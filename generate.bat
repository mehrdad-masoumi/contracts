@echo off
setlocal
set PROTOC_BIN=
set INCLUDE_ARGS=--proto_path=proto
set PROTO_FILES=proto\outbox\v1\outbox.proto proto\adinfo\v1\adinfo.proto
if "%PROTOC_GEN_GO_VERSION%"=="" set PROTOC_GEN_GO_VERSION=v1.33.0
if "%PROTOC_GEN_GO_GRPC_VERSION%"=="" set PROTOC_GEN_GO_GRPC_VERSION=v1.4.0

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

where protoc-gen-go >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Warning: protoc-gen-go not found. Installing...
    go install google.golang.org/protobuf/cmd/protoc-gen-go@%PROTOC_GEN_GO_VERSION%
)

where protoc-gen-go-grpc >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Warning: protoc-gen-go-grpc not found. Installing...
    go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@%PROTOC_GEN_GO_GRPC_VERSION%
)

if exist "%~dp0tools\protoc\include" (
    set INCLUDE_ARGS=%INCLUDE_ARGS% --proto_path=tools\protoc\include
)

"%PROTOC_BIN%" --go_out=contract --go_opt=paths=source_relative --go-grpc_out=contract --go-grpc_opt=paths=source_relative %INCLUDE_ARGS% %PROTO_FILES%

if %ERRORLEVEL% EQU 0 (
    echo Successfully generated Go files!
    echo Generated folders:
    dir /s /b /ad contract
) else (
    echo Error: Failed to generate Go files
    exit /b 1
)

endlocal
