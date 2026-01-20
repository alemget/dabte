# تشغيل هذا السكريبت للحصول على SHA-1 fingerprint
# PowerShell Script to get SHA-1 fingerprint

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Get SHA-1 Fingerprint" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

$debugKeystorePath = "$env:USERPROFILE\.android\debug.keystore"

# التحقق من وجود keystore
if (-Not (Test-Path $debugKeystorePath)) {
    Write-Host "ERROR: debug keystore not found at:" -ForegroundColor Red
    Write-Host "   $debugKeystorePath" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Solution:" -ForegroundColor Yellow
    Write-Host "1. Run the app at least once" -ForegroundColor White
    Write-Host "2. debug.keystore will be created automatically" -ForegroundColor White
    exit 1
}

Write-Host "Found debug keystore" -ForegroundColor Green
Write-Host ""

# البحث عن keytool في Flutter
$flutterPath = (Get-Command flutter -ErrorAction SilentlyContinue).Source
if ($flutterPath) {
    $flutterDir = Split-Path (Split-Path $flutterPath)
    $javaHome = "$flutterDir\jre"
    if (Test-Path "$javaHome\bin\keytool.exe") {
        $keytoolPath = "$javaHome\bin\keytool.exe"
        Write-Host "Found keytool in Flutter SDK" -ForegroundColor Green
    }
}

# البحث في JAVA_HOME
if (-Not $keytoolPath -and $env:JAVA_HOME) {
    if (Test-Path "$env:JAVA_HOME\bin\keytool.exe") {
        $keytoolPath = "$env:JAVA_HOME\bin\keytool.exe"
        Write-Host "Found keytool in JAVA_HOME" -ForegroundColor Green
    }
}

# البحث في PATH
if (-Not $keytoolPath) {
    $keytoolCmd = Get-Command keytool -ErrorAction SilentlyContinue
    if ($keytoolCmd) {
        $keytoolPath = $keytoolCmd.Source
        Write-Host "Found keytool in PATH" -ForegroundColor Green
    }
}

if (-Not $keytoolPath) {
    Write-Host "ERROR: keytool not found" -ForegroundColor Red
    Write-Host ""
    Write-Host "Solutions:" -ForegroundColor Yellow
    Write-Host "1. Install Java JDK" -ForegroundColor White
    Write-Host "2. Or use keytool from Flutter SDK" -ForegroundColor White
    Write-Host "3. Or run the command manually:" -ForegroundColor White
    Write-Host "   keytool -list -v -keystore `"$debugKeystorePath`" -alias androiddebugkey -storepass android -keypass android" -ForegroundColor Gray
    exit 1
}

Write-Host "Extracting SHA-1..." -ForegroundColor Cyan
Write-Host ""

# تشغيل keytool
$output = & $keytoolPath -list -v -keystore $debugKeystorePath -alias androiddebugkey -storepass android -keypass android 2>&1

# البحث عن SHA-1
$sha1 = ($output | Select-String "SHA1:").ToString().Split(":")[1].Trim()
$sha256 = ($output | Select-String "SHA256:").ToString().Split(":")[1].Trim()

if ($sha1) {
    Write-Host "==================================" -ForegroundColor Green
    Write-Host "SHA-1 Fingerprint:" -ForegroundColor Green
    Write-Host $sha1 -ForegroundColor Yellow
    Write-Host "==================================" -ForegroundColor Green
    Write-Host ""
    
    if ($sha256) {
        Write-Host "SHA-256 Fingerprint:" -ForegroundColor Cyan
        Write-Host $sha256 -ForegroundColor Gray
        Write-Host ""
    }
    
    # نسخ إلى clipboard
    try {
        $sha1 | Set-Clipboard
        Write-Host "SHA-1 copied to clipboard!" -ForegroundColor Green
    } catch {
        Write-Host "WARNING: SHA-1 not copied - copy it manually" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Go to Google Cloud Console" -ForegroundColor White
    Write-Host "   https://console.cloud.google.com/" -ForegroundColor Gray
    Write-Host "2. APIs & Services -> Credentials" -ForegroundColor White
    Write-Host "3. Create OAuth Client ID (Android)" -ForegroundColor White
    Write-Host "4. Package name: com.diomax.app" -ForegroundColor White
    Write-Host "5. Paste SHA-1 above" -ForegroundColor White
    Write-Host ""
    
} else {
    Write-Host "ERROR: Failed to extract SHA-1" -ForegroundColor Red
    Write-Host "Full output:" -ForegroundColor Yellow
    Write-Host $output
}

Read-Host "Press Enter to exit..."
