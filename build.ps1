$gameName = "Main"
$loveExePath = "C:/Program Files/LOVE/love.exe"
$outputExe = "./build/$gameName.exe"
$loveFile = "./build/$gameName.love"
$includeFiles = @(
  "./main.lua",
  "./src/object.lua",
  "./src/entity.lua",
  "./src/bot.lua",
  "./src/tracker.lua",
  "./src/helper.lua",
  "./src/const.lua",
  "./assets/object.png",
  "./assets/bot_1.png",
  "./assets/bot_2.png",
  "./assets/food.png"
)

Add-Type -AssemblyName "System.IO.Compression.FileSystem"
$zip = [System.IO.Compression.ZipFile]::Open($loveFile, 'Create')

foreach ($file in $includeFiles)
{
  if (Test-Path $file)
  {
    # Forward slashes for consistency
    #
    # Remove ./ prefix when adding it to the
    # archive because LOVE2D will search in
    # working directory if string in code has
    # ./ prefix e.g ./src/bot.lua
    $zipEntryName = ($file -replace '\\', '/') -replace '^\./', ''

    [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $file, $zipEntryName) | Out-Null
  }
}
$zip.Dispose()

$exeBytes = [System.IO.File]::ReadAllBytes($loveExePath)
$loveBytes = [System.IO.File]::ReadAllBytes($loveFile)
[System.IO.File]::WriteAllBytes($outputExe, $exeBytes + $loveBytes)
Write-Host "App built: $outputExe"
Remove-Item $loveFile

Write-Host "Running App $gameName..."
Invoke-Item $outputExe
