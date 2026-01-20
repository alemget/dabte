$keytool = "C:\Program Files\Java\jdk-21.0.10\bin\keytool.exe"
$keystore = "$env:USERPROFILE\.android\debug.keystore"
Write-Host "Running keytool..."
$output = & $keytool -list -v -keystore $keystore -alias androiddebugkey -storepass android -keypass android 2>&1
$sha1Line = $output | Select-String "SHA1:"
if ($sha1Line) {
    Write-Host "FOUND_SHA1_START"
    Write-Host $sha1Line
    Write-Host "FOUND_SHA1_END"
}
else {
    Write-Host "SHA1 not found in output."
    Write-Host $output
}
