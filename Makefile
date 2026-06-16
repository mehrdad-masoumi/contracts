.PHONY: proto clean deps tidy

TOOLS_PROTOC := $(firstword $(wildcard tools/protoc/bin/protoc tools/protoc/bin/protoc.exe))
PROTO_FILES := $(shell find proto -name "*.proto")
PROTOC_INCLUDE := --proto_path=proto
PROTOC_GEN_GO_VERSION ?= v1.33.0
PROTOC_GEN_GO_GRPC_VERSION ?= v1.4.0

ifeq ($(TOOLS_PROTOC),)
PROTOC ?= protoc
else
PROTOC ?= $(TOOLS_PROTOC)
endif

ifneq ($(wildcard tools/protoc/include),)
PROTOC_INCLUDE += --proto_path=tools/protoc/include
endif

# Generate Go code from protobuf files
proto:
	$(PROTOC) --go_out=contract --go_opt=paths=source_relative \
	       --go-grpc_out=contract --go-grpc_opt=paths=source_relative \
	       $(PROTOC_INCLUDE) \
	       $(PROTO_FILES)

# Clean generated files
clean:
	find contract -name "*.pb.go" -delete
	find contract -name "*_grpc.pb.go" -delete

# Install dependencies
deps:
	go mod download
	go install google.golang.org/protobuf/cmd/protoc-gen-go@$(PROTOC_GEN_GO_VERSION)
	go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@$(PROTOC_GEN_GO_GRPC_VERSION)

# Tidy go.mod
tidy:
	go mod tidy

