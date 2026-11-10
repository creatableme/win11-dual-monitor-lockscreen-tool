# Windows 11 双屏锁屏壁纸

**Windows 11 Dual-Monitor Lock Screen Wallpaper** · [English](README.en.md)

让 Windows 11 在扩展显示模式下，从刚锁屏到呼出密码输入界面，主屏和副屏都能显示锁屏壁纸。副屏按自己的屏幕比例铺满，保留 Windows 原生锁屏与登录流程。

## 两个锁屏阶段

| 阶段 | 副屏由谁绘制 | 壁纸设置 |
| --- | --- | --- |
| 刚锁屏，主屏显示时钟 | [Microzello 的 Lock Screen Wallpaper](https://github.com/Microzello/win11-lockscreen-wallpaper) | 使用原图，程序居中裁切并铺满 |
| 呼出 Windows 密码或 PIN 输入界面 | [VoidVolker 的 LockScreen](https://github.com/VoidVolker/LockScreen) | 使用预先裁成副屏比例的副本，消除等比缩放产生的黑边 |

此组合在 Windows 11 25H2 的 16∶9 主屏和 16∶10 副屏上实测通过，测试时用 .NET 9 本地编译了 Microzello 的源码。其他系统版本、显示组合和登录策略需要现场验证。

## 配置

1. 在 Windows「设置 → 系统 → 显示」中选择「扩展这些显示器」，并在「个性化 → 锁屏界面」为主屏选图。
2. 从 [VoidVolker 的发布页](https://github.com/VoidVolker/LockScreen/releases/tag/1.0.1.993) 安装对应架构的版本。该版本使用 .NET 9 Desktop Runtime。打开 LockScreen 设置，确认 Logon Service 正在运行。
3. 按 [Microzello 的安装说明](https://github.com/Microzello/win11-lockscreen-wallpaper#install) 从源码构建并安装。上游流程需要 .NET 8 SDK，并为 UIAccess 添加本机代码签名证书。请先阅读上游的[安全说明](https://github.com/Microzello/win11-lockscreen-wallpaper#security-considerations)。在托盘菜单设置原图，并勾选 **Start with Windows**。
4. 在 PowerShell 中运行下面的命令。脚本会自动识别单个副屏的分辨率，把原图居中裁切成副屏尺寸并保存为新的 PNG。

   ~~~powershell
   .\Export-FittedWallpaper.ps1 -InputPath .\wallpaper.png -OutputPath .\wallpaper-filled.png
   ~~~

   如果连接了多个副屏，可以用 **DisplayName** 选中目标显示器，或用 **Width** 和 **Height** 指定尺寸。

   ~~~powershell
   .\Export-FittedWallpaper.ps1 -InputPath .\wallpaper.png -OutputPath .\wallpaper-filled.png -Width 2560 -Height 1600
   ~~~

5. 在 VoidVolker 的 LockScreen 中把生成的 PNG 设为副屏壁纸。请把原图和生成的 PNG 放在两款程序都能读取的本地目录。设置好后，按 **Win+L** 检查刚锁屏的画面，再按空格呼出登录界面，确认两个阶段的副屏都铺满。

如果锁屏后显示器过一会儿熄灭，请另外检查 Windows 当前电源计划的锁屏显示关闭超时。壁纸适配脚本只生成图像文件。

## 卸载

1. 在 Microzello 的托盘菜单取消 **Start with Windows**，再用上游的 [uninstall.cmd](https://github.com/Microzello/win11-lockscreen-wallpaper/blob/master/uninstall.cmd) 卸载程序和对应的本机签名证书。
2. 从 Windows「已安装的应用」卸载 VoidVolker LockScreen，或使用它自带的卸载程序。

本仓库提供配置指南和适配脚本。两个上游项目分别维护，各自采用 MIT 许可证。
