@echo off
setlocal enabledelayedexpansion
set "TEST_DIR=test_output"
set "LOGO_FILE=logo.png"
set "TEST_URL=https://mindray.com"
set "TEST_TEXT=Hello,World!Hello,123456123456123456123456123456123456123456123456123456123456123456123456123456123456123456123456123456123456123456123456123456123456123456123456123456123456123456123456123456123456"

echo ========== ��ʼ���Զ�ά�����ɳ��� ==========

:: �����������Ŀ¼
if exist %TEST_DIR% (
    rmdir /s /q %TEST_DIR%
)
mkdir %TEST_DIR%

:: ����1: �������ܲ���
echo ����1: �������ܲ���...
go run .\main.go -text %TEST_URL% -output %TEST_DIR%\basic.png
if errorlevel 1 (
    echo ����1ʧ��!
    goto :test_failed
) else (
    echo ����1ͨ��!
)

:: ����2: ��Logo�Ķ�ά��
echo ����2: ��Logo�Ķ�ά��...
if exist %LOGO_FILE% (
    go run .\main.go -text %TEST_TEXT% -logo %LOGO_FILE% -logo-size 100 -output %TEST_DIR%\with_logo.png
    if errorlevel 1 (
        echo ����2ʧ��!
        goto :test_failed
    ) else (
        echo ����2ͨ��!
    )
) else (
    echo ����: �Ҳ���Logo�ļ�����������2
)

:: ����3: �Զ���߾�
echo ����3: �Զ���߾�...
go run .\main.go -text %TEST_URL% -border 10 -output %TEST_DIR%\with_border.png
if errorlevel 1 (
    echo ����3ʧ��!
    goto :test_failed
) else (
    echo ����3ͨ��!
)

:: ����4: �Զ���ߴ�
echo ����4: �Զ���ߴ�...
go run .\main.go -text %TEST_URL% -size 512 -output %TEST_DIR%\large_size.png
if errorlevel 1 (
    echo ����4ʧ��!
    goto :test_failed
) else (
    echo ����4ͨ��!
)

:: ����5: ��Logo���Զ���߾�
echo ����5: ��Logo���Զ���߾�...
if exist %LOGO_FILE% (
    go run .\main.go -text %TEST_URL% -logo %LOGO_FILE% -border 1 -output %TEST_DIR%\logo_border.png
    if errorlevel 1 (
        echo ����5ʧ��!
        goto :test_failed
    ) else (
        echo ����5ͨ��!
    )
) else (
    echo ����: �Ҳ���Logo�ļ�����������5
)

:: ����6: ������ - ȱ���ı�����
echo ����6: ������ - ȱ���ı�����...
go run .\main.go -output %TEST_DIR%\error.png > %TEST_DIR%\error.log 2>&1
if errorlevel 0 (
    echo ����6ʧ��! ����Ӧ�þܾ�ȱ�ٱ�����������
    goto :test_failed
) else (
    echo ����6ͨ��!
)

echo ========== ���в������! ==========
echo ���Խ��: ͨ��
echo �������������: %TEST_DIR%
goto :end

:test_failed
echo ========== ����ʧ��! ==========
echo ��������Ĵ�����Ϣ
exit /b 1

:end
endlocal