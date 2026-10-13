param([string]$AppRoot = 'C:\Source\Sabinetek', [switch]$SyncApp)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$siteRoot = Split-Path $PSScriptRoot -Parent
$staticRoot = Join-Path $siteRoot 'static'
[xml]$logo = Get-Content (Join-Path $staticRoot 'images/plural.svg') -Raw

function Export-Logo([int]$Size, [string]$Path) {
    $bitmap = [System.Drawing.Bitmap]::new($Size, $Size)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    try {
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $graphics.ScaleTransform($Size / 128.0, $Size / 128.0)
        foreach ($rect in $logo.svg.rect) {
            $left = if ($rect.x) { [single]$rect.x } else { 0 }
            $top = if ($rect.y) { [single]$rect.y } else { 0 }
            $width = [single]$rect.width
            $height = [single]$rect.height
            $diameter = [single]$rect.rx * 2
            $shape = [System.Drawing.Drawing2D.GraphicsPath]::new()
            $brush = [System.Drawing.SolidBrush]::new([System.Drawing.ColorTranslator]::FromHtml($rect.fill))
            try {
                $shape.AddArc($left, $top, $diameter, $diameter, 180, 90)
                $shape.AddArc($left + $width - $diameter, $top, $diameter, $diameter, 270, 90)
                $shape.AddArc($left + $width - $diameter, $top + $height - $diameter, $diameter, $diameter, 0, 90)
                $shape.AddArc($left, $top + $height - $diameter, $diameter, $diameter, 90, 90)
                $shape.CloseFigure()
                $graphics.FillPath($brush, $shape)
            } finally { $brush.Dispose(); $shape.Dispose() }
        }
        $bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    } finally { $graphics.Dispose(); $bitmap.Dispose() }
}

function Export-Screenshot([string]$Source, [string]$Destination, [int]$Width) {
    $image = [System.Drawing.Image]::FromFile($Source)
    $height = [int]($image.Height * $Width / $image.Width)
    $bitmap = [System.Drawing.Bitmap]::new($Width, $height)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    try {
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.DrawImage($image, 0, 0, $Width, $height)
        $bitmap.Save($Destination, [System.Drawing.Imaging.ImageFormat]::Png)
    } finally { $graphics.Dispose(); $bitmap.Dispose(); $image.Dispose() }
}

Export-Logo 32 (Join-Path $staticRoot 'favicon-32.png')
Export-Logo 180 (Join-Path $staticRoot 'apple-touch-icon.png')
Export-Logo 1024 (Join-Path $staticRoot 'images/plural.png')
Export-Logo 256 (Join-Path $staticRoot 'images/plural-256.png')
$png = [System.IO.File]::ReadAllBytes((Join-Path $staticRoot 'images/plural-256.png'))
$stream = [System.IO.File]::Create((Join-Path $staticRoot 'favicon.ico'))
$writer = [System.IO.BinaryWriter]::new($stream)
try {
    $writer.Write([uint16]0); $writer.Write([uint16]1); $writer.Write([uint16]1)
    $writer.Write([byte]0); $writer.Write([byte]0); $writer.Write([byte]0); $writer.Write([byte]0)
    $writer.Write([uint16]1); $writer.Write([uint16]32)
    $writer.Write([uint32]$png.Length); $writer.Write([uint32]22); $writer.Write($png)
} finally { $writer.Dispose() }
Export-Screenshot (Join-Path $AppRoot 'Marketing/screenshots/desktop/01.png') (Join-Path $staticRoot 'images/recorder.png') 1440
Export-Screenshot (Join-Path $AppRoot 'Marketing/screenshots/phone/01.png') (Join-Path $staticRoot 'images/recorder-phone.png') 540
if ($SyncApp) {
    Copy-Item (Join-Path $staticRoot 'images/plural.svg') (Join-Path $AppRoot 'Marketing/brand/plural.svg')
    Copy-Item (Join-Path $staticRoot 'images/plural.png') (Join-Path $AppRoot 'Marketing/brand/icon.png')
    Copy-Item (Join-Path $staticRoot 'images/plural.png') (Join-Path $AppRoot 'Src/Plural.App.Android/Icon.png')
    Copy-Item (Join-Path $staticRoot 'favicon.ico') (Join-Path $AppRoot 'Src/Plural.App/Assets/plural.ico')
}
Write-Output 'Exported website screenshots, PNG logos, touch icon and ICO from the shared SVG.'