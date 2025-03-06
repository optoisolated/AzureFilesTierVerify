# Define the path to check
$path = "D:\"
# Show file being checked as its checked
$Verbose = True



CLS
$reparseCount = 0
$offlineCount = 0
$checkedFiles = 0

$results = Get-ChildItem -Path $path -File -Recurse -ErrorAction SilentlyContinue | 
    ForEach-Object {
        $checkedFiles++
        If ($Verbose) { Write-Host "Checking File $($checkedFiles): $($_.FullName)" }
        $attributes = $_.Attributes
        
        $isReparse = ($attributes -band [System.IO.FileAttributes]::ReparsePoint) -eq [System.IO.FileAttributes]::ReparsePoint
        $isOffline = ($attributes -band [System.IO.FileAttributes]::Offline) -eq [System.IO.FileAttributes]::Offline
        
        if ($isReparse -or $isOffline) {
            if ($isReparse) { $reparseCount++ }
            if ($isOffline) { $offlineCount++ }
            
            [PSCustomObject]@{
                FullPath = $_.FullName
                ReparsePoint = $isReparse
                Offline = $isOffline
            }
        }
    }

Write-Host "`nFiles with ReparsePoint (L) or Offline (O) attributes:" -ForegroundColor Green
Write-Host "------------------------------------------------" -ForegroundColor Green

if ($results) {
    $results | Format-Table -Property FullPath, ReparsePoint, Offline -AutoSize
} else {
    Write-Host "No files found with ReparsePoint or Offline attributes." -ForegroundColor Yellow
}

Write-Host "`nSummary:" -ForegroundColor Green
Write-Host "--------" -ForegroundColor Green
Write-Host "Files discovered: $($results.Count)"
Write-Host "Files checked: $checkedFiles"
Write-Host "Files with ReparsePoint (L) attribute: $reparseCount"
Write-Host "Files with Offline (O) attribute: $offlineCount"
