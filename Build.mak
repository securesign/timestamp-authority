.PHONY: 
cross-platform: fetch-tsa-certs-darwin-arm64 fetch-tsa-certs-darwin-amd64 fetch-tsa-certs-linux-amd64 fetch-tsa-certs-linux-arm64 fetch-tsa-certs-linux-ppc64le fetch-tsa-certs-linux-s390x fetch-tsa-certs-windows ## Build all distributable (cross-platform) binaries

.PHONY:	fetch-tsa-certs-darwin-arm64
fetch-tsa-certs-darwin-arm64: ## Build for mac M1
	env CGO_ENABLED=0 GOOS=darwin GOARCH=arm64 go build -mod=readonly -o fetch_tsa_certs_darwin_arm64 -trimpath ./cmd/fetch-tsa-certs

.PHONY: fetch-tsa-certs-darwin-amd64
fetch-tsa-certs-darwin-amd64:  ## Build for Darwin (macOS)
	env CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 go build -mod=readonly -o fetch_tsa_certs_darwin_amd64 -trimpath ./cmd/fetch-tsa-certs

.PHONY: fetch-tsa-certs-linux-amd64 
fetch-tsa-certs-linux-amd64: ## Build for Linux amd64
	env CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -mod=readonly -o fetch_tsa_certs_linux_amd64 -trimpath ./cmd/fetch-tsa-certs

.PHONY: fetch-tsa-certs-linux-arm64
fetch-tsa-certs-linux-arm64: ## Build for Linux arm64
	env CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -mod=readonly -o fetch_tsa_certs_linux_arm64 -trimpath ./cmd/fetch-tsa-certs

.PHONY: fetch-tsa-certs-linux-ppc64le
fetch-tsa-certs-linux-ppc64le: ## Build for Linux ppc64le
	env CGO_ENABLED=0 GOOS=linux GOARCH=ppc64le go build -mod=readonly -o fetch_tsa_certs_linux_ppc64le -trimpath ./cmd/fetch-tsa-certs

.PHONY: fetch-tsa-certs-linux-s390x
fetch-tsa-certs-linux-s390x:  ## Build for Linux s390x
	env CGO_ENABLED=0 GOOS=linux GOARCH=s390x go build -mod=readonly -o fetch_tsa_certs_linux_s390x -trimpath ./cmd/fetch-tsa-certs

.PHONY: fetch-tsa-certs-windows
fetch-tsa-certs-windows: ## Build for Windows
	env CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build -mod=readonly -o fetch_tsa_certs_windows_amd64.exe -trimpath ./cmd/fetch-tsa-certs
