// Package contracts provides shared protobuf contracts for Go microservices.
//
// All RabbitMQ wire payloads are defined as protobuf messages under proto/.
// Go interfaces for in-process dependencies (ports, adapters) belong in each
// service repository, not in this module.
//
// Import the specific subpackages you need:
//
//	import (
//		adinfov1 "github.com/mehrdad-masoumi/contracts/contract/adinfo/v1"
//		trackerv1 "github.com/mehrdad-masoumi/contracts/contract/tracker/v1"
//		linkv1 "github.com/mehrdad-masoumi/contracts/contract/link/v1"
//		updatemeettargetv1 "github.com/mehrdad-masoumi/contracts/contract/updatemeettarget/v1"
//		impressionv1 "github.com/mehrdad-masoumi/contracts/contract/impression/v1"
//	)
package contracts
