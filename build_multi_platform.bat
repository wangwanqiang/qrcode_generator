@echo off
setlocal

echo ========== ��ʼ��ƽ̨�����ά�����ɳ��� ==========

go mod init

:: ȷ����ǰĿ¼�� go.mod �ļ�
if not exist go.mod (
    echo ����: ��ǰĿ¼ȱ�� go.mod �ļ�������ִ�� go mod init
    goto :end
)

:: ������ļ�
if exist bin (
    rmdir /s /q bin
)
mkdir bin

:: ���� Windows 64λ�汾
echo ���ڱ��� Windows 64λ�汾...
set GOOS=windows
set GOARCH=amd64
go build -ldflags="-w -s" -o bin/qrcode_generator_windows_amd64.exe .\main.go
if errorlevel 1 goto :compile_error

:: ���� Linux 64λ�汾
echo ���ڱ��� Linux 64λ�汾...
set GOOS=linux
set GOARCH=amd64
go build -ldflags="-w -s" -o bin/qrcode_generator_linux_amd64 .\main.go
if errorlevel 1 goto :compile_error

:: ���� ARM 32λ�汾 (ARMv7)
echo ���ڱ��� ARM 32λ�汾...
set GOOS=linux
set GOARCH=arm
set GOARM=7
go build -ldflags="-w -s" -o bin/qrcode_generator_armv7 .\main.go
if errorlevel 1 goto :compile_error

:: ���� ARM 64λ�汾 (AARCH64)
echo ���ڱ��� ARM 64λ�汾...
set GOOS=linux
set GOARCH=arm64
go build -ldflags="-w -s" -o bin/qrcode_generator_arm64 .\main.go
if errorlevel 1 goto :compile_error

echo ========== ������� ==========
echo ���ɵ��ļ�λ�� bin Ŀ¼��:
dir bin\*qrcode* /b
goto :end

:compile_error
echo ��������г��ִ�������������־
:end

:: �ָ���������
set GOOS=
set GOARCH=
set GOARM=
endlocal