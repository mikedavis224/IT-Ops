#export pathping output to txt file
$url = Read-Host "Enter url to trace"
$path = Read-Host "Enter path to save log"
pathping $url | out-file -FilePath $path