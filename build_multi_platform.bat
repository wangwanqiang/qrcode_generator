@echo off
setlocal

echo ========== 开始跨平台编译二维码生成程序 ==========

go mod init

:: 确保当前目录有 go.mod 文件
if not exist go.mod (
    echo 错误: 当前目录缺少 go.mod 文件，请先执行 go mod init
    goto :end
)

:: 清理旧文件
if exist bin (
    rmdir /s /q bin
)
mkdir bin

:: 编译 Windows 64位版本
echo 正在编译 Windows 64位版本...
set GOOS=windows
set GOARCH=amd64
go build -ldflags="-w -s" -o bin/qrcode_generator_windows_amd64.exe .\main.go
if errorlevel 1 goto :compile_error

:: 编译 Linux 64位版本
echo 正在编译 Linux 64位版本...
set GOOS=linux
set GOARCH=amd64
go build -ldflags="-w -s" -o bin/qrcode_generator_linux_amd64 .\main.go
if errorlevel 1 goto :compile_error

:: 编译 ARM 32位版本 (ARMv7)
echo 正在编译 ARM 32位版本...
set GOOS=linux
set GOARCH=arm
set GOARM=7
go build -ldflags="-w -s" -o bin/qrcode_generator_armv7 .\main.go
if errorlevel 1 goto :compile_error

:: 编译 ARM 64位版本 (AARCH64)
echo 正在编译 ARM 64位版本...
set GOOS=linux
set GOARCH=arm64
go build -ldflags="-w -s" -o bin/qrcode_generator_arm64 .\main.go
if errorlevel 1 goto :compile_error

echo ========== 编译完成 ==========
echo 生成的文件位于 bin 目录下:
dir bin\*qrcode* /b
goto :end

:compile_error
echo 编译过程中出现错误，请检查上述日志
:end

:: 恢复环境变量
set GOOS=
set GOARCH=
set GOARM=
endlocal