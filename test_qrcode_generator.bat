@echo off
setlocal enabledelayedexpansion
set "TEST_DIR=test_output"
set "LOGO_FILE=logo.png"
set "TEST_URL=https://mindray.com"
set "TEST_TEXT=Hello,World!Hello,123456123456123456123456123456123456123456123456123456123456123456123456123456123456123456123456123456123456123456123456123456123456123456123456123456123456123456123456123456123456"

echo ========== 开始测试二维码生成程序 ==========

:: 创建测试输出目录
if exist %TEST_DIR% (
    rmdir /s /q %TEST_DIR%
)
mkdir %TEST_DIR%

:: 测试1: 基本功能测试
echo 测试1: 基本功能测试...
go run .\main.go -text %TEST_URL% -output %TEST_DIR%\basic.png
if errorlevel 1 (
    echo 测试1失败!
    goto :test_failed
) else (
    echo 测试1通过!
)

:: 测试2: 带Logo的二维码
echo 测试2: 带Logo的二维码...
if exist %LOGO_FILE% (
    go run .\main.go -text %TEST_TEXT% -logo %LOGO_FILE% -logo-size 100 -output %TEST_DIR%\with_logo.png
    if errorlevel 1 (
        echo 测试2失败!
        goto :test_failed
    ) else (
        echo 测试2通过!
    )
) else (
    echo 警告: 找不到Logo文件，跳过测试2
)

:: 测试3: 自定义边距
echo 测试3: 自定义边距...
go run .\main.go -text %TEST_URL% -border 10 -output %TEST_DIR%\with_border.png
if errorlevel 1 (
    echo 测试3失败!
    goto :test_failed
) else (
    echo 测试3通过!
)

:: 测试4: 自定义尺寸
echo 测试4: 自定义尺寸...
go run .\main.go -text %TEST_URL% -size 512 -output %TEST_DIR%\large_size.png
if errorlevel 1 (
    echo 测试4失败!
    goto :test_failed
) else (
    echo 测试4通过!
)

:: 测试5: 带Logo和自定义边距
echo 测试5: 带Logo和自定义边距...
if exist %LOGO_FILE% (
    go run .\main.go -text %TEST_URL% -logo %LOGO_FILE% -border 1 -output %TEST_DIR%\logo_border.png
    if errorlevel 1 (
        echo 测试5失败!
        goto :test_failed
    ) else (
        echo 测试5通过!
    )
) else (
    echo 警告: 找不到Logo文件，跳过测试5
)

:: 测试6: 错误处理 - 缺少文本参数
echo 测试6: 错误处理 - 缺少文本参数...
go run .\main.go -output %TEST_DIR%\error.png > %TEST_DIR%\error.log 2>&1
if errorlevel 0 (
    echo 测试6失败! 程序应该拒绝缺少必需参数的情况
    goto :test_failed
) else (
    echo 测试6通过!
)

echo ========== 所有测试完成! ==========
echo 测试结果: 通过
echo 测试输出保存在: %TEST_DIR%
goto :end

:test_failed
echo ========== 测试失败! ==========
echo 请检查上面的错误信息
exit /b 1

:end
endlocal