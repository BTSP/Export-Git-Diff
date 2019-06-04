@echo off
set /p input1=Export Start Commit ID:
set commitIdStart=%input1%
set /p input2=Export End Commit ID:
if [%input2%] == [] (set commitIdEnd=HEAD) else (set commitIdEnd=%input2%)
set /p input3=Export Desternation Folder name:
if [%input3%] == [] (set Folder=FileDiff) else (set Folder=%input3%)
echo Start ID = %commitIdStart%
echo End ID = %commitIdEnd%
echo Export Desternation Folder = %Folder%

for /f "tokens=2,*" %%i in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "Desktop"') do set "desktop_dir=%%j"
echo Desktop Path = %desktop_dir%

@rem Get now HEAD point location
for /f "tokens=1,2,*" %%i in ('cat .git/HEAD') do (set "Branch_Loc_now_1=%%i" && set "Branch_Loc_now_2=%%j")
echo Now HEAD location = %Branch_Loc_now_1% %Branch_Loc_now_2%

@rem echo Split string %Branch_Loc_now_2%
if /I "%Branch_Loc_now_1:~0,3%" == "ref" (
	:Split
	for /f "tokens=1,* delims=/" %%i in ("%Branch_Loc_now_2%") do (set "HEAD_Restore=%%i" && set "Branch_Loc_now_2= %%j")
	if "%Branch_Loc_now_2:~3%" NEQ ""  goto Split
	echo On One of Branchs: %HEAD_Restore%
	) else (set HEAD_Restore=%Branch_Loc_now_1% && echo On One of commits)

@rem switch code base to first commit 
call git checkout %commitIdStart%
for /f "tokens=1,*" %%i in ('cat .git/HEAD') do set "Branch_ID=%%i"
echo Checkout to  = %Branch_ID%

for /f "usebackq tokens=*" %%A in (`git diff-tree -r --no-commit-id --name-only --diff-filter=ACMRT %commitIdStart% %commitIdEnd%`) do echo FA|xcopy "%%~fA" "%desktop_dir%/%Folder%/%commitIdStart%/%%A"

@rem Delay 200ms for git responce time
timeout /t 1 /nowbreak

@rem switch to code base to second commit
call git checkout %commitIdEnd%
for /f "tokens=1,*" %%i in ('cat .git/HEAD') do set "Branch_ID=%%i"
echo Checkout to  = %Branch_ID%

for /f "usebackq tokens=*" %%A in (`git diff-tree -r --no-commit-id --name-only --diff-filter=ACMRT %commitIdStart% %commitIdEnd%`) do echo FA|xcopy "%%~fA" "%desktop_dir%/%Folder%/%commitIdEnd%/%%A"

@rem reset HEAD point back to before executing tool
call git checkout %HEAD_Restore%

:End
set /p DUMMY = Hit Enter To Continue...