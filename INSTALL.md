# راهنمای نصب Protoc

برای تولید فایل‌های Go از فایل‌های protobuf، باید `protoc` (Protocol Buffer Compiler) را نصب کنید.

## روش‌های نصب در Windows

### روش 1: استفاده از Chocolatey (توصیه می‌شود)

```bash
choco install protoc
```

### روش 2: استفاده از Scoop

```bash
scoop install protobuf
```

### روش 3: دانلود دستی

1. به [صفحه releases protobuf](https://github.com/protocolbuffers/protobuf/releases) بروید
2. آخرین نسخه `protoc-XX.X-win64.zip` را دانلود کنید
3. فایل را extract کنید
4. پوشه `bin` را به PATH اضافه کنید:
   - به System Properties > Environment Variables بروید
   - در System Variables، `Path` را پیدا کنید
   - Edit کنید و مسیر `bin` را اضافه کنید
   - مثال: `C:\protoc\bin`

### روش 4: استفاده از Git Bash (MINGW64)

اگر از Git Bash استفاده می‌کنید:

```bash
# دانلود و نصب در مسیر محلی
mkdir -p ~/tools
cd ~/tools
wget https://github.com/protocolbuffers/protobuf/releases/download/v25.1/protoc-25.1-win64.zip
unzip protoc-25.1-win64.zip

# اضافه کردن به PATH در ~/.bashrc
echo 'export PATH="$HOME/tools/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

## نصب پلاگین‌های Go

بعد از نصب `protoc`، پلاگین‌های Go را نصب کنید:

```bash
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
```

**مهم**: مطمئن شوید که `$GOPATH/bin` یا `$HOME/go/bin` در PATH شما است.

## بررسی نصب

بعد از نصب، ترمینال را بسته و دوباره باز کنید، سپس:

```bash
protoc --version
```

باید نسخه protoc نمایش داده شود.

## تولید فایل‌های Go

بعد از نصب، می‌توانید فایل‌های Go را تولید کنید:

```bash
# در Git Bash
./generate.sh

# یا در PowerShell
.\generate.bat

# یا با make
make proto
```

## عیب‌یابی

### خطا: `protoc: command not found`

- مطمئن شوید `protoc` در PATH است
- ترمینال را بسته و دوباره باز کنید
- در Git Bash، `which protoc` را اجرا کنید تا مسیر را ببینید

### خطا: `protoc-gen-go: program not found`

- `go install google.golang.org/protobuf/cmd/protoc-gen-go@latest` را اجرا کنید
- مطمئن شوید `$GOPATH/bin` در PATH است

### خطا: `protoc-gen-go-grpc: program not found`

- `go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest` را اجرا کنید
- مطمئن شوید `$GOPATH/bin` در PATH است

