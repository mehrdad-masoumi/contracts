# Service Contracts

Shared protobuf contracts for Go microservices.

This repository keeps `.proto` files as the source of truth and generated Go code under `contract/`. Generated `.pb.go` and `_grpc.pb.go` files should not be edited manually.

Module path:

```bash
github.com/mehrdad-masoumi/contracts
```

## Contracts

Contracts are versioned under `v1`.

```text
contracts/
├── proto/
│   ├── adinfo/v1/adinfo.proto
│   ├── tracker/v1/tracker.proto
│   ├── link/v1/link.proto
│   ├── updatemeettarget/v1/update_meet_target.proto
│   └── impression/v1/impression.proto
└── contract/
    ├── adinfo/v1/
    ├── tracker/v1/
    ├── link/v1/
    ├── updatemeettarget/v1/
    └── impression/v1/
```

Use the generated Go packages from `contract/<name>/v1` for RabbitMQ protobuf payloads:

```go
import (
	adinfov1 "github.com/mehrdad-masoumi/contracts/contract/adinfo/v1"
	trackerv1 "github.com/mehrdad-masoumi/contracts/contract/tracker/v1"
	linkv1 "github.com/mehrdad-masoumi/contracts/contract/link/v1"
	updatemeettargetv1 "github.com/mehrdad-masoumi/contracts/contract/updatemeettarget/v1"
	impressionv1 "github.com/mehrdad-masoumi/contracts/contract/impression/v1"
)
```

Go interfaces for in-process dependencies (message queue, outbox, adinfo client) belong in each service repository under `internal/port/`, not in this module.

## Installation

```bash
go get github.com/mehrdad-masoumi/contracts
```

## Generating Go Code

Install `protoc` and the Go plugins first. See `INSTALL.md` for platform-specific setup.

```bash
go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.33.0
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.4.0
```

Generate all contracts:

```bash
make proto
```

Alternative scripts:

```bash
./generate.sh
.\generate.bat
```

The generation tools recursively discover `.proto` files under `proto/` and write generated Go files under matching paths in `contract/`.

## RabbitMQ Protobuf Messages

Use `google.golang.org/protobuf/proto` for RabbitMQ payload serialization. Recommended RabbitMQ content type:

```text
application/x-protobuf
```

### AdInfo Producer

```go
import (
	"google.golang.org/protobuf/proto"

	adinfov1 "github.com/mehrdad-masoumi/contracts/contract/adinfo/v1"
)

msg := &adinfov1.AdInfoResolveRequested{
	RequestId: "request-123",
	Token:     "token-abc",
}

body, err := proto.Marshal(msg)
if err != nil {
	return err
}
```

### AdInfo Consumer

```go
import (
	"google.golang.org/protobuf/proto"

	adinfov1 "github.com/mehrdad-masoumi/contracts/contract/adinfo/v1"
)

var msg adinfov1.AdInfoResolveRequested
if err := proto.Unmarshal(delivery.Body, &msg); err != nil {
	return err
}
```

All current contracts define RabbitMQ protobuf messages only; none define a gRPC service.

## Development

Common commands:

```bash
make proto
make clean
make deps
make tidy
go test ./...
```

When changing a contract:

1. Edit the `.proto` file under `proto/<contract>/v1/`.
2. Run `make proto`.
3. Run `go test ./...`.
4. Commit both the `.proto` change and regenerated Go files.

## Versioning

Additive changes are preferred within `v1`, such as adding new optional fields with new field numbers. Avoid reusing or renumbering existing fields.

For breaking changes, add a new version directory such as `proto/outbox/v2/` and generate a matching package under `contract/outbox/v2/`.
