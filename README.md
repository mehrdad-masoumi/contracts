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
│   ├── outbox/v1/outbox.proto
│   └── adinfo/v1/adinfo.proto
└── contract/
    ├── outbox/v1/
    ├── outboxcontract/
    └── adinfo/v1/
```

Use the generated Go packages from `contract/`:

```go
import (
	outboxv1 "github.com/mehrdad-masoumi/contracts/contract/outbox/v1"
	outboxcontract "github.com/mehrdad-masoumi/contracts/contract/outboxcontract"
	adinfov1 "github.com/mehrdad-masoumi/contracts/contract/adinfo/v1"
)
```

`outboxcontract.OutboxPattern` is a small Go interface for services that depend on the outbox pattern directly. `outboxv1` is the generated protobuf/gRPC package.

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

`adinfo.v1` currently defines messages only. It does not define a gRPC service because it is used for RabbitMQ protobuf serialization.

## gRPC Usage

For gRPC contracts, service definitions must exist in the `.proto` file. The `outbox.v1` contract defines a gRPC service.

### Outbox

```go
import (
	"context"
	"log"

	outboxv1 "github.com/mehrdad-masoumi/contracts/contract/outbox/v1"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/protobuf/types/known/structpb"
)

func example(ctx context.Context) error {
	conn, err := grpc.Dial("localhost:50051", grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		return err
	}
	defer conn.Close()

	client := outboxv1.NewOutboxServiceClient(conn)
	headers, err := structpb.NewStruct(map[string]interface{}{
		"content_type": "application/json",
	})
	if err != nil {
		return err
	}

	_, err = client.AddEvent(ctx, &outboxv1.AddEventRequest{
		AggregateType: "user",
		AggregateId:   123,
		EventType:     "user.created",
		Payload:       []byte(`{"name":"John Doe"}`),
		Des:           []string{"notification", "analytics"},
		Headers:       headers,
	})
	if err != nil {
		return err
	}

	log.Println("outbox event accepted")
	return nil
}
```

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
