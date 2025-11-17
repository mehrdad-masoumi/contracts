.PHONY: proto clean deps tidy

TOOLS_PROTOC := $(firstword $(wildcard tools/protoc/bin/protoc tools/protoc/bin/protoc.exe))
PROTO_FILES := $(wildcard proto/outbox/*.proto) $(wildcard proto/user/*.proto)
PROTOC_INCLUDE := --proto_path=proto

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
	rm -f contract/outbox/*.pb.go contract/outbox/*_grpc.pb.go
	rm -f contract/user/*.pb.go contract/user/*_grpc.pb.go

# Install dependencies
deps:
	go mod download
	go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
	go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

# Tidy go.mod
tidy:
	go mod tidy

