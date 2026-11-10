#requires -Version 5.1
[CmdletBinding(DefaultParameterSetName = 'Detect', SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [string]$InputPath,

    [Parameter(Mandatory)]
    [string]$OutputPath,

    [Parameter(ParameterSetName = 'Detect')]
    [string]$DisplayName,

    [Parameter(Mandatory, ParameterSetName = 'Dimensions')]
    [ValidateRange(1, 16384)]
    [int]$Width,

    [Parameter(Mandatory, ParameterSetName = 'Dimensions')]
    [ValidateRange(1, 16384)]
    [int]$Height
)

$ErrorActionPreference = 'Stop'
$inputFile = Get-Item -LiteralPath $InputPath
if ($inputFile -isnot [IO.FileInfo]) {
    throw 'InputPath must point to an image file.'
}
$outputFile = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputPath)
if ([IO.Path]::GetExtension($outputFile) -ine '.png') {
    throw 'OutputPath must end in .png.'
}
if (Test-Path -LiteralPath $outputFile) {
    throw 'Choose a new output filename. The helper does not overwrite files.'
}

if ($PSCmdlet.ParameterSetName -eq 'Detect') {
    if (-not ('WallpaperFit.Dpi' -as [type])) {
        Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;

namespace WallpaperFit
{
    public static class Dpi
    {
        [DllImport("user32.dll", SetLastError = true)]
        public static extern IntPtr SetThreadDpiAwarenessContext(IntPtr context);
    }
}
'@
    }
    # PER_MONITOR_AWARE_V2 returns physical rather than scaled display bounds.
    $previousDpi = [WallpaperFit.Dpi]::SetThreadDpiAwarenessContext([IntPtr](-4))
    if ($previousDpi -eq [IntPtr]::Zero) {
        throw 'Could not detect physical display sizes. Pass -Width and -Height.'
    }
    try {
        Add-Type -AssemblyName System.Windows.Forms
        $screens = @([Windows.Forms.Screen]::AllScreens | Where-Object { -not $_.Primary })
        if ($DisplayName) {
            $screens = @($screens | Where-Object DeviceName -eq $DisplayName)
        }
        if ($screens.Count -ne 1) {
            throw 'Could not select one secondary display. Pass -DisplayName or -Width and -Height.'
        }
        $bounds = $screens[0].Bounds
        $Width = $bounds.Width
        $Height = $bounds.Height
    } finally {
        [void][WallpaperFit.Dpi]::SetThreadDpiAwarenessContext($previousDpi)
    }
}

if (-not $PSCmdlet.ShouldProcess($outputFile, ('Export {0}x{1} wallpaper' -f $Width, $Height))) {
    return
}

Add-Type -AssemblyName System.Drawing
$source = [Drawing.Image]::FromFile($inputFile.FullName)
$tempFile = Join-Path ([IO.Path]::GetDirectoryName($outputFile)) ('.wallpaper-' + [Guid]::NewGuid().ToString('N') + '.tmp')
$bitmap = $graphics = $null
try {
    $bitmap = [Drawing.Bitmap]::new($Width, $Height, [Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [Drawing.Graphics]::FromImage($bitmap)
    $graphics.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.PixelOffsetMode = [Drawing.Drawing2D.PixelOffsetMode]::HighQuality

    $scale = [Math]::Max($Width / $source.Width, $Height / $source.Height)
    $drawWidth = [int][Math]::Ceiling($source.Width * $scale)
    $drawHeight = [int][Math]::Ceiling($source.Height * $scale)
    $x = [int][Math]::Truncate(($Width - $drawWidth) / 2)
    $y = [int][Math]::Truncate(($Height - $drawHeight) / 2)
    $graphics.DrawImage($source, [Drawing.Rectangle]::new($x, $y, $drawWidth, $drawHeight))

    $bitmap.Save($tempFile, [Drawing.Imaging.ImageFormat]::Png)
    [IO.File]::Move($tempFile, $outputFile)
} finally {
    foreach ($resource in $graphics, $bitmap, $source) {
        if ($null -ne $resource) {
            $resource.Dispose()
        }
    }
    if (Test-Path -LiteralPath $tempFile) {
        Remove-Item -LiteralPath $tempFile
    }
}

[pscustomobject]@{
    Path   = $outputFile
    Width  = $Width
    Height = $Height
}
