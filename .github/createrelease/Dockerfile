FROM mhart/alpine-node:10

WORKDIR /

ENV GITHUB_TOKEN=$GITHUB_TOKEN
ENV GITHUB_EVENT_PATH=$GITHUB_EVENT_PATH

COPY ["app.js", "package.json", "./"]

RUN npm install

CMD ["node", "app.js"]