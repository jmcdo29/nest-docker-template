FROM node:16-alpine AS base

WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn --production

# install node-prune (https://github.com/tj/node-prune)
RUN apk add curl bash --no-cache && \
	curl -sfL https://install.goreleaser.com/github.com/tj/node-prune.sh | bash -s -- -b /usr/local/bin

FROM base AS dev

# You MUST specify files/directories you don't want on your final image like .env file, dist, etc. The file .dockerignore at this folder is a good starting point.
COPY . .
RUN ls -l

# install required depedencies for compile related TypeScript/NestJS code
RUN yarn

# lint and formatting configs are commented out
# uncomment if you want to add them into the build process
# RUN yarn lint
RUN yarn build

# run node prune
RUN /usr/local/bin/node-prune

# use one of the smallest images possible
FROM node:16-alpine
# get package.json from base stage
COPY --from=base /app/package.json ./
# get the dist back
COPY --from=dev /app/dist/ ./dist/
# get the node_modules from base stage
COPY --from=base /app/node_modules/ ./node_modules/
# expose application port 
EXPOSE 3000
# start
CMD ["node", "dist/main.js"]
