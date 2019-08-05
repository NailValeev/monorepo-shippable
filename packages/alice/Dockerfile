FROM node:10.13-alpine

# Environment
WORKDIR /home/app/
ENV NODE_ENV=production

COPY package.json /home/app/
COPY . /home/app/

RUN yarn install

# Build

RUN cd packages/alice && yarn build
EXPOSE 3000
CMD yarn workspace alice start

