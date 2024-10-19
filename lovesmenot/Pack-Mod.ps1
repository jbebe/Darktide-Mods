$version = Read-Host "Mod version"
$zipFile = "lovesmenot-$version.zip"
Remove-Item $zipFile -ErrorAction Ignore

Add-Type -AssemblyName System.IO.Compression, System.IO.Compression.FileSystem

$zip = [System.IO.Compression.ZipFile]::Open(
    (Join-Path -Path $(Resolve-Path -Path ".") -ChildPath $zipFile),
  [System.IO.Compression.ZipArchiveMode]::Create
)

function CreateZipItem ([string]$filePath, [string] $prefix) {
  $newPath = $(Resolve-Path -Path $filePath -Relative) -replace '\.\\', ''
  $newPath = Join-Path $prefix $newPath
  Write-Output "$newPath"
  $zipEntry = $zip.CreateEntry($newPath)
  $zipEntryWriter = New-Object -TypeName System.IO.BinaryWriter $zipEntry.Open()
  $content = [System.IO.File]::ReadAllText($filePath) `
    -replace 'localhost:53531', 'lmn-api.blint.cloud' `
    -replace 'localhost:5173', 'lovesmenot.blint.cloud'
  $zipEntryWriter.Write([system.Text.Encoding]::UTF8.GetBytes($content))
  $zipEntryWriter.Flush()
  $zipEntryWriter.Close()
}

try {
  # Add scripts to list
  $modFiles = @()
  $modFiles += (Get-ChildItem src -File -Recurse | ForEach-Object { $_.FullName })
  $modFiles += (Get-ChildItem nurgle_modules -File -Recurse | ForEach-Object { $_.FullName })
  
  # Create zip items
  CreateZipItem "$((Get-ChildItem lovesmenot.mod).FullName)" "lovesmenot"
  foreach ($fname in $modFiles) {
    CreateZipItem "$fname" "lovesmenot"
  }  
}
finally {
  # Clean up
  $zip.Dispose()
}
