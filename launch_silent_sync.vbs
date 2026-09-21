Set WshShell = CreateObject("WScript.Shell")
scriptPath = "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File ""c:\Users\mukhe\OneDrive\Documents\New Project\Adharm-Vinash\auto_sync.ps1"""
WshShell.Run scriptPath, 0, False
