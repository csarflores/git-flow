@echo off
chcp 65001 >nul
REM Git Flow CLI - Windows Installer
REM Automates all manual installation steps

echo.
echo  ╔══════════════════════════════════════════════════════════════╗
echo  ║               Git Flow CLI - Windows Installer               ║
echo  ╚══════════════════════════════════════════════════════════════╝
echo.

set "USER_HOME=%USERPROFILE%"
set "BIN_DIR=%USER_HOME%\bin"
set "PROJECT_DIR=%~dp0"
set "BASHRC=%USER_HOME%\.bashrc"

REM Find bash.exe in common Git for Windows locations
set "BASH_CMD=bash"
if not exist "%BASH_CMD%" (
    if exist "C:\Program Files\Git\bin\bash.exe" set "BASH_CMD=C:\Program Files\Git\bin\bash.exe"
)
if not exist "%BASH_CMD%" (
    if exist "C:\Program Files (x86)\Git\bin\bash.exe" set "BASH_CMD=C:\Program Files (x86)\Git\bin\bash.exe"
)
if not exist "%BASH_CMD%" (
    if exist "%USER_HOME%\AppData\Local\Programs\Git\bin\bash.exe" set "BASH_CMD=%USER_HOME%\AppData\Local\Programs\Git\bin\bash.exe"
)
if not exist "%BASH_CMD%" (
    if exist "%USER_HOME%\AppData\Local\Programs\Git\cmd\bash.exe" set "BASH_CMD=%USER_HOME%\AppData\Local\Programs\Git\cmd\bash.exe"
)

echo [INFO] Installing Git Flow CLI to %BIN_DIR%
echo.

REM Step 1: Create bin directory
if not exist "%BIN_DIR%" (
    echo [INFO] Creating %BIN_DIR% directory
    mkdir "%BIN_DIR%"
) else (
    echo [INFO] %BIN_DIR% already exists
)

REM Step 2: Copy main files
echo [INFO] Copying git-flow CLI files
copy /Y "%PROJECT_DIR%git-flow" "%BIN_DIR%\git-flow" >nul
copy /Y "%PROJECT_DIR%git-flow-cli.sh" "%BIN_DIR%\git-flow-cli.sh" >nul
xcopy /E /I /Y "%PROJECT_DIR%lib" "%BIN_DIR%\lib" >nul

REM Step 3: Make executable in Git Bash
echo [INFO] Making scripts executable
if exist "%BIN_DIR%\git-flow-cli.sh" (
    "%BASH_CMD%" -c "chmod +x ~/bin/git-flow-cli.sh" >nul 2>&1
    "%BASH_CMD%" -c "chmod +x ~/bin/git-flow" >nul 2>&1
)

REM Step 4: Add bin directory to PATH in .bashrc
echo [INFO] Adding %BIN_DIR% to PATH
"%BASH_CMD%" -c "if ! grep -q 'export PATH=\"\$HOME/bin:\$PATH\"' ~/.bashrc 2>/dev/null; then echo 'export PATH=\"\$HOME/bin:\$PATH\"' >> ~/.bashrc; echo '[INFO] Added to PATH'; else echo '[INFO] Already in PATH'; fi" >nul 2>&1

REM Step 5: Configure Git aliases
echo [INFO] Configuring Git aliases
git config --global alias.crear-feature "!f() { if [ -z \"\$1\" ]; then echo '⚠️ Uso: git crear-feature <nombre>'; exit 1; fi; git-flow-cli.sh crear feature \"\$1\"; }; f"
git config --global alias.crear-fix "!f() { if [ -z \"\$1\" ]; then echo '⚠️ Uso: git crear-fix <nombre>'; exit 1; fi; git-flow-cli.sh crear fix \"\$1\"; }; f"
git config --global alias.crear-release "!f() { if [ -z \"\$1\" ]; then echo '⚠️ Uso: git crear-release <version>'; exit 1; fi; git-flow-cli.sh crear release \"\$1\"; }; f"
git config --global alias.crear-hotfix "!f() { if [ -z \"\$1\" ]; then echo '⚠️ Uso: git crear-hotfix <nombre>'; exit 1; fi; git-flow-cli.sh crear hotfix \"\$1\"; }; f"
git config --global alias.cerrar "!f() { if [ -n \"\$1\" ]; then git-flow-cli.sh cerrar \"\$1\"; else git-flow-cli.sh cerrar; fi; }; f"
git config --global alias.deploy "!f() { if [ -n \"\$1\" ]; then git-flow-cli.sh deploy \"\$1\"; else git-flow-cli.sh deploy; fi; }; f"
git config --global alias.sync "!git-flow-cli.sh sync"
git config --global alias.status-flow "!git-flow-cli.sh status"
git config --global alias.help-flow "!git-flow-cli.sh help"
git config --global alias.init-flow "!git-flow-cli.sh init"

echo.
echo  ╔══════════════════════════════════════════════════════════════╗
echo  ║             Installation completed successfully!             ║
echo  ╚══════════════════════════════════════════════════════════════╝
echo.
echo [INFO] Please restart your Git Bash terminal
echo [INFO] Available commands after restart:
echo        git crear-feature ^<nombre^>
echo        git crear-fix ^<nombre^>
echo        git crear-release ^<version^>
echo        git crear-hotfix ^<nombre^>
echo        git cerrar ^<mensaje^>
echo        git deploy ^<mensaje^>
echo        git sync
echo        git status-flow
echo        git help-flow
echo        git init-flow
echo.
pause
