#Requires AutoHotkey v2.0
#SingleInstance Force
#UseHook true

; Request Admin rights (mandatory for hardware changes)
if !A_IsAdmin {
    Run('*RunAs "' A_ScriptFullPath '"')
    ExitApp()
}

; --- Copilot Key -> Right Control ---
    ;Intercept Left Win + Left Shift + F23 (copilot key)
    *<+<#f23:: {
        ;release Win and Shift so theres no accidental shortcuts
        ;Rctrl down
        Send "{Blind}{LShift up}{LWin up}{RCtrl down}"
    }

    *<+<#f23 up:: {
        ; if copilot key up, release Rctrl
        Send "{Blind}{RCtrl up}"
}




; --- Vim-style Navigation ---
/* *<^>!h::Send("{Blind}{Left}")
*<^>!j::Send("{Blind}{Down}")
*<^>!k::Send("{Blind}{Up}")
*<^>!l::Send("{Blind}{Right}")
*<^>!u::Send("{Blind}{Home}")
*<^>!i::Send("{Blind}{End}")
; --- Backspace (AltGr + m) ---
<^>!m::Send("{Blind}{Backspace}")

; --- Delete Word / Ctrl+Backspace (Shift + AltGr + m) ---
+<^>!m::Send("^{Backspace}") */



#t:: {
    ;finds the touchscreen device ID then then toggles it using pnputil.
    cmd := 'powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command "' . 
           '$dev = Get-PnpDevice | Where-Object { $_.FriendlyName -like \"*touch screen*\" -or $_.Service -eq \"mtconfig\" } | Select-Object -First 1; ' .
           'if ($dev.Status -eq \"OK\") { Disable-PnpDevice -InstanceId $dev.InstanceId -Confirm:$false } ' .
           'else { Enable-PnpDevice -InstanceId $dev.InstanceId -Confirm:$false }"'

    try {
        RunWait(cmd, , "Hide")
        ToolTip("Touchscreen Toggled")
    } catch {
        ToolTip("Toggle Failed")
    }

    SetTimer(() => ToolTip(), -2000)
}

; --- Close front application (Win+W) ---
#w:: {
    if WinExist("A") {
        WinClose("A")
    }
}

; --- Browser shortcut (Win+B) ---
#b:: {
    try {
        browserRegPath := "HKCU\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice"
        progId := RegRead(browserRegPath, "ProgId") ; Default browser
        
        cmdPath := RegRead("HKCR\" . progId . "\shell\open\command") ;path
        
        RegExMatch(cmdPath, '"([^"]+)"', &match) ;cleanup with regex
        browserExe := match[1]
        
        Run('"' . browserExe . '"') ;run exe
    } 
    catch {
        Run("about:blank") ;fallback if something fails
    }
}
