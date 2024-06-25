FROM alpine:3.19@sha256:af4785ccdbcd5cde71bfd5b93eabd34250b98651f19fe218c91de6c8d10e21c5

RUN apk add --no-cache gettext

ADD envsubst_inplace.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
