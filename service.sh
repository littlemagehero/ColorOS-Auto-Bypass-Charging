#!/system/bin/sh
LIVE=/data/adb/modules/coloros_autobypass
PROP=$LIVE/module.prop
CONF=/data/adb/coloros_autobypass.conf
TILE="com.oplus.battery/com.oplus.powermanager.fuelgaue.bypasscharge.BypassChargeTile"
PLUGGED="(AC|USB) powered: true"   # wired only: ColorOS bypass needs a wired charger

until [ "$(getprop sys.boot_completed)" = "1" ]; do sleep 3; done
if [ "$1" = "now" ]; then
  # Hot install: once the installer is done, clear its "pending update" flag so the manager's switch works
  ( sleep 10; rm -f "$LIVE/update" ) &
else
  sleep 20
fi

st=$(settings get system bypass_charge_state 2>/dev/null)
if [ "$st" = "0" ] || [ "$st" = "1" ]; then
  M="settings key ✅"
elif dumpsys package com.oplus.battery 2>/dev/null | grep -q "BypassChargeTile"; then
  M="tile fallback ✅"
else
  M="not found ⚠️"
fi
sed -i "s#^description=.*#description=status: active ✅ | method: $M#" "$PROP" 2>/dev/null

# Config file values (digits only)
conf() { sed -n "s/^$1=\([0-9]*\).*/\1/p" "$CONF" 2>/dev/null | head -n 1; }

# Optional: apply THRESHOLD from the config file (20/40/60/80, or 1-100 when ADVANCED=1)
set_threshold() {
  t=$(conf THRESHOLD)
  case "$t" in ''|*[!0-9]*) return ;; esac
  if [ "$(conf ADVANCED)" = "1" ]; then
    [ "$t" -ge 1 ] && [ "$t" -le 100 ] || return
  else
    case "$t" in 20|40|60|80) ;; *) return ;; esac
  fi
  [ "$(settings get system bypass_charge_value 2>/dev/null)" = "$t" ] ||
    settings put system bypass_charge_value "$t" 2>/dev/null
}

# Turn bypass on: write the settings key; fall back to the tile if it does not stick
fire() {
  sleep "$1"
  [ -e "$LIVE/disable" ] && return   # module switched off in the manager
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
