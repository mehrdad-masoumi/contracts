package outboxcontract

import "context"

type OutboxPattern interface {
	AddEvent(
		ctx context.Context,
		aggregateType string,
		aggregateID uint64,
		eventType string,
		payload []byte,
		des []string,
		headers map[string]interface{},
	) error
}
