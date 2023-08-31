FROM registry.access.redhat.com/ubi9/go-toolset@sha256:52ab391730a63945f61d93e8c913db4cc7a96f200de909cd525e2632055d9fa6 AS builder
ENV APP_ROOT=/opt/app-root
ENV GOPATH=$APP_ROOT
ENV CGO_ENABLED=false
ENV -buildvcs=false

WORKDIR $APP_ROOT/src/
ADD go.mod go.sum $APP_ROOT/src/
RUN go mod download
RUN git config --global --add safe.directory /opt/app-root/src

# Add source code
ADD ./ $APP_ROOT/src/

RUN go build -v ./cmd/trillian_log_signer


# Multi-Stage production build
FROM registry.access.redhat.com/ubi9/go-toolset@sha256:52ab391730a63945f61d93e8c913db4cc7a96f200de909cd525e2632055d9fa6 as deploy

# Retrieve the binary from the previous stage
COPY --from=builder /opt/app-root/src/trillian_log_signer /

# Set the binary as the entrypoint of the container
ENTRYPOINT ["/trillian_log_signer"]