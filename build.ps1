# ═══════════════════════════════════════════════════════════
# Build script for oida.mo standalone application (Windows)
# ═══════════════════════════════════════════════════════════

param(
    [switch]$Clean,
    [switch]$Release
)

$VERSION = "1.3.0"
$APP_NAME = "oida"
$BUILD_DIR = "build"
$SRC_DIR = "src"
$DIST_DIR = "dist"

Write-Host "🦞 oida.mo Build System v$VERSION" -ForegroundColor Cyan

# Check for Nim
$nim = Get-Command nim -ErrorAction SilentlyContinue
if (-not $nim) {
    Write-Host "⚠️  Nim not found. Install from: https://nim-lang.org" -ForegroundColor Yellow
    exit 1
}

# Create directories
New-Item -Path $BUILD_DIR -ItemType Directory -Force | Out-Null
New-Item -Path $DIST_DIR -ItemType Directory -Force | Out-Null

# Detect architecture
$arch = if ([Environment]::Is64BitOperatingSystem) { "x64" } else { "x86" }
$TARGET = "$APP_NAME-$VERSION-windows-$arch.exe"

Write-Host "📦 Target: $TARGET" -ForegroundColor Cyan

# Build with optimization flags
Write-Host "🔨 Compiling..." -ForegroundColor Cyan

$nimArgs = @(
    "c"
    "-d:release"
    "--gc:arc"
    "-d:danger"
    "--opt:speed"
    "-o:$DIST_DIR\$TARGET"
    "$SRC_DIR\main.nim"
)

if ($Release) {
    $nimArgs += "-d:release"
}

& nim @nimArgs

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Build successful: $DIST_DIR\$TARGET" -ForegroundColor Green
    
    # Show build info
    Write-Host "📊 Build Info:" -ForegroundColor Green
    Get-Item "$DIST_DIR\$TARGET" | Format-List Name, Length, LastWriteTime
    
    if (Test-Path "$DIST_DIR\$APP_NAME.exe") {
        Remove-Item "$DIST_DIR\$APP_NAME.exe" -Force
    }
    Copy-Item "$DIST_DIR\$TARGET" "$DIST_DIR\$APP_NAME.exe"
    Write-Host "📁 Executable ready: $DIST_DIR\$APP_NAME.exe" -ForegroundColor Green
} else {
    Write-Host "❌ Build failed" -ForegroundColor Yellow
    exit 1
}
