# Build stage
FROM golang:1.24-alpine AS build

RUN apk add --no-cache git

WORKDIR /build
RUN git clone --depth=1 --branch=v5.18.1 https://github.com/TwiN/gatus.git .

RUN go build -o gatus .

# Final stage
FROM alpine:3.19

RUN apk add --no-cache bash gettext

COPY --from=build /build/gatus /gatus
COPY entrypoint.sh /entrypoint.sh
COPY config.template.yml /config.template.yml

RUN chmod +x /gatus /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
