#!/system/bin/sh
BAT=/sys/class/power_supply/battery
rd() { [ -r "$BAT/$1" ] && cat "$BAT/$1" 2>/dev/null; }
toma() { v=${1#-}; v=${v:-0}; [ "$v" -gt 20000 ] 2>/dev/null && v=$((v / 1000)); echo "$v"; }

PWR=$(dumpsys battery 2>/dev/null | grep -E "(AC|USB|Wireless|Dock) powered: true" | sed 's/ powered: true//; s/^ *//' | tr '\n' ' ')
echo "Battery : $(rd capacity)% ($(rd status))"
echo "Charger : ${PWR:-not plugged in}"
t=$(rd temp); [ -n "$t" ] && echo "Temp    : $((t / 10)).$((t % 10)) C"
v=$(rd voltage_now); [ -n "$v" ] && echo "Voltage : $((v / 1000)) mV"

sum=0
for i in 1 2 3; do
  sum=$((sum + $(toma "$(rd current_now)")))
  [ "$i" -lt 3 ] && sleep 1
done
echo "Current : $((sum / 3)) mA (avg of 3)"

ST=$(settings get system bypass_charge_state 2>/dev/null)
LIM=$(settings get system bypass_charge_value 2>/dev/null)
[ -n "$LIM" ] && [ "$LIM" != "null" ] && echo "Limit   : $LIM%"
case "$ST" in
  1) echo "Bypass  : ON ✅ (system state = 1)" ;;
  0) echo "Bypass  : OFF (system state = 0)" ;;
  *) echo "Bypass  : unknown (bypass_charge_state key not found)" ;;
esac
