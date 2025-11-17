# Service Contracts

پکیج قراردادهای gRPC برای تمام سرویس‌های میکروسرویس

این مخزن شامل قراردادهای protobuf برای:
- **Outbox Service**: مدیریت پیام‌های outbox
- **User Service**: مدیریت کاربران و پروفایل

## نصب

برای استفاده از این پکیج در سرویس‌های دیگر:

```bash
go get github.com/mehrdad-masoumi/contracts
```

## ساخت فایل‌های Go

برای تولید فایل‌های Go از فایل‌های protobuf:

```bash
make proto
```

این دستور فایل‌های Go را برای تمام سرویس‌ها تولید می‌کند.

### پیش‌نیازها

1. نصب `protoc`:
   - Windows: دانلود از [protobuf releases](https://github.com/protocolbuffers/protobuf/releases)
   - یا با Chocolatey: `choco install protoc`
   - یا با Scoop: `scoop install protobuf`
   - **راهنمای کامل**: [INSTALL.md](INSTALL.md) را مطالعه کنید

2. نصب پلاگین‌های Go:
   ```bash
   go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
   go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
   ```
   
   **مهم**: مطمئن شوید `$GOPATH/bin` یا `$HOME/go/bin` در PATH شما است.

3. نصب وابستگی‌ها:
   ```bash
   make deps
   ```

**نکته**: اگر `make proto` کار نمی‌کند، می‌توانید از اسکریپت‌های جایگزین استفاده کنید:
- در Git Bash: `./generate.sh`
- در PowerShell: `.\generate.bat`

## استفاده در سرویس‌ها

### Outbox Service

#### Import کردن

```go
import (
    outboxpb "github.com/mehrdad-masoumi/contracts/contract/outbox"
    "google.golang.org/grpc"
)
```

#### مثال Server

```go
package main

import (
    "context"
    "log"
    "net"

    outboxpb "github.com/mehrdad-masoumi/contracts/contract/outbox"
    "google.golang.org/grpc"
)

type server struct {
    outboxpb.UnimplementedOutboxServiceServer
}

func (s *server) CreateMessage(ctx context.Context, req *outboxpb.CreateMessageRequest) (*outboxpb.CreateMessageResponse, error) {
    // پیاده‌سازی منطق ایجاد پیام
    message := &outboxpb.OutboxMessage{
        Id:           generateID(),
        AggregateId:  req.AggregateId,
        AggregateType: req.AggregateType,
        EventType:    req.EventType,
        Payload:      req.Payload,
        Status:       outboxpb.MessageStatus_MESSAGE_STATUS_PENDING,
        RetryCount:   0,
        CreatedAt:    time.Now().Unix(),
        UpdatedAt:    time.Now().Unix(),
    }
    
    return &outboxpb.CreateMessageResponse{Message: message}, nil
}

// سایر متدها...
```

#### مثال Client

```go
import (
    outboxpb "github.com/mehrdad-masoumi/contracts/contract/outbox"
    "google.golang.org/grpc"
)

conn, _ := grpc.Dial("localhost:50051", grpc.WithTransportCredentials(insecure.NewCredentials()))
client := outboxpb.NewOutboxServiceClient(conn)

req := &outboxpb.CreateMessageRequest{
    AggregateId:  "user-123",
    AggregateType: "user",
    EventType:    "user.created",
    Payload:      []byte(`{"name": "John Doe"}`),
}

resp, err := client.CreateMessage(ctx, req)
```

### User Service

#### Import کردن

```go
import (
    userpb "git.mtnirancell.ir/digital/yelloadwise/services/contracts/contract/user"
    "google.golang.org/grpc"
    "google.golang.org/protobuf/types/known/timestamppb"
)
```

#### مثال Server

```go
package main

import (
    "context"
    "log"
    "net"
    "time"

    userpb "git.mtnirancell.ir/digital/yelloadwise/services/contracts/user"
    "google.golang.org/grpc"
    "google.golang.org/protobuf/types/known/timestamppb"
)

type server struct {
    userpb.UnimplementedUserServiceServer
}

func (s *server) GetUserByID(ctx context.Context, req *userpb.GetUserByIDRequest) (*userpb.GetUserByIDResponse, error) {
    // دریافت کاربر از دیتابیس
    user := &userpb.User{
        Id:          req.UserId,
        Email:       "user@example.com",
        PhoneNumber: "+989123456789",
        Status:      userpb.StatusTypeUser_STATUS_TYPE_USER_ACTIVE,
        Verify:      true,
        Profile: &userpb.Profile{
            FirstName:   "John",
            LastName:    "Doe",
            NationalId:  "1234567890",
            Nationality: "IR",
        },
        Roles: []*userpb.Role{
            {
                Id:          "role-1",
                Name:        "admin",
                FullAccess:  true,
                AdminAccess: true,
            },
        },
        CreatedAt: timestamppb.New(time.Now()),
        UpdatedAt: timestamppb.New(time.Now()),
    }
    
    return &userpb.GetUserByIDResponse{Data: user}, nil
}

func main() {
    lis, err := net.Listen("tcp", ":50052")
    if err != nil {
        log.Fatalf("failed to listen: %v", err)
    }

    s := grpc.NewServer()
    userpb.RegisterUserServiceServer(s, &server{})

    log.Println("User Service listening on :50052")
    if err := s.Serve(lis); err != nil {
        log.Fatalf("failed to serve: %v", err)
    }
}
```

#### مثال Client

```go
import (
    userpb "git.mtnirancell.ir/digital/yelloadwise/services/contracts/user"
    "google.golang.org/grpc"
    "google.golang.org/grpc/credentials/insecure"
)

conn, _ := grpc.Dial("localhost:50052", grpc.WithTransportCredentials(insecure.NewCredentials()))
client := userpb.NewUserServiceClient(conn)

req := &userpb.GetUserByIDRequest{UserId: 123}
resp, err := client.GetUserByID(ctx, req)
if err != nil {
    log.Fatal(err)
}

log.Printf("User: %s, Email: %s", resp.Data.Profile.FirstName, resp.Data.Email)
```

## API Methods

### OutboxService

- **CreateMessage**: ایجاد یک پیام جدید در outbox
- **GetMessage**: دریافت پیام بر اساس ID
- **ListPendingMessages**: لیست پیام‌های pending
- **UpdateMessageStatus**: به‌روزرسانی وضعیت پیام
- **DeleteMessage**: حذف پیام

### UserService

- **GetUserByID**: دریافت اطلاعات کاربر بر اساس ID

### Enums

#### MessageStatus (Outbox)
- `MESSAGE_STATUS_UNSPECIFIED`: وضعیت نامشخص
- `MESSAGE_STATUS_PENDING`: در انتظار انتشار
- `MESSAGE_STATUS_PUBLISHED`: منتشر شده
- `MESSAGE_STATUS_FAILED`: ناموفق

#### StatusTypeUser (User)
- `STATUS_TYPE_USER_UNSPECIFIED`: وضعیت نامشخص
- `STATUS_TYPE_USER_ACTIVE`: فعال
- `STATUS_TYPE_USER_INACTIVE`: غیرفعال
- `STATUS_TYPE_USER_SUSPENDED`: تعلیق شده
- `STATUS_TYPE_USER_DELETED`: حذف شده

## ساختار پروژه

```
contracts/
├── go.mod
├── go.sum
├── Makefile
├── README.md
├── proto/                    # فایل‌های protobuf
│   ├── outbox/
│   │   └── outbox.proto
│   └── user/
│       └── user.proto
└── contract/                 # فایل‌های Go تولید شده
    ├── outbox/
    │   ├── outbox.pb.go          # (generated)
    │   └── outbox_grpc.pb.go     # (generated)
    └── user/
        ├── user.pb.go            # (generated)
        └── user_grpc.pb.go       # (generated)
```

## دستورات Makefile

- `make proto`: تولید فایل‌های Go از تمام فایل‌های protobuf
- `make clean`: پاک کردن تمام فایل‌های تولید شده
- `make deps`: نصب وابستگی‌ها و پلاگین‌ها
- `make tidy`: مرتب کردن go.mod

## License

[Your License Here]
