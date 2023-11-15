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

FROM registry.access.redhat.com/ubi9/go-toolset@sha256:c3a9c5c7fb226f6efcec2424dd30c38f652156040b490c9eca5ac5b61d8dc3ca AS builder
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
FROM registry.access.redhat.com/ubi9/go-toolset@sha256:c3a9c5c7fb226f6efcec2424dd30c38f652156040b490c9eca5ac5b61d8dc3ca as debug
RUN go install github.com/go-delve/delve/cmd/dlv@v1.9.0

# overwrite server and include debugger
COPY --from=builder /opt/app-root/src/timestamp-server_debug /usr/local/bin/timestamp-server

# Multi-Stage production build
FROM registry.access.redhat.com/ubi9/ubi-minimal@sha256:7d1ea7ac0c6f464dac7bae6994f1658172bf6068229f40778a513bc90f47e624 as deploy

LABEL description="The timestamp-authority is a process that provides a timestamp record of when a document was created or modified."
LABEL io.k8s.description="The timestamp-authority is a process that provides a timestamp record of when a document was created or modified."
LABEL io.k8s.display-name="Timestamp-authority container image for Red Hat Trusted Signer."
LABEL io.openshift.tags="TSA trusted-signer."
LABEL summary="Provides a timestamp-authority image."
LABEL com.redhat.component="timestamp-authority"

# Retrieve the binary from the previous stage
COPY --from=builder /opt/app-root/src/timestamp-server /usr/local/bin/timestamp-server

# Set the binary as the entrypoint of the container
CMD ["timestamp-server", "serve"]
