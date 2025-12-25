"""
Python-based keyboard automation script
Requires: pip install keyboard pyautogui psutil pyperclip pywin32
"""

import os
import time
import psutil
import pyautogui
import pyperclip
import keyboard
from pathlib import Path
import win32gui
import win32process
import win32con
import subprocess
import tkinter as tk
from tkinter import simpledialog
import threading

# Screen center coordinates
SCREEN_WIDTH, SCREEN_HEIGHT = pyautogui.size()
CENTER_X = SCREEN_WIDTH // 2
CENTER_Y = SCREEN_HEIGHT // 2

class KeyboardAutomation:
    def __init__(self):
        self.actions = self._setup_actions()
        self.dialog_active = False
        
    def _setup_actions(self):
        """Define all automation actions"""
        return {
            # App launch/activate
            'vc': lambda: self.activate_or_run_exe(
                Path(os.getenv('LOCALAPPDATA')) / 'Programs' / 'Microsoft VS Code' / 'Code.exe'
            ),
            'eg': lambda: self.activate_or_run_exe(
                r'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
            ),
            'wt': lambda: self.activate_or_run_class(
                'CASCADIA_HOSTING_WINDOW_CLASS',
                Path(os.getenv('LOCALAPPDATA')) / 'Microsoft' / 'WindowsApps' / 'wt.exe'
            ),
            'ch': lambda: self.activate_or_run_class(
                'Chrome_WidgetWin_1',
                r'C:\Program Files\Google\Chrome\Application\chrome.exe'
            ),
            'vm': lambda: self.activate_or_run_exe(r'd:\apps\Vim\vim91\gvim.exe'),
            
            # Window operations
            'x': lambda: self.send_keys('alt+f4'),
            'mx': lambda: self.maximize_active(),
            'mmc': lambda: self.move_mouse_active_center(),
            'mmsc': lambda: self.click_screen_center(),
            'lm': lambda: pyautogui.click()
        }
    
    def send_keys(self, *key_sequences):
        """Send key sequences with keyboard library"""
        for seq in key_sequences:
            keyboard.send(seq)
            time.sleep(0.05)
    
    def get_exe_name(self, path):
        """Extract executable name from path"""
        return Path(path).name
    
    def find_window_by_exe(self, exe_name):
        """Find window by executable name"""
        def callback(hwnd, windows):
            if win32gui.IsWindowVisible(hwnd):
                try:
                    _, pid = win32process.GetWindowThreadProcessId(hwnd)
                    process = psutil.Process(pid)
                    if process.name().lower() == exe_name.lower():
                        windows.append(hwnd)
                except:
                    pass
            return True
        
        windows = []
        win32gui.EnumWindows(callback, windows)
        return windows[0] if windows else None
    
    def find_window_by_class(self, class_name):
        """Find window by class name"""
        return win32gui.FindWindow(class_name, None)
    
    def activate_or_run_exe(self, path):
        """Activate window if exists, otherwise run executable"""
        path_str = str(path)
        exe_name = self.get_exe_name(path_str)
        hwnd = self.find_window_by_exe(exe_name)
        
        if hwnd:
            # Check if window is minimized
            if win32gui.IsIconic(hwnd):
                win32gui.ShowWindow(hwnd, win32con.SW_RESTORE)
            # Just bring to foreground without changing size
            win32gui.SetForegroundWindow(hwnd)
        else:
            subprocess.Popen(path_str)
    
    def activate_or_run_class(self, class_name, path=None):
        """Activate window by class name, or run if path provided"""
        hwnd = self.find_window_by_class(class_name)
        
        if hwnd:
            # Check if window is minimized
            if win32gui.IsIconic(hwnd):
                win32gui.ShowWindow(hwnd, win32con.SW_RESTORE)
            # Just bring to foreground without changing size
            win32gui.SetForegroundWindow(hwnd)
        elif path:
            subprocess.Popen(str(path))
    
    def maximize_active(self):
        """Maximize the active window"""
        hwnd = win32gui.GetForegroundWindow()
        if hwnd:
            win32gui.ShowWindow(hwnd, win32con.SW_MAXIMIZE)
    
    def move_mouse_active_center(self):
        """Move mouse to center of active window"""
        hwnd = win32gui.GetForegroundWindow()
        if hwnd:
            rect = win32gui.GetWindowRect(hwnd)
            x = (rect[0] + rect[2]) // 2
            y = (rect[1] + rect[3]) // 2
            pyautogui.moveTo(x, y, duration=0)
    
    def click_screen_center(self):
        """Click at screen center"""
        pyautogui.moveTo(CENTER_X, CENTER_Y, duration=0)
        pyautogui.click()
    
    def show_action_palette(self):
        """Show action palette dialog"""
        if self.dialog_active:
            return
        
        self.dialog_active = True
        
        # Save current window state
        original_hwnd = win32gui.GetForegroundWindow()
        original_placement = None
        if original_hwnd:
            try:
                original_placement = win32gui.GetWindowPlacement(original_hwnd)
            except:
                pass
        
        root = tk.Tk()
        root.withdraw()
        
        tokens = ", ".join(sorted(self.actions.keys()))
        result = simpledialog.askstring(
            "AHK v2 Actions",
            f"Enter action token:\n{tokens}",
            parent=root
        )
        
        root.destroy()
        
        # Execute action if provided
        if result:
            token = result.strip()
            if token in self.actions:
                self.actions[token]()
        
        # Restore original window state
        if original_hwnd and original_placement:
            try:
                time.sleep(0.1)  # Small delay to let the action complete
                if win32gui.IsWindow(original_hwnd):
                    # Only restore if window wasn't intentionally changed
                    current_hwnd = win32gui.GetForegroundWindow()
                    if current_hwnd == original_hwnd or not result:
                        win32gui.SetWindowPlacement(original_hwnd, original_placement)
            except:
                pass
        
        self.dialog_active = False

# Global automation instance
automation = KeyboardAutomation()

def setup_hotkeys():
    """Setup all hotkeys and key remappings"""
    
    # Custom CapsLock handler with threading to avoid blocking
    capslock_state = {'shift_held': False}
    
    def show_palette_async():
        """Show palette in a separate thread to avoid blocking the hook"""
        threading.Thread(target=automation.show_action_palette, daemon=True).start()
    
    def on_capslock(e):
        # Skip if dialog is active
        if automation.dialog_active:
            return True  # Let the key pass through normally
            
        if e.event_type == 'down':
            # Record shift state on key down
            capslock_state['shift_held'] = keyboard.is_pressed('shift')
            
        elif e.event_type == 'up':
            # On release, execute the appropriate action
            if capslock_state['shift_held']:
                # Use threading to avoid blocking the keyboard hook
                show_palette_async()
            else:
                keyboard.send('esc')
            
            capslock_state['shift_held'] = False
        
        # Always suppress the original CapsLock
        return False
    
    keyboard.hook_key('caps lock', on_capslock, suppress=True)
    
    # Kill switch - Ctrl+Shift+Alt+Q to exit the script
    keyboard.add_hotkey('ctrl+shift+alt+q', lambda: os._exit(0), suppress=True)
    
def main():
    """Main entry point"""
    print("Python Keyboard Automation Running...")
    print("Note: This script requires administrator privileges for global hotkeys")
    print("Press Ctrl+C to exit\n")
    print("Key bindings:")
    print("  CapsLock -> Escape")
    print("  Shift+CapsLock -> Action Palette")
    
    try:
        setup_hotkeys()
        print("\nHotkeys registered successfully!")
        keyboard.wait()  # Wait forever
    except KeyboardInterrupt:
        print("\nExiting...")
    except Exception as e:
        print(f"\nError: {e}")
        print("Make sure to run this script as Administrator!")

if __name__ == '__main__':
    main()
