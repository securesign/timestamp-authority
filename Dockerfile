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

FROM golang:1.24.2@sha256:1ecc479bc712a6bdb56df3e346e33edcc141f469f82840bab9f4bc2bc41bf91d AS builder
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
FROM registry.access.redhat.com/ubi9/go-toolset@sha256:fd2e89bb5f1387856fb00e8c3c4c7d488a9228e8c0a695b2b145a5307dd51e26 as debug
RUN go install github.com/go-delve/delve/cmd/dlv@v1.9.0

# overwrite server and include debugger
COPY --from=builder /opt/app-root/src/timestamp-server_debug /usr/local/bin/timestamp-server

# Multi-Stage production build
FROM golang:1.24.2@sha256:1ecc479bc712a6bdb56df3e346e33edcc141f469f82840bab9f4bc2bc41bf91d as deploy

# Retrieve the binary from the previous stage
COPY --from=builder /opt/app-root/src/timestamp-server /usr/local/bin/timestamp-server

# Set the binary as the entrypoint of the container
CMD ["timestamp-server", "serve"]

# debug compile options & debugger
FROM deploy as debug
RUN go install github.com/go-delve/delve/cmd/dlv@v1.22.1

# overwrite server and include debugger
COPY --from=builder /opt/app-root/src/timestamp-server_debug /usr/local/bin/timestamp-server
