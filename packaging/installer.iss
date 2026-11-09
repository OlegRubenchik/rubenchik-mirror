; Rubenchik Mirror installer (Inno Setup 6.3+). Built in CI: iscc /DAppVersion=1.0.0 packaging\installer.iss
#ifndef AppVersion
  #define AppVersion "0.0.0-dev"
#endif
#ifndef AppDir
  #define AppDir "..\dist\app"
#endif
#define AppName "Rubenchik Mirror"
#define AppExe "bin\uxplay.exe"
#define FwRule "Rubenchik Mirror"

[Setup]
AppId={{6F1D2A7B-3C54-4E0A-9B8E-5D7A1C42F9E3}
AppName={#AppName}
AppVersion={#AppVersion}
AppVerName={#AppName} {#AppVersion}
AppPublisher=Oleg Rubenchik
AppPublisherURL=https://github.com/OlegRubenchik/rubenchik-mirror
AppSupportURL=https://github.com/OlegRubenchik/rubenchik-mirror/issues
AppUpdatesURL=https://github.com/OlegRubenchik/rubenchik-mirror/releases
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
DisableProgramGroupPage=yes
OutputDir=..\dist
OutputBaseFilename=RubenchikMirror-Setup
SetupIconFile=icon.ico
UninstallDisplayIcon={app}\icon.ico
UninstallDisplayName={#AppName}
WizardStyle=modern
WizardImageFile=wizard-large.bmp
WizardSmallImageFile=wizard-small.bmp
LicenseFile=..\LICENSE
Compression=lzma2/ultra64
SolidCompression=yes
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
PrivilegesRequired=admin
MinVersion=10.0

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create a &desktop shortcut"; GroupDescription: "Shortcuts:"
Name: "autostart"; Description: "Start {#AppName} automatically when Windows starts"; GroupDescription: "Startup:"; Flags: unchecked
Name: "pin"; Description: "Require a PIN code on the iPhone before mirroring (recommended)"; GroupDescription: "Security:"

[Files]
Source: "{#AppDir}\bin\*"; DestDir: "{app}\bin"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#AppDir}\lib\*"; DestDir: "{app}\lib"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#AppDir}\libexec\*"; DestDir: "{app}\libexec"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#AppDir}\share\*"; DestDir: "{app}\share"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#AppDir}\etc\*"; DestDir: "{app}\etc"; Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "{#AppDir}\licenses\*"; DestDir: "{app}\licenses"; Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "uxplayrc.pin"; DestDir: "{app}"; DestName: "uxplayrc"; Flags: ignoreversion; Tasks: pin
Source: "uxplayrc"; DestDir: "{app}"; DestName: "uxplayrc"; Flags: ignoreversion; Tasks: not pin
Source: "icon.ico"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\assets\idle-logo.bmp"; DestDir: "{app}\assets"; Flags: ignoreversion
Source: "..\LICENSE"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\THIRD_PARTY_NOTICES.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\README.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#AppDir}\UxPlay-LICENSE.txt"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{autoprograms}\{#AppName}"; Filename: "{app}\{#AppExe}"; Parameters: "-rc ""{app}\uxplayrc"""; WorkingDir: "{app}\bin"; IconFilename: "{app}\icon.ico"; Comment: "AirPlay screen mirroring receiver"
Name: "{autoprograms}\Edit {#AppName} settings"; Filename: "{win}\notepad.exe"; Parameters: """{app}\uxplayrc"""; IconFilename: "{app}\icon.ico"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExe}"; Parameters: "-rc ""{app}\uxplayrc"""; WorkingDir: "{app}\bin"; IconFilename: "{app}\icon.ico"; Tasks: desktopicon
Name: "{commonstartup}\{#AppName}"; Filename: "{app}\{#AppExe}"; Parameters: "-rc ""{app}\uxplayrc"""; WorkingDir: "{app}\bin"; IconFilename: "{app}\icon.ico"; Tasks: autostart; Flags: runminimized

[Run]
; Remove any stale rule first, then allow uxplay.exe inbound on private networks.
Filename: "{sys}\netsh.exe"; Parameters: "advfirewall firewall delete rule name=""{#FwRule}"""; Flags: runhidden; StatusMsg: "Configuring Windows Firewall..."
Filename: "{sys}\netsh.exe"; Parameters: "advfirewall firewall add rule name=""{#FwRule}"" dir=in action=allow program=""{app}\{#AppExe}"" enable=yes profile=private"; Flags: runhidden; StatusMsg: "Configuring Windows Firewall..."
Filename: "{app}\{#AppExe}"; Parameters: "-rc ""{app}\uxplayrc"""; WorkingDir: "{app}\bin"; Description: "Start {#AppName} now"; Flags: nowait postinstall skipifsilent

[UninstallRun]
Filename: "{sys}\netsh.exe"; Parameters: "advfirewall firewall delete rule name=""{#FwRule}"""; Flags: runhidden; RunOnceId: "DelFirewallRule"

[UninstallDelete]
Type: filesandordirs; Name: "{app}"
Type: filesandordirs; Name: "{localappdata}\gstreamer-1.0"

[Code]
procedure StopRunningInstance();
var
  rc: Integer;
begin
  Exec(ExpandConstant('{sys}\taskkill.exe'), '/F /IM uxplay.exe', '', SW_HIDE, ewWaitUntilTerminated, rc);
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
begin
  StopRunningInstance();
  Result := '';
end;

function InitializeUninstall(): Boolean;
begin
  StopRunningInstance();
  Result := True;
end;
