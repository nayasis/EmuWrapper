#Requires AutoHotkey >=2.0

class VirtualDisk {

  static _init() {
		VirtualDisk.mountedImage := ""
	}
  static void := VirtualDisk._init()

	mount(path) {
		if (FileUtil.isFile(path)) {
			cmd := "powershell Mount-DiskImage '" path "'"
			debug(cmd)
			RunWait(cmd, , "Hide")
			this.mountedImage := path
			debug(">> mount : " this.mountedImage)
			return this.mounted()
		}
	}

	mounted() {
		return this.mountedImage != ""
	}

	unmount() {
		if (this.mounted()) {
			debug(">> unmount : " this.mountedImage)
			cmd := "powershell Dismount-DiskImage '" this.mountedImage "'"
			RunWait(cmd, , "Hide")
		}
	}
}
