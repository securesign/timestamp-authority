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
    CGO_ENABLED=0 go build -mod=readonly -ldflags "${SERVER_LDFLAGS}" ./cmd/timestamp-server

# Multi-Stage production build
FROM registry.access.redhat.com/ubi9/ubi-minimal@sha256:06d06f15f7b641a78f2512c8817cbecaa1bf549488e273f5ac27ff1654ed33f0 as deploy

# Retrieve the binary from the previous stage
COPY --from=builder /opt/app-root/src/timestamp-server /usr/local/bin/timestamp-server

LABEL description="The timestamp-authority is a process that provides a timestamp record of when a document was created or modified."
LABEL io.k8s.description="The timestamp-authority is a process that provides a timestamp record of when a document was created or modified."
LABEL io.k8s.display-name="Timestamp-authority container image for Red Hat Trusted Signer."
LABEL io.openshift.tags="TSA trusted-signer."
LABEL summary="Provides a timestamp-authority image."
LABEL com.redhat.component="timestamp-authority"

# Set the binary as the entrypoint of the container
CMD ["timestamp-server", "serve"]