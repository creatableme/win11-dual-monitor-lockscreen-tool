# Windows 11 Dual-Monitor Lock Screen Wallpaper Tool

**Windows 11 双屏锁屏壁纸工具** · [简体中文](README.md)

Set up lock screen wallpaper on both monitors in Windows 11 Extend mode, from the initial lock screen to the native password or PIN prompt. The included crop helper fits wallpaper to the secondary display without stretching the image or adding black bars.

## How the two stages work

| Stage | Secondary display renderer | Wallpaper |
| --- | --- | --- |
| Initial lock screen with the clock | [Microzello's Lock Screen Wallpaper](https://github.com/Microzello/win11-lockscreen-wallpaper) | Use the original image. The app crops it to fill the screen. |
| Windows password or PIN prompt | [VoidVolker's LockScreen](https://github.com/VoidVolker/LockScreen) | Use a copy cropped to the secondary display's aspect ratio. |

The combination was tested on Windows 11 25H2 with a 16:9 primary display and a 16:10 secondary display, using a local .NET 9 build of Microzello's source. Other Windows versions, display layouts and sign-in policies need separate testing.

## Setup

1. Select **Extend these displays** in Windows display settings and choose an image in **Personalization → Lock screen** for the primary display.
2. Install the appropriate build from the [VoidVolker release page](https://github.com/VoidVolker/LockScreen/releases/tag/1.0.1.993). This release uses the .NET 9 Desktop Runtime. Open its settings and verify that Logon Service is running.
3. Build and install Microzello's utility following its [installation instructions](https://github.com/Microzello/win11-lockscreen-wallpaper#install). The upstream process uses the .NET 8 SDK and adds a local code-signing certificate for UIAccess. Review the upstream [security considerations](https://github.com/Microzello/win11-lockscreen-wallpaper#security-considerations) before installing. Select the original image in its tray menu and enable **Start with Windows**.
4. Run the helper in PowerShell. It detects the secondary display if there is exactly one and saves a center-cropped copy as a new PNG.

   ~~~powershell
   .\Export-FittedWallpaper.ps1 -InputPath .\wallpaper.png -OutputPath .\wallpaper-filled.png
   ~~~

   For multiple secondary displays, use **DisplayName** to select one, or pass **Width** and **Height** directly.

   ~~~powershell
   .\Export-FittedWallpaper.ps1 -InputPath .\wallpaper.png -OutputPath .\wallpaper-filled.png -Width 2560 -Height 1600
   ~~~

5. In VoidVolker LockScreen, assign the generated PNG to the secondary display. Keep both images in a local folder readable by the respective utilities. Press **Win+L** to check the initial lock screen, then press Space to check the sign-in prompt.

If the monitors turn off after you lock, check the locked-display timeout in your active Windows power plan separately. The wallpaper helper only writes an image file.

## Uninstall

1. Disable **Start with Windows** from Microzello's tray menu and use the upstream [uninstall.cmd](https://github.com/Microzello/win11-lockscreen-wallpaper/blob/master/uninstall.cmd) to remove the utility and its local signing certificate.
2. Uninstall VoidVolker LockScreen from **Installed apps** or use its uninstaller.

This repository contains the setup guide and crop helper. Each upstream utility is maintained separately under the MIT License.
