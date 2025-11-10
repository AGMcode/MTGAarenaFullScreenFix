# MTG Arena Fullscreen Fix
# Monitors MTG Arena and automatically toggles fullscreen when the window loses fullscreen mode

Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    public class WinAPI {
        [DllImport("user32.dll")]
        public static extern IntPtr GetForegroundWindow();
        
        [DllImport("user32.dll")]
        public static extern bool SetForegroundWindow(IntPtr hWnd);
        
        [DllImport("user32.dll")]
        public static extern int GetWindowLong(IntPtr hWnd, int nIndex);
        
        [DllImport("user32.dll")]
        public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
        
        [StructLayout(LayoutKind.Sequential)]
        public struct RECT {
            public int Left;
            public int Top;
            public int Right;
            public int Bottom;
        }
        
        public const int GWL_STYLE = -16;
        public const uint WS_BORDER = 0x00800000;
        public const uint WS_CAPTION = 0x00C00000;
    }
"@

function Send-AltEnter {
    param([IntPtr]$WindowHandle)
    
    # Bring window to foreground
    [WinAPI]::SetForegroundWindow($WindowHandle) | Out-Null
    Start-Sleep -Milliseconds 200
    
    # Create shell object to send keys
    $wshell = New-Object -ComObject wscript.shell
    $wshell.SendKeys("%{ENTER}")
    
    Write-Host "$(Get-Date -Format 'HH:mm:ss') - Sent Alt+Enter to toggle fullscreen" -ForegroundColor Green
}

function Test-IsFullscreen {
    param([IntPtr]$WindowHandle)
    
    $rect = New-Object WinAPI+RECT
    [WinAPI]::GetWindowRect($WindowHandle, [ref]$rect) | Out-Null
    
    # Get screen dimensions
    Add-Type -AssemblyName System.Windows.Forms
    $screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
    
    # Check if window covers entire screen
    $isFullSize = ($rect.Left -le 0) -and ($rect.Top -le 0) -and 
                  ($rect.Right -ge $screen.Width) -and ($rect.Bottom -ge $screen.Height)
    
    # Check window style (no border/caption = likely fullscreen)
    $style = [WinAPI]::GetWindowLong($WindowHandle, [WinAPI]::GWL_STYLE)
    $hasBorder = ($style -band [WinAPI]::WS_CAPTION) -ne 0
    
    return $isFullSize -and -not $hasBorder
}

Write-Host "MTG Arena Fullscreen Monitor Started" -ForegroundColor Cyan
Write-Host "Waiting for MTGA.exe process..." -ForegroundColor Yellow
Write-Host "Press Ctrl+C to stop monitoring`n" -ForegroundColor Yellow

$initialCheckDone = $false
$checkInterval = 2 # Check every 2 seconds
$processWasRunning = $false
$closeTimeout = 10 # Seconds to wait before auto-closing after MTG Arena exits

while ($true) {
    try {
        # Find MTG Arena process
        $process = Get-Process -Name "MTGA" -ErrorAction SilentlyContinue
        
        if ($process -and $process.MainWindowHandle -ne [IntPtr]::Zero) {
            $windowHandle = $process.MainWindowHandle
            $processWasRunning = $true
            
            if (-not $initialCheckDone) {
                Write-Host "$(Get-Date -Format 'HH:mm:ss') - Found MTG Arena (PID: $($process.Id))" -ForegroundColor Green
                Write-Host "$(Get-Date -Format 'HH:mm:ss') - Performing initial fullscreen check..." -ForegroundColor Yellow
                
                # Wait a moment for the window to initialize
                Start-Sleep -Seconds 2
                
                $isFullscreen = Test-IsFullscreen -WindowHandle $windowHandle
                
                if (-not $isFullscreen) {
                    Write-Host "$(Get-Date -Format 'HH:mm:ss') - Window is not fullscreen, forcing fullscreen mode..." -ForegroundColor Yellow
                    Send-AltEnter -WindowHandle $windowHandle
                } else {
                    Write-Host "$(Get-Date -Format 'HH:mm:ss') - Window is already fullscreen" -ForegroundColor Green
                }
                
                $initialCheckDone = $true
                Write-Host "$(Get-Date -Format 'HH:mm:ss') - Now monitoring every $checkInterval seconds...`n" -ForegroundColor Cyan
            }
            
            # Periodic check
            $isFullscreen = Test-IsFullscreen -WindowHandle $windowHandle
            
            if (-not $isFullscreen) {
                Write-Host "$(Get-Date -Format 'HH:mm:ss') - Fullscreen lost! Restoring..." -ForegroundColor Red
                Send-AltEnter -WindowHandle $windowHandle
            }
        }
        else {
            if ($initialCheckDone) {
                Write-Host "$(Get-Date -Format 'HH:mm:ss') - MTG Arena closed. Exiting in $closeTimeout seconds..." -ForegroundColor Yellow
                
                # Wait a bit to see if process restarts
                for ($i = $closeTimeout; $i -gt 0; $i--) {
                    Start-Sleep -Seconds 1
                    $checkProcess = Get-Process -Name "MTGA" -ErrorAction SilentlyContinue
                    if ($checkProcess) {
                        Write-Host "$(Get-Date -Format 'HH:mm:ss') - MTG Arena restarted, resuming monitoring..." -ForegroundColor Green
                        $initialCheckDone = $false
                        break
                    }
                    if ($i -le 3) {
                        Write-Host "$i..." -ForegroundColor Yellow
                    }
                }
                
                # If still not running, exit
                $finalCheck = Get-Process -Name "MTGA" -ErrorAction SilentlyContinue
                if (-not $finalCheck) {
                    Write-Host "`n$(Get-Date -Format 'HH:mm:ss') - MTG Arena has closed. Exiting monitor." -ForegroundColor Cyan
                    exit 0
                }
            }
            elseif ($processWasRunning) {
                # Process was running but now it's not, and we haven't done initial check yet
                Write-Host "$(Get-Date -Format 'HH:mm:ss') - MTG Arena closed before initialization. Exiting..." -ForegroundColor Yellow
                exit 0
            }
        }
        
        Start-Sleep -Seconds $checkInterval
    }
    catch {
        Write-Host "Error: $_" -ForegroundColor Red
        Start-Sleep -Seconds $checkInterval
    }
}
