set ws = CreateObject("wscript.shell")

WScript.Sleep(1000)
ws.SendKeys("%y")
WScript.Sleep(500)
ws.SendKeys("%y")
WScript.Sleep(500)
ws.SendKeys("{ENTER}")