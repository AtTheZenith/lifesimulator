$gameName = "Main"
$loveExePath = "C:/Program Files/LOVE/love.exe"
$outputExe = "./build/$gameName.exe"
$loveFile = "./build/$gameName.love"
$includeFiles = @(
  "./main.lua",
  "./src/player.lua",
  "./src/input.lua",
  "./src/const.lua",
  "./assets/bot.png"
)

Add-Type -AssemblyName "System.IO.Compression.FileSystem"
$zip = [System.IO.Compression.ZipFile]::Open($loveFile, 'Create')

foreach ($file in $includeFiles)
{
  if (Test-Path $file)
  {
    $zipEntryName = $file -replace '\\', '/'
    if ($file -eq "./main.lua")
    {
      $zipEntryName = "main.lua"
    }
    [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $file, $zipEntryName) | Out-Null
  }
}
$zip.Dispose()

$exeBytes = [System.IO.File]::ReadAllBytes($loveExePath)
$loveBytes = [System.IO.File]::ReadAllBytes($loveFile)
[System.IO.File]::WriteAllBytes($outputExe, $exeBytes + $loveBytes)
Write-Host "Game built: $outputExe"

Remove-Item $loveFile
