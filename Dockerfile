FROM node:18-alpine3.18

# Installing libvips-dev for sharp Compatibility
RUN apk update && apk add --no-cache build-base gcc autoconf automake zlib-dev libpng-dev nasm bash vips-dev git

# Set the environment variable
ARG NODE_ENV=development
ENV NODE_ENV=${NODE_ENV}

WORKDIR /opt/

# Copy package files and install dependencies
COPY package.json yarn.lock ./
RUN yarn global add node-gyp
RUN yarn config set network-timeout 600000 -g && yarn install
RUN yarn add mysql2

# Set PATH for node modules
ENV PATH /opt/node_modules/.bin:$PATH

WORKDIR /opt/app

# Copy application code and set permissions
COPY . .
RUN chown -R node:node /opt/app
USER node

# Build the application
RUN ["yarn", "build"]

# Expose the application port
EXPOSE 1337

# Start the application
CMD ["yarn", "develop"]
