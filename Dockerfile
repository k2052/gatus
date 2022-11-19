# Build the go application into a binary
FROM golang:1.19-buster as builder
WORKDIR /app
COPY . ./
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o gatus .

# Run Tests inside docker image if you don't have a configured go environment
#RUN apk update && apk add --virtual build-dependencies build-base gcc
#RUN go test ./... -mod vendor

# Run the binary on an empty container
FROM debian:buster-slim
RUN set -x && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*
COPY --from=builder /app/gatus .
COPY --from=builder /app/config.yaml ./config/config.yml
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
ENV PORT=8080
EXPOSE ${PORT}
CMD ["/gatus"]
