FROM appropriate/curl

RUN apk -v --update add \
  make \
  curl \
  jq

COPY  "entrypoint.sh" "/entrypoint.sh"

ENTRYPOINT ["/entrypoint.sh"]
