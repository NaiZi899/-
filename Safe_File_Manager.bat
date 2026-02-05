@echo off
chcp 65001 >nul
color 07
title 终端文件提取工具_专业版

:StartLoop
setlocal enabledelayedexpansion
cls
echo ----------------------------------------------------------------------------------
echo 1 扫描当前目录
echo ----------------------------------------------------------------------------------
set "count=0"
for /d %%d in (*) do (
    set /a count+=1
    set "folder_!count!=%%d"
    echo   !count! - %%d
)

if %count% equ 0 (
    echo   当前目录下无文件夹
    goto EndMenu
)

echo.
echo ----------------------------------------------------------------------------------
echo 2 配置操作参数-后续操作存在删除行为，请谨慎操作
echo ----------------------------------------------------------------------------------

:SelectRange
set "range_mode="
set /p "range_mode=  选择范围 (1 当前目录全部文件夹 / 2 当前目录部分文件夹): "

if "%range_mode%"=="1" (
    set "index_list="
    for /l %%i in (1,1,%count%) do set "index_list=!index_list! %%i"
) else if "%range_mode%"=="2" (
    set /p "index_list=  输入序号 (用空格隔开): "
) else (
    goto SelectRange
)

:SelectAction
echo.
set "action_mode="
set /p "action_mode=  选择模式 (C 复制 / M 移动): "

if /i "!action_mode!"=="C" (
    set "is_move=0"
) else if /i "!action_mode!"=="M" (
    set "is_move=1"
) else (
    goto SelectAction
)

:SetTarget
echo.
set "target="
set /p "target=  输入目标文件夹名称: "
if "!target!"=="" goto SetTarget

echo.
echo ----------------------------------------------------------------------------------
echo 3 正在提取文件
echo ----------------------------------------------------------------------------------
if not exist "!target!" md "!target!"

for %%n in (!index_list!) do (
    set "src_folder=!folder_%%n!"
    if defined src_folder (
        set "abs_src="
        for /f "delims=" %%i in ("!src_folder!") do set "abs_src=%%~fi"
        set "abs_target="
        for /f "delims=" %%i in ("!target!") do set "abs_target=%%~fi"

        if /i "!abs_src!" neq "!abs_target!" (
            for /f "tokens=*" %%f in ('dir "!abs_src!" /s /b /a-d 2^>nul') do (
                copy /y "%%f" "!abs_target!\" >nul
            )
            
            if !errorlevel! leq 1 (
                if "!is_move!"=="1" (
                    rd /s /q "!abs_src!"
                    echo   OK - !src_folder! 已移动
                ) else (
                    echo   OK - !src_folder! 已复制
                )
            ) else (
                echo   FAIL - !src_folder! 出现错误
            )
        )
    )
)

:EndMenu
echo.
echo ----------------------------------------------------
echo 1 继续操作
echo 2 退出系统
set "next_step="
set /p "next_step=  请输入选项: "

if "%next_step%"=="1" (
    endlocal
    goto StartLoop
)
if "%next_step%"=="2" (
    endlocal
    exit
)
goto EndMenu