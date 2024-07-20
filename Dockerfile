# Stage 1: Build
FROM node:18-alpine as build

# Install necessary build tools and dependencies
RUN apk update && apk add --no-cache build-base gcc autoconf automake zlib-dev libpng-dev vips-dev git > /dev/null 2>&1
ENV NODE_ENV=production

WORKDIR /opt/

# Copy and install dependencies
COPY package.json yarn.lock ./
RUN yarn global add node-gyp
RUN yarn config set network-timeout 600000 -g && yarn install --production
RUN yarn add mysql2
ENV PATH /opt/node_modules/.bin:$PATH

# Copy the rest of the application and build it
WORKDIR /opt/app
COPY . .
RUN yarn build

# Stage 2: Production Image
FROM node:18-alpine

# Install runtime dependencies
RUN apk add --no-cache vips-dev
ENV NODE_ENV=production

WORKDIR /opt/

# Copy node_modules from build stage
COPY --from=build /opt/node_modules ./node_modules

WORKDIR /opt/app

# Copy built application from build stage
COPY --from=build /opt/app ./
ENV PATH /opt/node_modules/.bin:$PATH

# Set correct permissions
RUN chown -R node:node /opt/app
USER node

# Expose the application port
EXPOSE 1337

# Start the application
CMD ["yarn", "start"]
