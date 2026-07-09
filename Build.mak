FIPS_MODULE ?= latest
BUILD_FLAGS = -mod=readonly -tags=no_openssl -buildvcs=false -trimpath

.PHONY: fetch-tsa-certs-linux
fetch-tsa-certs-linux: ## Build native Linux binary (FIPS)
	env CGO_ENABLED=0 GOFIPS140=v1.0.0 go build $(BUILD_FLAGS) -o fetch_tsa_certs ./cmd/fetch-tsa-certs

.PHONY: fetch-tsa-certs-linux-amd64
fetch-tsa-certs-linux-amd64: ## Build for Linux amd64
	env CGO_ENABLED=0 GOFIPS140=$(FIPS_MODULE) GOOS=linux GOARCH=amd64 go build $(BUILD_FLAGS) -o fetch_tsa_certs_linux_amd64 ./cmd/fetch-tsa-certs

.PHONY: fetch-tsa-certs-linux-arm64
fetch-tsa-certs-linux-arm64: ## Build for Linux arm64
	env CGO_ENABLED=0 GOFIPS140=$(FIPS_MODULE) GOOS=linux GOARCH=arm64 go build $(BUILD_FLAGS) -o fetch_tsa_certs_linux_arm64 ./cmd/fetch-tsa-certs

.PHONY: fetch-tsa-certs-linux-ppc64le
fetch-tsa-certs-linux-ppc64le: ## Build for Linux ppc64le
	env CGO_ENABLED=0 GOFIPS140=$(FIPS_MODULE) GOOS=linux GOARCH=ppc64le go build $(BUILD_FLAGS) -o fetch_tsa_certs_linux_ppc64le ./cmd/fetch-tsa-certs

.PHONY: fetch-tsa-certs-linux-s390x
fetch-tsa-certs-linux-s390x: ## Build for Linux s390x
	env CGO_ENABLED=0 GOFIPS140=$(FIPS_MODULE) GOOS=linux GOARCH=s390x go build $(BUILD_FLAGS) -o fetch_tsa_certs_linux_s390x ./cmd/fetch-tsa-certs

.PHONY: cross-platform
cross-platform: fetch-tsa-certs-darwin-arm64 fetch-tsa-certs-darwin-amd64 fetch-tsa-certs-windows ## Build all distributable (cross-platform) binaries

.PHONY: all-platforms
all-platforms: fetch-tsa-certs-linux-amd64 fetch-tsa-certs-linux-arm64 fetch-tsa-certs-linux-ppc64le fetch-tsa-certs-linux-s390x cross-platform ## Build all binaries for all platforms

.PHONY:	fetch-tsa-certs-darwin-arm64
fetch-tsa-certs-darwin-arm64: ## Build for mac M1
	env CGO_ENABLED=0 GOFIPS140=$(FIPS_MODULE) GOOS=darwin GOARCH=arm64 go build $(BUILD_FLAGS) -o fetch_tsa_certs_darwin_arm64 ./cmd/fetch-tsa-certs

.PHONY: fetch-tsa-certs-darwin-amd64
fetch-tsa-certs-darwin-amd64:  ## Build for Darwin (macOS)
	env CGO_ENABLED=0 GOFIPS140=$(FIPS_MODULE) GOOS=darwin GOARCH=amd64 go build $(BUILD_FLAGS) -o fetch_tsa_certs_darwin_amd64 ./cmd/fetch-tsa-certs

.PHONY: fetch-tsa-certs-windows
fetch-tsa-certs-windows: ## Build for Windows
	env CGO_ENABLED=0 GOFIPS140=$(FIPS_MODULE) GOOS=windows GOARCH=amd64 go build $(BUILD_FLAGS) -o fetch_tsa_certs_windows_amd64.exe ./cmd/fetch-tsa-certs
