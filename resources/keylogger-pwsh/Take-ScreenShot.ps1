Function Get-Screen {
    param (
        [String] $Path = (Get-Location).Path,
        [String] $FileName = "Screenshot",
        [Int] $ScreenNumber = 0
    )

    Write-Host "Starting screenshot capture..."
    [void] [Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    [void] [Reflection.Assembly]::LoadWithPartialName("System.Drawing")

    $Screens = [System.Windows.Forms.Screen]::AllScreens
    Write-Host "Number of screens detected: $($Screens.Count)"

    If ($ScreenNumber -eq 0) {
        Write-Host "Capturing all screens..."
        foreach ($Screen in $Screens) {
            $MaxWidth += $Screen.Bounds.Width
            if ($MaxHeight -lt $Screen.Bounds.Height) {
                $MaxHeight = $Screen.Bounds.Height
            }
        }
        $ScreensSize = New-Object PSObject -property @{
            X = 0
            Y = 0
            Width = $MaxWidth
            Height = $MaxHeight
        }
    } elseif ($ScreenNumber -le $Screens.Count) {
        Write-Host "Capturing screen $ScreenNumber..."
        if ($ScreenNumber -ge 2) {
            $sn = $ScreenNumber
            while ($sn - 2 -ge 0) {
                $X += $Screens[$sn - 2].Bounds.Width
                $sn--
            }
            $Y = 0
        } else {
            $X = 0
            $Y = 0
        }
        $ScreensSize = New-Object PSObject -property @{
            X = $X
            Y = $Y
            Width = $Screens[$ScreenNumber - 1].Bounds.Width
            Height = $Screens[$ScreenNumber - 1].Bounds.Height
        }
    } else {
        Write-Warning "Invalid screen number: $ScreenNumber"
        return
    }

    $i = 1
    do {
        $Name = $FileName
        if ($i -gt 1) {
            $Name += "-$i"
        }
        $FULLPATH = Join-Path -Path $Path -ChildPath "$Name.png"
        $i++
    } while (Test-Path -Path $FULLPATH)

    Write-Host "Saving screenshot to: $FULLPATH"
    $Size = New-Object System.Drawing.Size $ScreensSize.Width, $ScreensSize.Height
    $Bitmap = New-Object System.Drawing.Bitmap $ScreensSize.Width, $ScreensSize.Height
    $Screenshot = [Drawing.Graphics]::FromImage($Bitmap)

    try {
        $Screenshot.CopyFromScreen($ScreensSize.X, $ScreensSize.Y, 0, 0, $Size)
        $Bitmap.Save($FULLPATH)
        Write-Host "Screenshot saved successfully!"
    } catch {
        Write-Error "Error during screen capture: $_"
    } finally {
        $Screenshot.Dispose()
        $Bitmap.Dispose()
    }
}
