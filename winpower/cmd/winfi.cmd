
@echo off

set "a=%*"
powershell -File "c:/winpower/ps/wp.ps1" "winfi" %a%
