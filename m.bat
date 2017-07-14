@echo off

SET code=code-insiders

echo Installing all extensions from extensions file
for /F "tokens=*" %%A in (extensions) do %code% --install-extension %%A

echo Writing all installed extensions back to extensions file
%code% --list-extensions > extensions
