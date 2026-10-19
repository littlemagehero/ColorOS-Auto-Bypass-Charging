#!/system/bin/sh
PROP=/data/adb/modules/coloros_autobypass/module.prop
CONF=/data/adb/coloros_autobypass.conf
TILE="com.oplus.battery/com.oplus.powermanager.fuelgaue.bypasscharge.BypassChargeTile"
PLUGGED="(AC|USB) powered: true"   # wired only: ColorOS bypass needs a wired charger

until [ "$(getprop sys.boot_completed)" = "1" ]; do sleep 3; done
[ "$1" = "now" ] || sleep 20   # "now" = hot install, skip the boot wait

st=$(settings get system bypass_charge_state 2>/dev/null)
if [ "$st" = "0" ] || [ "$st" = "1" ]; then
  M="settings key ✅"
elif dumpsys package com.oplus.battery 2>/dev/null | grep -q "BypassChargeTile"; then
  M="tile fallback ✅"
else
  M="not found ⚠️"
fi
sed -i "s#^description=.*#description=status: active ✅ | method: $M#" "$PROP" 2>/dev/null

# Optional: apply THRESHOLD=20|40|60|80 from the config file, if it exists
set_threshold() {
  t=$(sed -n 's/^THRESHOLD=\([0-9]*\).*/\1/p' "$CONF" 2>/dev/null | head -n 1)
  case "$t" in 20|40|60|80) ;; *) return ;; esac
  [ "$(settings get system bypass_charge_value 2>/dev/null)" = "$t" ] ||
    settings put system bypass_charge_value "$t" 2>/dev/null
}

# Turn bypass on: write the settings key; fall back to the tile if it does not stick
fire() {
  sleep "$1"
  set_threshold
  i=0
  while [ "$i" -lt 3 ]; do
    st=$(settings get system bypass_charge_state 2>/dev/null)
    [ "$st" = "1" ] && return
    dumpsys battery 2>/dev/null | grep -qE "$PLUGGED" || return
    if [ "$st" = "0" ]; then
      settings put system bypass_charge_state 1 2>/dev/null
      sleep 2
      [ "$(settings get system bypass_charge_state 2>/dev/null)" = "1" ] && return
    fi
    cmd statusbar click-tile "$TILE" >/dev/null 2>&1
    [ "$st" = "0" ] || return   # key missing: single tile click, no retries
    sleep 3
    i=$((i + 1))
  done
}

was=0
first=1
# Already plugged in when the script starts (reboot while charging)
if dumpsys battery 2>/dev/null | grep -qE "$PLUGGED"; then
  was=1
  first=0
  fire 6 &
fi

logcat -b events -T 1 -s battery_status 2>/dev/null | while read -r line; do
  case "$line" in *battery_status*) ;; *) continue ;; esac
  p=${line#*\[}
  p=${p%\]*}
  IFS=,
  set -- $p
  unset IFS
  if [ "${4:-0}" -gt 0 ] 2>/dev/null; then
    if [ "$was" -eq 0 ]; then
      was=1
      d=2
      [ "$first" -eq 1 ] && d=6
      first=0
      fire "$d"
    fi
  elif [ "$was" -eq 1 ]; then
    # Ignore brief plugged=0 flickers: only a real unplug re-arms the trigger
    sleep 2
    dumpsys battery 2>/dev/null | grep -qE "$PLUGGED" || was=0
  fi
done
