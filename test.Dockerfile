FROM node:12 as BASE
# I use yarn, you can swap with npm and cut a step or two out
RUN curl -o- -L https://yarnpkg.com/install.sh | bash
WORKDIR /app
COPY package.json \
  yarn.lock \
  ./
RUN yarn

FROM BASE AS DEV
COPY .eslintrc.js \
  .prettierrc \
  nest-cli.json \
  tsconfig.* \
  ./
# bring in src from context
COPY ./src/ ./src/
RUN yarn lint

FROM DEV as TEST
# bring in test from context
COPY ./test/ ./test/
RUN yarn test

CMD ["./node_modules/.bin/jest", "--config", "./test/jest-e2e.json"]