# Copyright 2022 The Sigstore Authors.
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

FROM golang:1.25.8@sha256:e282f9e8023cc22767b4fc0bfe53b97db8edfcc395a603691c126bb0a6160703 AS builder
ENV APP_ROOT=/opt/app-root
ENV GOPATH=$APP_ROOT

WORKDIR $APP_ROOT/src/
ADD go.mod go.sum $APP_ROOT/src/
RUN go mod download

# Add source code
ADD ./cmd/ $APP_ROOT/src/cmd/
ADD ./pkg/ $APP_ROOT/src/pkg/

ARG SERVER_LDFLAGS
RUN go build -ldflags "${SERVER_LDFLAGS}" ./cmd/timestamp-server
RUN CGO_ENABLED=0 go build -gcflags "all=-N -l" -ldflags "${SERVER_LDFLAGS}" -o timestamp-server_debug ./cmd/timestamp-server

# debug compile options & debugger
FROM registry.redhat.io/ubi9/go-toolset:9.7-1775491036@sha256:d6b5e8c74c20bf1fa8235b4c81152dc2bd89a13f8b72977a141e4ad509b13eed as debug
RUN go install github.com/go-delve/delve/cmd/dlv@v1.9.0

# overwrite server and include debugger
COPY --from=builder /opt/app-root/src/timestamp-server_debug /usr/local/bin/timestamp-server

# Multi-Stage production build
FROM golang:1.25.8@sha256:e282f9e8023cc22767b4fc0bfe53b97db8edfcc395a603691c126bb0a6160703 as deploy

# Retrieve the binary from the previous stage
COPY --from=builder /opt/app-root/src/timestamp-server /usr/local/bin/timestamp-server

# Set the binary as the entrypoint of the container
CMD ["timestamp-server", "serve"]

# debug compile options & debugger
FROM deploy as debug
RUN go install github.com/go-delve/delve/cmd/dlv@v1.22.1

# overwrite server and include debugger
COPY --from=builder /opt/app-root/src/timestamp-server_debug /usr/local/bin/timestamp-server
