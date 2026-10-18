# ColorOS Auto Bypass Charging

Experimental KernelSU / Magisk module that turns on bypass charging on ColorOS automatically when you plug in a charger.

## How it works
- Listens for Android's `battery_status` events (no polling, no logs).
- On plug-in with battery above 20%, reads `settings get system bypass_charge_state`. If bypass is already on it does nothing; if it is 0 it writes 1.
- If the write does not stick, or the key does not exist, it falls back to clicking the bypass tile:
  `cmd statusbar click-tile com.oplus.battery/com.oplus.powermanager.fuelgaue.bypasscharge.BypassChargeTile`
- ColorOS turns bypass off again by itself on unplug or when it reaches your charge limit.

## Action button
- **Charging, bypass on:** shows the status (battery, charger, limit, temperature, voltage and three current samples with their average). Changes nothing.
- **Charging, bypass off** (for example ColorOS switched it off at your limit): turns bypass on and reports the result.
- **Not charging:** says the phone is discharging and changes nothing.

It only runs when you press Action, so there is no background overhead.

## Requirements
- ColorOS with the `bypass_charge_state` system setting (the Quick Settings tile is only a fallback)
- KernelSU or Magisk

## Tested on
- Device: OnePlus Ace 6T
- ColorOS 16/17

## Notes
- Check that the key exists on your device: `settings get system bypass_charge_state` should print 0 or 1.
- The fallback tile name may differ between ColorOS versions.
- Experimental: use at your own risk.

See [CHANGELOG.md](CHANGELOG.md) for version history.
