#NoEnv

class VirtualDisk {

  static void := VirtualDisk._init()

	_init() {
		this.mountedImage := ""
	}

	mount(path) {
		if(FileUtil.isFile(path)) {
			cmd := "powershell Mount-DiskImage '" path "'"
			debug(cmd)
			RunWait, % cmd,, Hide,
			; RunWait, % cmd,,,
			this.mountedImage := path
			debug(">> mount : " this.mountedImage)
			return this.mounted()
		}
	}

	mounted() {
		return this.mountedImage != ""
	}

	unmount() {
		if(this.mounted()) {
			debug(">> unmount : " this.mountedImage)
			cmd := "powershell Dismount-DiskImage '" this.mountedImage "'"
			RunWait, % cmd,, Hide,
		}
	}

}