# Changelog

Versions follow `0.x.y` while the module is experimental.
Format based on [Keep a Changelog](https://keepachangelog.com/).

## [0.3.0] - 2026-10-18 (experimental)

### Changed
- Turns bypass on by writing `settings put system bypass_charge_state 1` directly, instead of clicking the Quick Settings tile. The tile no longer needs to stay in the panel.
- The tile click is now only a fallback: used if the key does not stick after the write, or if the key does not exist on the device (single click, no retries).
- Retries reduced to 3 attempts.
- The module description now shows the method in use (`settings key`, `tile fallback` or `not found`) instead of the tile check.

### Notes
- The key is only written while a charger is connected and the battery is above 20%.
- It is not written if the key is missing, to avoid creating unknown settings.
- Confirmed on the author's device that writing the key flips the Bypass charging toggle. Current drop while charging should be verified with the Action button.

## [0.2.0] - 2026-10-18 (experimental)

### Added
- Reads the real bypass state from `settings get system bypass_charge_state` (1 = on, 0 = off).
- Skips the click when bypass is already on, so the toggle can no longer switch it off by mistake.
- Retries up to 5 times, 3 seconds apart, until the state reads 1. This replaces the blind delay and should fix needing to plug in twice after a reboot.
- Action button now shows the real bypass state and the charge limit (`bypass_charge_value`).

### Changed
- Shorter initial delay (2 s, or 6 s for the first plug-in after boot) because retries now cover the case where ColorOS is not ready yet.
- If the state key is missing (other devices), the module falls back to a single click without retrying.
- The 20% battery check and the unplug debounce are unchanged.

### Known issues
- The tile class name is hardcoded and may change with ColorOS updates.
- The bypass tile must stay in the Quick Settings panel for the click to work.
- The `bypass_charge_state` key is confirmed only on the author's device.
- Unplugging and replugging within 2 seconds does not trigger a click.

## [0.1.0] - 2026-10-18 (experimental)

### Added
- Turns on bypass charging by clicking ColorOS's bypass quick-settings tile when a charger is plugged in and the battery is above 20%.
- Event-driven: waits on `battery_status` events from logcat, so there is no polling and no log files.
- Also triggers when the phone is already charging at boot.
- Longer delay for the first plug-in after boot, so ColorOS is ready.
- Debounce for brief `plugged=0` flickers: only a confirmed unplug re-arms the trigger (checked with `dumpsys battery`).
- Action button: charger type, battery level, temperature, voltage, current samples, tile check and an estimated bypass state.
- Module description shows whether the tile was found at boot.

### Known issues
- The tile class name is hardcoded and may change with ColorOS updates.
- Bypass detection in the Action button is an estimate (average battery current under 200 mA).
- The click is a toggle: if bypass is already on, it will turn it off.
- Unplugging and replugging within 2 seconds does not trigger a click.
- Only tested on the author's device.
