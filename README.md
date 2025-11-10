# MTG Arena Fullscreen Fixer

A Windows utility that automatically monitors and maintains fullscreen mode for MTG Arena, preventing the game from reverting to windowed mode.

## Problem

MTG Arena sometimes loses fullscreen mode during gameplay, especially:
- When alt-tabbing between applications
- After certain in-game events or transitions
- During Steam overlay interactions
- When switching displays or resolutions

## Solution

This tool runs in the background and automatically detects when MTG Arena exits fullscreen mode, then immediately toggles it back to fullscreen using Alt+Enter.

## Features

- **Automatic Monitoring**: Continuously monitors MTG Arena window state
- **Instant Recovery**: Immediately restores fullscreen when lost
- **Easy Launch**: Single batch file launches both the game and monitor
- **Low Overhead**: Minimal system resource usage
- **Auto-Exit**: Closes automatically when MTG Arena is closed

## Requirements

- Windows OS
- MTG Arena (Steam version)
- PowerShell (included with Windows)

## Installation

1. Clone or download this repository
2. Adjust the Steam path in `Launch_MTGA.bat` if your Steam installation is in a different location (default: `C:\Program Files (x86)\Steam\`)
3. Verify the MTG Arena App ID is correct (default: 2141910)

## Usage

### Quick Start

Simply run `Launch_MTGA.bat` - it will:
1. Launch MTG Arena through Steam
2. Wait for the game to initialize (15 seconds)
3. Start the fullscreen monitor

### Manual Usage

If you prefer to launch MTG Arena separately:
```batch
powershell -ExecutionPolicy Bypass -File MTGArenaFullscreenFix.ps1
```

The monitor will wait for MTG Arena to start and then begin monitoring.

## Configuration

### Adjusting Check Interval

Edit `MTGArenaFullscreenFix.ps1` and modify the `$checkInterval` variable (default: 2 seconds):
```powershell
$checkInterval = 2 # Check every 2 seconds
```

### Adjusting Auto-Close Timer

Modify the `$closeTimeout` variable to change how long the script waits before closing after MTG Arena exits (default: 10 seconds):
```powershell
$closeTimeout = 10 # Seconds to wait before auto-closing
```

## How It Works

1. **Process Detection**: Monitors for the MTGA.exe process
2. **Window Analysis**: Checks window dimensions and styles to determine fullscreen state
3. **Border Detection**: Verifies the window has no borders/caption (true fullscreen)
4. **Automatic Toggle**: Sends Alt+Enter key combination when fullscreen is lost
5. **Continuous Monitoring**: Repeats the check at regular intervals

## Files

- `Launch_MTGA.bat` - Convenience launcher for both game and monitor
- `MTGArenaFullscreenFix.ps1` - The main PowerShell monitoring script
- `README.md` - This file

## Troubleshooting

### Script Won't Run
If PowerShell execution policy prevents the script from running:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Wrong Steam Path
Edit `Launch_MTGA.bat` and update the Steam path:
```batch
start "" "YOUR_STEAM_PATH\steam.exe" -applaunch 2141910
```

### Different App ID
If you have MTG Arena installed differently, find the correct App ID and update it in `Launch_MTGA.bat`.

## Known Limitations

- Works with Steam version of MTG Arena
- Requires Windows PowerShell
- May briefly show the window border during the toggle operation

## License

This project is free to use and modify for personal use.

## Contributing

Feel free to submit issues or pull requests if you have improvements or find bugs.

---

**Note**: This tool does not modify the game files or inject any code. It simply monitors the window state and sends keyboard input.