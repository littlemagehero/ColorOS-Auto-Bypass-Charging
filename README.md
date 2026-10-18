# ColorOS Auto Bypass Charging

Experimental KernelSU / Magisk module that turns on bypass charging on ColorOS automatically when you plug in a charger.

## How it works
- Listens for Android's `battery_status` events (no polling, no logs).
- On plug-in with battery above 20%, checks `settings get system bypass_charge_state`. If bypass is already on it does nothing; otherwise it runs
  `cmd statusbar click-tile com.oplus.battery/com.oplus.powermanager.fuelgaue.bypasscharge.BypassChargeTile`
- It retries a few times if ColorOS is not ready yet.
- ColorOS turns bypass off again by itself on unplug or when it reaches your charge limit.

## Action button
Shows charger, level, temperature, voltage, battery current, the real bypass state and your charge limit.

## Requirements
- ColorOS with a bypass charging quick-settings tile (kept in the Quick Settings panel)
- KernelSU or Magisk

## Notes
- The tile name may differ or change between ColorOS versions. Test it first:
  `su -c 'cmd statusbar click-tile <component>'`
- Experimental: use at your own risk.

See [CHANGELOG.md](CHANGELOG.md) for version history.
