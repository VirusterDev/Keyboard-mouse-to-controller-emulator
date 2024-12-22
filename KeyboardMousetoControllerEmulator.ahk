#Persistent
#NoEnv
SetBatchLines, -1
SendMode, Input

vJoy_DLL := "C:\path\to\vJoyInterface.dll"

Menu, MainMenu, Add, Keyboard -> Controller, ShowKeyboardBindings
Menu, MainMenu, Add, Mouse -> Controller, ShowMouseBindings
Menu, MainMenu, Add, Save, SaveBindings
Menu, MainMenu, Show, w400 h800

ShowKeyboardBindings:
    Gui, New, +Resize +MinSize
    Gui, Add, Text, x10 y10 w200 h30, Keyboard Key Bindings
    Gui, Add, ListView, r20 w300 vLV_Keys, Key|Controller Button
    Gui, Add, Button, x10 y+5 w100 h30 gAddKeyBinding, Add Binding
    Gui, Show, w320 h600, Keyboard -> Controller
Return

ShowMouseBindings:
    Gui, New, +Resize +MinSize
    Gui, Add, Text, x10 y10 w200 h30, Mouse Bindings
    Gui, Add, ListView, r20 w300 vLV_Mouse, Mouse Action|Controller Button
    Gui, Add, Button, x10 y+5 w100 h30 gAddMouseBinding, Add Binding
    Gui, Show, w320 h300, Mouse -> Controller
Return

AddKeyBinding:
    InputBox, Key, Enter the Keyboard Key
    InputBox, Button, Enter the Controller Button
    LV_Add("", Key, Button)
Return

AddMouseBinding:
    InputBox, Action, Enter the Mouse Action
    InputBox, Button, Enter the Controller Button
    LV_Add("", Action, Button)
Return

SaveBindings:
    Gui, Submit
    Bindings := []
    Loop, % LV_GetCount()
    {
        LV_GetText(Key, A_Index, 1)
        LV_GetText(Button, A_Index, 2)
        Bindings.push({Key: Key, Button: Button})
    }
    FileDelete, bindings.json
    FileAppend, % JSON_Encode(Bindings), bindings.json
Return

JSON_Encode(Bindings)
{
    json := "["
    Loop, % Bindings.MaxIndex()
    {
        Binding := Bindings[A_Index]
        json .= "{""Key"":""" Binding.Key """,""Button"":""" Binding.Button """}"
        if (A_Index < Bindings.MaxIndex())
            json .= ","
    }
    json .= "]"
    return json
}

OnExit:
ExitApp

; Simulate Keyboard and Mouse Inputs to vJoy
SetTimer, MonitorInput, 10
Return

MonitorInput:
Loop
{
    ; Keyboard to Controller Mapping
    Loop, % LV_GetCount()
    {
        LV_GetText(Key, A_Index, 1)
        LV_GetText(Button, A_Index, 2)
        if (GetKeyState(Key, "P"))
        {
            SimulateControllerInput(Button)
        }
    }
    ; Mouse to Controller Mapping
    ; For simplicity, using left-click for button emulation
    if (GetKeyState("LButton", "P"))
    {
        SimulateControllerInput("Button1")
    }
    ; Add more conditions for mouse emulation like movement, scroll etc.
}
Return

SimulateControllerInput(Button)
{
    DllCall(vJoy_DLL, "str", "SetBtn", "int", 1, "int", Button)
}
