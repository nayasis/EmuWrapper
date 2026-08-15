#Requires AutoHotkey >=2.0
/*

;TestCode

#Include Common.ahk
#Include FileUtil.ahk
#Include Tray.ahk

imageFilePath := "\\NAS\emul\image\PC9801\0_imagesFdi\Ys 2 (1988)(Nihon Falcom)(T-Kr)\Ys 2 - Ancient Ys Vanished - The Final Chapter disk 1 (19xx)(Falcom).D88"

fddContainer  := new DiskContainer( imageFilePath, "i).*\.(d88|fdi)" )

msgbox % fddContainer.size()

msgbox % fddContainer.toString()

msgbox % fddContainer.toOption()

return

^+PGUP:: ; Drive#1 Disk Change
    fddContainer.insertDisk( "1", "setDisk" )
    ;Tray.showMessage( "Disk 1", fddContainer.toString(), 10000 )
	return

^+PGDN:: ; Drive#2 Disk Change
	fddContainer.insertDisk( "2", "setDisk" )
    ;Tray.showMessage( "Disk 2", fddContainer.toString(), 10000 )
	return

^F3::
    msgbox Close !!
    ExitApp

^+Del:: ; Cancel Disk Change	
	fddContainer.cancel()
	return

setDisk( slotNo, file ) {
    IfNotExist % file 
        return
    msgbox % "disk[" file "] is inserted in [" slotNo "]"
    
}
*/


class DiskContainer {

    static slot := Map()

    container   := []
   
    __New(path := "", pattern := ".*") {
        if (path != "") {
            this.container := FileUtil.findFiles(path, pattern)
        }
    }

    size() {
        cnt := this.container.Length
        if (cnt == "" || cnt == 0)
            return 0
        return cnt
    }

    hasDisk() {
      return this.size() > 0
    }

    hasMultiDisk() {
      return this.size() > 1
    }

    addPath(path) {
        this.container.Push(path)
    }
    
    toString() {
        returnVal := ""
        returnVal := returnVal . ">> In Slot`n"
        for slotNo, slot in DiskContainer.slot {
            returnVal := returnVal . "  - slot:" . slotNo . ", file: `"" . slot.fileInserted . "`n"
        }
        returnVal := returnVal . ">> In Container`n"
        loop this.container.Length {
            returnVal := returnVal . "  - index:" . A_Index . ", file : `"" . this.container[A_Index] . "`n"
        }
        return returnVal
    }
    
    toOption(limitCount := 999, prefix := "", postfix := "") {
        returnVal := ""
        loop this.size() {
            if (A_Index > limitCount)
                break
            returnVal := returnVal . prefix . " `"" . this.container[A_Index] . "`"" . postfix
        }
        return Trim(returnVal)
    }

    insertDisk(slotNo, functionName, duration := 1000) {
        file := ""
        loop this.size() {
            file := this.container[1]
            swapDisk := this.container[1]
            this.container.RemoveAt(1)
            this.container.Push(swapDisk)
            if (file != DiskContainer.slot[slotNo].fileInserted)
                break
        }

        SetTimer(DiskContainer.Timer_InsertDisk_RunFunction, 0)

        if (!DiskContainer.slot.Has(slotNo) || DiskContainer.slot[slotNo] == "")
            DiskContainer.slot[slotNo] := {}

        DiskContainer.slot[slotNo].file := file
        DiskContainer.slot[slotNo].functionName := functionName

        debug("insert disk in drive " slotNo)
        simpleFileName := FileUtil.getName(file)
        if (simpleFileName == "") {
            simpleFileName := RegExReplace(file, "(.+?)\.*?$", "$1")
        }
        debug(simpleFileName)
        Tray.showMessage("Insert Disk in Drive " . slotNo . " : " . simpleFileName)

        SetTimer(DiskContainer.Timer_InsertDisk_RunFunction, -duration)
    }

    static Timer_InsertDisk_RunFunction() {
        for slotNo, slot in DiskContainer.slot {
            if (slot.file == "")
                continue
            fn := Func(slot.functionName)
            if (fn)
                fn.Call(slotNo, slot.file)
            slot.fileInserted := slot.file
            slot.file := ""
            slot.functionName := ""
        }
    }
    
    removeDisk( slotNo, functionName ) {

        Tray.showMessage( "Remove disk in Drive " slotNo, "" )
        if !DiskContainer.slot.Has(slotNo)
            return
        slot := DiskContainer.slot[ slotNo ]
        fn := Func(functionName)
        if (fn)
            fn.Call(slotNo, slot.file)
        slot.fileInserted := ""
        slot.file         := ""
        slot.functionName := ""        
        
    }
    
    cancel() {
        Tray.showMessage("Cancel to change disk")
        for slotNo, slot in DiskContainer.slot {
            if (slot.file == "")
                continue
            slot.file := ""
            slot.functionName := ""
        }
        SetTimer(DiskContainer.Timer_InsertDisk_RunFunction, 0)
    }
    
    setSlot(slotNo, file) {
        if (!DiskContainer.slot.Has(slotNo) || DiskContainer.slot[slotNo] == "")
            DiskContainer.slot[slotNo] := {}
        DiskContainer.slot[slotNo].fileInserted := file
    }

    getFileInSlot(slotNo) {
        return DiskContainer.slot.Has(slotNo) ? DiskContainer.slot[slotNo].fileInserted : ""
    }
    
    getFile(index) {
        return this.container[index]
    }

    initSlot(size) {
        loop this.size() {
            if (A_Index > size)
                break
            this.setSlot(A_Index, this.getFile(A_Index))
        }
    }

}
