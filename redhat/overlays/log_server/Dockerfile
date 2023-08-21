#
# Copyright 2021 The Sigstore Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM golang:1.20.7@sha256:bc5f0b5e43282627279fe5262ae275fecb3d2eae3b33977a7fd200c7a760d6f1 AS builder
ENV APP_ROOT=/opt/app-root
ENV GOPATH=$APP_ROOT
ENV CGO_ENABLED=0

WORKDIR $APP_ROOT/src/
ADD go.mod $APP_ROOT/src/
ADD go.sum $APP_ROOT/src/
RUN go mod download

# Add source code
ADD ./ $APP_ROOT/src/
 
RUN go build ./cmd/trillian_log_server


# Multi-Stage production build
FROM golang:1.20.7@sha256:bc5f0b5e43282627279fe5262ae275fecb3d2eae3b33977a7fd200c7a760d6f1 as deploy

# Retrieve the binary from the previous stage
COPY --from=builder /opt/app-root/src/cmd/trillian_log_server /usr/local/bin/trillian_log_server

# Set the binary as the entrypoint of the container
#CMD ["trillian_log_server"]

# debug compile options & debugger
#FROM deploy as debug
#RUN go install github.com/go-delve/delve/cmd/dlv@v1.21.0

# overwrite server and include debugger
#COPY --from=builder /opt/app-root/src/cmd/trillian_log_server_debug /usr/local/bin/trillian_log_server

#FROM deploy as test
# overwrite server with test build with code coverage
#COPY --from=builder /opt/app-root/src/cmd/trillian_log_server_test /usr/local/bin/trillian_log_server


