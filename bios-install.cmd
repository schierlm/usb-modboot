@echo off
cd /D %~dp0
for /f "usebackq" %%i in (`grub-probe -t disk %~f0`) do set DISK=%%i
set LETTER=%~d0
cls
echo Install GRUB for USB-ModBoot to drive %LETTER% (device %DISK%).
echo.
choice /M "Are you sure"
if not %ERRORLEVEL% == 1 exit
echo Installing...
grub-bios-setup -d . %DISK%
echo Done.
pause
