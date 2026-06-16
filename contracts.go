// Package contracts provides shared protobuf contracts for Go microservices.
//
// This package contains protobuf definitions for:
//   - Outbox Service: outbox message management
//   - OutboxPattern: direct Go interface for outbox dependencies
//   - AdInfo messages: RabbitMQ protobuf serialization
//
// Import the specific subpackages you need:
//
//	import (
//		outboxv1 "github.com/mehrdad-masoumi/contracts/contract/outbox/v1"
//		outboxcontract "github.com/mehrdad-masoumi/contracts/contract/outboxcontract"
//		adinfov1 "github.com/mehrdad-masoumi/contracts/contract/adinfo/v1"
//	)
package contracts
