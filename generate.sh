#!/bin/bash

echo "Generating Go files from protobuf..."

PROTOC_BIN=""

# Check if protoc is installed globally
if command -v protoc &> /dev/null; then
    PROTOC_BIN="$(command -v protoc)"
elif [ -x "./tools/protoc/bin/protoc" ]; then
    PROTOC_BIN="$(pwd)/tools/protoc/bin/protoc"
elif [ -x "./tools/protoc/bin/protoc.exe" ]; then
    PROTOC_BIN="$(pwd)/tools/protoc/bin/protoc.exe"
else
    echo "Error: protoc is not installed or not in PATH"
    echo ""
    echo "Please install protoc:"
    echo "  Windows: Download from https://github.com/protocolbuffers/protobuf/releases"
    echo "  Or use: choco install protoc"
    echo "  Or use: scoop install protobuf"
    echo ""
    echo "After installation, make sure protoc is in your PATH or placed in ./tools/protoc/bin"
    exit 1
fi

# Check if protoc-gen-go is installed
if ! command -v protoc-gen-go &> /dev/null; then
    echo "Warning: protoc-gen-go not found. Installing..."
    go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
fi

# Check if protoc-gen-go-grpc is installed
if ! command -v protoc-gen-go-grpc &> /dev/null; then
    echo "Warning: protoc-gen-go-grpc not found. Installing..."
    go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
fi

# Generate files
"$PROTOC_BIN" --go_out=contract --go_opt=paths=source_relative \
       --go-grpc_out=contract --go-grpc_opt=paths=source_relative \
       --proto_path=proto \
       --proto_path=tools/protoc/include \
       proto/outbox/outbox.proto proto/user/user.proto

if [ $? -eq 0 ]; then
    echo "Successfully generated Go files!"
    echo "  - contract/outbox/outbox.pb.go"
    echo "  - contract/outbox/outbox_grpc.pb.go"
    echo "  - contract/user/user.pb.go"
    echo "  - contract/user/user_grpc.pb.go"
else
    echo "Error: Failed to generate Go files"
    exit 1
fi

