# Changelog

## [0.3.4] - 2026-10-18
- README explains why the module exists. Simpler changelog.
- Small code cleanup.
- The module manager can check GitHub for updates (stable releases only).
- Bypass now turns on at any battery level.
- Only reacts to wired chargers.
- Optional config file to set the threshold.

## [0.3.3] - 2026-10-18
- Update the module without rebooting.

## [0.3.2] - 2026-10-18
- Action button: turns bypass on if it is off while charging, and says "discharging" when unplugged.
- Action button shows three current readings again.

## [0.3.1] - 2026-10-18
- Action button shows the real bypass state.
- Code cleanup.

## [0.3.0] - 2026-10-18
- Turns bypass on directly instead of clicking the tile (the tile is now a fallback).

## [0.2.0] - 2026-10-18
- Works after a reboot while charging, and retries if ColorOS is not ready yet.
- No longer switches bypass off by clicking twice.

## [0.1.0] - 2026-10-18
- First version: turns on bypass charging when you plug in above 20% battery.
