FIPS_MODULE ?= latest

.PHONY: 
cross-platform: fetch-tsa-certs-darwin-arm64 fetch-tsa-certs-darwin-amd64 fetch-tsa-certs-windows ## Build all distributable (cross-platform) binaries

.PHONY:	fetch-tsa-certs-darwin-arm64
fetch-tsa-certs-darwin-arm64: ## Build for mac M1
	env CGO_ENABLED=0 GOFIPS140=$(FIPS_MODULE) GOOS=darwin GOARCH=arm64 go build -mod=readonly -o fetch_tsa_certs_darwin_arm64 -trimpath ./cmd/fetch-tsa-certs

.PHONY: fetch-tsa-certs-darwin-amd64
fetch-tsa-certs-darwin-amd64:  ## Build for Darwin (macOS)
	env CGO_ENABLED=0 GOFIPS140=$(FIPS_MODULE) GOOS=darwin GOARCH=amd64 go build -mod=readonly -o fetch_tsa_certs_darwin_amd64 -trimpath ./cmd/fetch-tsa-certs

.PHONY: fetch-tsa-certs-windows
fetch-tsa-certs-windows: ## Build for Windows
	env CGO_ENABLED=0 GOFIPS140=$(FIPS_MODULE) GOOS=windows GOARCH=amd64 go build -mod=readonly -o fetch_tsa_certs_windows_amd64.exe -trimpath ./cmd/fetch-tsa-certs
