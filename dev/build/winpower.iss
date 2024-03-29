; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "WinPower"
#define MyAppPublisher "RootData21"
#define MyAppURL "https://abdulahad.net/winpower"

[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{55049D15-C6FB-453F-9CFB-79659899A6D9}
AppName={#MyAppName}
AppVersion={#version}
AppVerName={#MyAppName} {#version}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName=c:\winpower
DisableDirPage=yes
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
InfoBeforeFile=C:\winpower_dev\dev\build\asset\pre_install_dialog_notice.txt
InfoAfterFile=C:\winpower_dev\dev\build\asset\post_install_dialog_notice.txt
PrivilegesRequired=lowest
OutputDir=C:\winpower_dev\download\installer
OutputBaseFilename={#MyAppName}_{#version}
SetupIconFile=C:\winpower_dev\dev\build\asset\winpower.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern
UninstallDisplayIcon=C:\winpower_dev\dev\build\asset\winpower.ico

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "C:\winpower_dev\winpower\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Code]
procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  ResultCode: Integer;
begin
  if CurUninstallStep = usUninstall then
  begin
    ShellExec('', ExpandConstant('{cmd}'), '/C piyon -r "c:\winpower\cmd"', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
    Exec('powershell.exe', '-Command Set-Location c:/winpower; . "lib/func.ps1"; removeWPPref', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  end;
end;

function NextButtonClick(CurPage: Integer): Boolean;
var
  ResultCode: Integer;
begin
  Result := True;

  if CurPage = wpFinished then
  begin
    Exec('powershell.exe', '-Command Set-ExecutionPolicy ByPass CurrentUser -Force', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
    if ShellExec('', ExpandConstant('{cmd}'), '/C C:\winpower\cmd\wp.cmd wp_setup y', '', SW_SHOW, ewWaitUntilTerminated, ResultCode) then
    begin
      if ResultCode <> 0 then
      begin
        MsgBox('Command execution failed with exit code: ' + IntToStr(ResultCode), mbError, MB_OK);
      end;
    end
    else
    begin
      MsgBox('Failed to execute command.', mbError, MB_OK);
    end;
  end;
end;
