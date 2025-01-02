SHELL := /bin/bash
MAKEFLAGS += --no-print-directory

GOBIN = go

IDEN1 = "*"
IDEN2 = "**"

HOST_OS != $(GOBIN) env GOOS
HOST_ARCH != $(GOBIN) env GOARCH

VERSION != git rev-parse HEAD | head -c8

GOOS = $(HOST_OS)
GOARCH = $(HOST_ARCH)

CFLAGS = -X github.com/zanz1n/blog/config.Version=$(VERSION) -X github.com/zanz1n/blog/config.Name=blog

.PHONY: default

default: check build-dev build

run: override GOOS = $(HOST_OS)
run: override GOARCH = $(HOST_ARCH)
run: build-dev
	@echo "$(IDEN1) Running app:"
	@./bin/blog_$(GOOS)_$(GOARCH)_debug

build: OUT ?= bin/blog_$(GOOS)_$(GOARCH)
build: BTAG = Build
build: ALL_CFLAGS = -s -w $(CFLAGS)

build-dev: OUT ?= bin/blog_$(GOOS)_$(GOARCH)_debug
build-dev: BTAG = Build dev
build-dev: ALL_CFLAGS = $(CFLAGS)

build build-dev: check
	@echo "$(IDEN1) $(BTAG):"
	@echo "$(IDEN2) OS: $(GOOS) ARCH: $(GOARCH)"
	$(GOBIN) build -v -ldflags "$(ALL_CFLAGS)" -o $(OUT) .
	@echo "$(IDEN1) $(BTAG): completed"

check: deps generate test

test:
	@echo "$(IDEN1) Test:"
ifneq ($(SKIPTESTS), 1)
	$(GOBIN) test ./... -v --race
	@echo "$(IDEN1) Test: completed"
else
	@echo "$(IDEN1) Test: skipped"
endif

generate:
	@echo "$(IDEN1) Codegen:"

	templ generate
	@echo "$(IDEN2) Generated templ components"

	@echo "$(IDEN1) Codegen: completed"

deps:
	@echo "$(IDEN1) Download binaries:"

	$(GOBIN) install github.com/a-h/templ/cmd/templ@latest
	@echo "$(IDEN2) Downloaded templ"

	@echo "$(IDEN1) Download binaries: completed"

update:
	@echo "$(IDEN1) Update:"

	$(GOBIN) mod tidy

	$(GOBIN) get -u ./...
	@echo "$(IDEN2) Updated go modules"

	$(GOBIN) mod tidy
	@echo "$(IDEN2) Tidy go mod file"
	@echo "$(IDEN1) Update: completed"
