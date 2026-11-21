# ColorOS Auto Bypass Charging

Experimental KernelSU / Magisk module that turns on bypass charging on ColorOS automatically when you plug in a charger.

This module is created because ColorOS only supports auto bypass charging when playing games.

## How it works
- Only reacts to wired chargers, because ColorOS bypass needs one.
- Listens for Android's `battery_status` events (no polling, no logs).
- On plug-in, reads `settings get system bypass_charge_state`. If bypass is already on it does nothing; if it is 0 it writes 1.
- If the write does not stick, or the key does not exist, it falls back to clicking the bypass tile:
  `cmd statusbar click-tile com.oplus.battery/com.oplus.powermanager.fuelgaue.bypasscharge.BypassChargeTile`
- It retries a few times if ColorOS is not ready yet.
- ColorOS turns bypass off again by itself on unplug or when it reaches your charge limit.

## WebUI
Open the module's WebUI from KernelSU (or WebUI X on Magisk). It shows the battery and bypass state as soon as it opens, lets you switch bypass, and sets the threshold with a slider (20, 40, 60 or 80). Live battery current is off by default, reads every 5 seconds, and only runs while the page is open.

The menu (top right) has **Advanced options**. Turning it on, after accepting the terms, replaces the slider with a field where you can type any threshold from 1 to 100. More advanced options will be added there. The WebUI is only static files, so it uses nothing when it is not open.

## Action button
- **Charging, bypass on:** shows the status (battery, charger, limit, temperature, voltage and three current samples with their average). Changes nothing.
- **Charging, bypass off** (for example ColorOS switched it off at your limit): turns bypass on and reports the result.
- **Not charging:** says the phone is discharging and changes nothing.

It only runs when you press Action, so there is no background overhead.

## Optional: set the threshold
ColorOS lets you pick the bypass threshold in Settings. To have the module apply it instead, create `/data/adb/coloros_autobypass.conf` containing `THRESHOLD=80` (20, 40, 60 or 80). The value is applied each time you plug in. Without the file, the module never touches your threshold. The WebUI writes this file for you.

## Requirements
- ColorOS with the `bypass_charge_state` system setting (the Quick Settings tile is only a fallback)
- A wired charger
- KernelSU or Magisk

## Tested on
- Device: OnePlus Ace 6T
- ColorOS 16/17

## Notes
- Check that the key exists on your device: `settings get system bypass_charge_state` should print 0 or 1.
- The fallback tile name may differ between ColorOS versions.
- Experimental: use at your own risk.

See [CHANGELOG.md](CHANGELOG.md) for version history.
