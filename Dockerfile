FROM node:12 as BASE
# I use yarn, you can swap with npm and cut a step or two out
RUN curl -o- -L https://yarnpkg.com/install.sh | bash
WORKDIR /app
COPY package.json \
  yarn.lock \
  ./
RUN yarn --production

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
RUN yarn build


# use one of the smallest images possible
FROM node:12-alpine
# get package.json from base
COPY --from=BASE /app/package.json ./
# get the dist back
COPY --from=DEV /app/dist/ ./dist/
# get the node_modules from the intial cache
COPY --from=BASE /app/node_modules/ ./node_modules/
# expose application port 
EXPOSE 3000
# start
CMD ["node", "dist/main.js"]
