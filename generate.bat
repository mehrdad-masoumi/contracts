@echo off
setlocal
set PROTOC_BIN=

echo Generating Go files from protobuf...

where protoc >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    for /f "delims=" %%i in ('where protoc') do (
        set PROTOC_BIN=%%i
        goto :found_protoc
    )
)

if exist "%~dp0tools\protoc\bin\protoc.exe" (
    set PROTOC_BIN=%~dp0tools\protoc\bin\protoc.exe
    goto :found_protoc
)

echo Error: protoc is not installed or not in PATH
echo.
echo Please install protoc:
echo   Download from: https://github.com/protocolbuffers/protobuf/releases
echo   Or install via: choco install protoc
echo   Or install via: scoop install protobuf
echo.
echo After installation, make sure protoc is in your PATH or placed in tools\protoc\bin
exit /b 1

:found_protoc
echo Using protoc: %PROTOC_BIN%

"%PROTOC_BIN%" --go_out=contract --go_opt=paths=source_relative --go-grpc_out=contract --go-grpc_opt=paths=source_relative --proto_path=proto --proto_path=tools\protoc\include proto\outbox\outbox.proto proto\user\user.proto

if %ERRORLEVEL% EQU 0 (
    echo Successfully generated Go files!
    echo   - contract\outbox\outbox.pb.go
    echo   - contract\outbox\outbox_grpc.pb.go
    echo   - contract\user\user.pb.go
    echo   - contract\user\user_grpc.pb.go
) else (
    echo Error: Failed to generate Go files
    exit /b 1
)

endlocal
