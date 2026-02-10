# Repository Guidelines

## Project Structure & Module Organization
This repository is an AutoHotkey-based emulator wrapper collection with platform-specific folders at the root (e.g., `3ds/`, `psx2/`, `retroarch/`, `mame/`, `apple2e/`). Each platform folder contains wrapper scripts (`Wrapper*.ahk`) and the emulator binaries/configs that the wrapper targets. Shared utilities live in `ZZ_Library/` (notably `ZZ_Library/Include.ahk`), and shared assets like screenshots are centralized in `ZZ_snapshot/`. Build helpers live under `tools/` (notably `tools/Compile.ahk` and `tools/run_ahk.ps1`).

## Build, Test, and Development Commands
There is no unified build system; wrappers are compiled individually via AutoHotkey. Standard usage:
```powershell
.\tools\run_ahk.ps1 .\apple2e\AppleWin1.30.20\WrapperAppleWin.ahk
```
This uses `tools/run_ahk.ps1` which auto-detects file extensions: `.ahk` runs directly, `.exe` runs directly. Use `-compile` to build `.ahk` into `.exe` via `tools/Compile.ahk`. Examples:
```powershell
.\tools\run_ahk.ps1 .\apple2e\AppleWin1.30.20\WrapperAppleWin.ahk
.\tools\run_ahk.ps1 .\apple2e\AppleWin1.30.20\WrapperAppleWin.ahk -compile
.\tools\run_ahk.ps1 .\apple2e\AppleWin1.30.20\WrapperAppleWin.exe
```

Compiler selection for v2:
- If needed, set `AHK2EXE_PATH` or `AHK_COMPILER_DIR` to point to the v2 compiler.
- `tools/Compile.ahk` uses `C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe` as `/base` by default.

Stdout/stderr capture:
- `tools/run_ahk.ps1` writes stdout/stderr to a temp log via `AHK_STDOUT_LOG` and echoes it back to the console.
- For `.ahk` runs, it starts AutoHotkey with `/ErrorStdOut /CP65001 /restart`.
- If a `.ahk` run does not exit within 2 minutes, the AutoHotkey process is force-terminated.
- When running `.exe` targets, `tools/run_ahk.ps1` stops the launched process after output capture, matching by executable path.

Test scripts:
- Local test scripts are kept under `.test/` (e.g., `.test/CliTest.ahk`, `.test/ExecScriptTest.ahk`, `.test/JsonDumpTest.ahk`).
- Debugging tests live at `.test/tools/DebuggingTest.ahk` and should be kept (do not delete).
- All test scripts under `.test/` are permanent and must be kept (do not delete).
- Any ad-hoc test artifacts originally created in `tools/` must be moved into `.test/tools/` (including test `.ahk`, `.exe`, and log files).
```

## Coding Style & Naming Conventions
Scripts target AutoHotkey v2 syntax. Keep header directives at the top, and follow existing formatting (tabs for indentation and aligned assignments such as `imageDir    := %0%`). File naming follows `Wrapper<Name>.ahk` for entry points.

## Testing Guidelines
No automated test framework is present. Validate changes manually by running the relevant wrapper and verifying emulator launch, save folder linking, and hotkeys. Use a small test ROM/image file and confirm links are created under each game’s `_EL_CONFIG` and in the emulator’s user profile.

## Commit & Pull Request Guidelines
Recent commits are short, single-line summaries, often in Korean, without a strict prefix. Keep messages concise, describing the change in one sentence (e.g., “fix wrapper” / “수정내용 추가”). For PRs, include:
- A brief summary of the emulator(s) affected
- The exact wrapper(s) or folders touched (e.g., `psx2\PCSX2\WrapperPCSX2.ahk`)
- Screenshots or logs if behavior changes are user-visible

## Configuration Notes
Many wrappers assume a shared layout and make symlinks to emulator save/config folders. Review paths in each wrapper (e.g., `Environment.getUserHome()` or `ZZ_snapshot`) before distributing to another machine.
