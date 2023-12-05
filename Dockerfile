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

FROM brew.registry.redhat.io/rh-osbs/openshift-golang-builder:rhel_9_1.21@sha256:98a0ff138c536eee98704d6909699ad5d0725a20573e2c510a60ef462b45cce0 AS builder
ENV APP_ROOT=/opt/app-root
ENV GOPATH=$APP_ROOT
RUN mkdir /opt/app-root && mkdir /opt/app-root/src

WORKDIR $APP_ROOT/src/

ADD go.mod go.sum $APP_ROOT/src/
ADD ./cmd/ $APP_ROOT/src/cmd/
ADD ./pkg/ $APP_ROOT/src/pkg/

RUN git config --global --add safe.directory /opt/app-root/src && \
    go mod download && \
    CGO_ENABLED=0 go build -ldflags "${SERVER_LDFLAGS}" ./cmd/timestamp-server

# Multi-Stage production build
FROM brew.registry.redhat.io/rh-osbs/openshift-golang-builder:rhel_9_1.21@sha256:98a0ff138c536eee98704d6909699ad5d0725a20573e2c510a60ef462b45cce0 as deploy

# Retrieve the binary from the previous stage
COPY --from=builder /opt/app-root/src/timestamp-server /usr/local/bin/timestamp-server

# Set the binary as the entrypoint of the container
CMD ["timestamp-server", "serve"]