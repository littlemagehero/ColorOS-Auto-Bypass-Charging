#!/system/bin/sh
BAT=/sys/class/power_supply/battery
rd() { [ -r "$BAT/$1" ] && cat "$BAT/$1" 2>/dev/null; }
toma() { v=${1#-}; v=${v:-0}; [ "$v" -gt 20000 ] 2>/dev/null && v=$((v / 1000)); echo "$v"; }

PWR=$(dumpsys battery 2>/dev/null | grep -E "(AC|USB|Wireless) powered: true" | sed 's/ powered: true//; s/^ *//' | tr '\n' ' ')
echo "Battery : $(rd capacity)% ($(rd status))"
echo "Charger : ${PWR:-not plugged in}"
t=$(rd temp); [ -n "$t" ] && echo "Temp    : $((t / 10)).$((t % 10)) C"
v=$(rd voltage_now); [ -n "$v" ] && echo "Voltage : $((v / 1000)) mV"

echo "Current (3 samples):"
sum=0
for i in 1 2 3; do
  m=$(toma "$(rd current_now)")
  echo "  $m mA"
  sum=$((sum + m))
  [ "$i" -lt 3 ] && sleep 1
done
avg=$((sum / 3))
echo "Average : $avg mA"

if dumpsys package com.oplus.battery 2>/dev/null | grep -q "BypassChargeTile"; then
  echo "Tile    : found"
else
  echo "Tile    : NOT found (ColorOS update?)"
fi

ST=$(settings get system bypass_charge_state 2>/dev/null)
LIM=$(settings get system bypass_charge_value 2>/dev/null)
[ -n "$LIM" ] && [ "$LIM" != "null" ] && echo "Limit   : $LIM%"
case "$ST" in
  1) echo "Bypass  : ON ✅ (system state = 1)" ;;
  0) echo "Bypass  : OFF (system state = 0)" ;;
  *)
    if [ -z "$PWR" ]; then
      echo "Bypass  : unknown (not plugged in)"
    elif [ "$avg" -lt 200 ]; then
      echo "Bypass  : LIKELY ON (state unreadable, current near 0)"
    else
      echo "Bypass  : appears OFF (state unreadable, current above 200 mA)"
    fi ;;
esac
