; ==============================================================
;  So Novel 安装包脚本 (Inno Setup)
;  产物: 一个可在 Windows 11 上双击安装的 setup.exe
;  PostgreSQL/服务均不涉及, 纯文件安装 + 快捷方式, 无需管理员权限
; ==============================================================

#define AppName        "So Novel"
#define AppVersion     "1.12.0"
#define AppPublisher   "freeok (upstream) / 本地隐私加固分支"
#define AppExe         "sonovel-launch.cmd"

[Setup]
AppId={{8E4C1B77-2F4A-4C1D-9B2E-7A3D5F0C9E21}
AppName={#AppName}
AppVersion={#AppVersion}
AppVerName={#AppName} {#AppVersion}
AppPublisher={#AppPublisher}
DefaultDirName={autopf}\SoNovel
DefaultGroupName={#AppName}
DisableProgramGroupPage=yes
; 装到用户目录, 不需要管理员权限, 避免 UAC 弹窗
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
OutputDir=dist
OutputBaseFilename=Sonovel-Setup-{#AppVersion}-win11-x64
SetupIconFile=assets\logo.ico
UninstallDisplayIcon={app}\sonovel.exe
UninstallDisplayName={#AppName}
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
; 64 位程序, 关闭 32 位安装模式
MinVersion=10.0

[Languages]
Name: "chs"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "创建桌面快捷方式"; GroupDescription: "附加任务:"; Flags: checkedonce
Name: "enableweb";   Description: "启用 Web 界面 (浏览器访问 localhost:7765)"; GroupDescription: "功能选项:"; Flags: unchecked

[Files]
; 主体文件全部来自 target\SoNovel
Source: "target\SoNovel\sonovel.exe";        DestDir: "{app}"; Flags: ignoreversion
Source: "target\SoNovel\sonovel-launch.cmd"; DestDir: "{app}"; Flags: ignoreversion
Source: "target\SoNovel\app.jar";            DestDir: "{app}"; Flags: ignoreversion
Source: "target\SoNovel\sonovel.l4j.ini";    DestDir: "{app}"; Flags: ignoreversion
Source: "target\SoNovel\readme.txt";         DestDir: "{app}"; Flags: ignoreversion
Source: "target\SoNovel\DISCLAIMER.md";      DestDir: "{app}"; Flags: ignoreversion
Source: "target\SoNovel\CHANGELOG_ALL.md";   DestDir: "{app}"; Flags: ignoreversion
; 配置: 仅在不存在时安装, 升级时不覆盖用户已改的配置
Source: "target\SoNovel\config.ini";         DestDir: "{app}"; Flags: onlyifdoesntexist uninsneveruninstall
; 内置 JRE
Source: "target\SoNovel\runtime\*";          DestDir: "{app}\runtime"; Flags: ignoreversion recursesubdirs createallsubdirs
; 书源规则
Source: "target\SoNovel\rules\*";            DestDir: "{app}\rules"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#AppName}";              Filename: "{app}\{#AppExe}"; WorkingDir: "{app}"; IconFilename: "{app}\sonovel.exe"
Name: "{group}\卸载 {#AppName}";         Filename: "{uninstallexe}"
Name: "{autodesktop}\{#AppName}";        Filename: "{app}\{#AppExe}"; WorkingDir: "{app}"; IconFilename: "{app}\sonovel.exe"; Tasks: desktopicon

[Run]
; 勾选"启用 Web 界面"时, 安装完直接把配置改好
Filename: "powershell.exe"; \
  Parameters: "-NoProfile -ExecutionPolicy Bypass -Command ""$p='{app}\config.ini'; (Get-Content -Raw -Encoding UTF8 $p) -replace 'enabled = 0(\s*\r?\nport = 7765)','enabled = 1$1' | Set-Content -Encoding UTF8 $p"""; \
  Flags: runhidden waituntilterminated; Tasks: enableweb
; 安装完可选启动
Filename: "{app}\{#AppExe}"; Description: "立即运行 {#AppName}"; Flags: postinstall nowait skipifsilent

[UninstallDelete]
; 清理运行时产生的下载目录(仅当为空时不报错)
Type: dirifempty; Name: "{app}\downloads"

[Messages]
chs.WelcomeLabel2=即将在您的电脑上安装 [name/ver]。%n%n这是一个**已移除设备信息上报**的本地构建版本：原版启动时会向作者服务器发送本机用户名、计算机名、MAC 地址与内网 IP，本版本已整体删除该功能。%n%n程序完全免费，无需联网激活。
