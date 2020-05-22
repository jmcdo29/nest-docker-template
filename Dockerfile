FROM node:12 as BASE
# I use yarn, you can swap with npm and cut a step or two out
RUN curl -o- -L https://yarnpkg.com/install.sh | bash
WORKDIR /app
COPY package.json \
  yarn.lock \
  ./
RUN yarn --production
# cache the production necessary node_modules/
RUN mv node_modules/ /tmp/node_modules/

FROM BASE AS DEV
COPY .eslintrc.js \
  .prettierrc \
  nest-cli.json \
  tsconfig.* \
  ./
# bring in src from context
COPY ./src/ ./src/
RUN yarn
RUN yarn lint

FROM DEV as TEST
# bring in test from context
COPY ./test/ ./test/
RUN yarn test
RUN yarn test:e2e

FROM DEV as BUILD
RUN yarn build
# cache the dist directory 
# not necessary, but follows the idea from other steps
RUN mv dist/ /tmp/dist/

# use smallest image possible
FROM node:12-alpine
# get package.json from base
COPY --from=BASE /app/package.json ./
# get the dist back
COPY --from=BUILD /tmp/dist/ ./dist/
# get the node_modules from the intial cache
COPY --from=BASE /tmp/node_modules/ ./node_modules/
# start
CMD ["yarn", "start:prod"]