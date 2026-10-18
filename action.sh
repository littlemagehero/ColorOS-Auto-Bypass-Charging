#!/system/bin/sh
BAT=/sys/class/power_supply/battery
rd() { [ -r "$BAT/$1" ] && cat "$BAT/$1" 2>/dev/null; }
toma() { v=${1#-}; v=${v:-0}; [ "$v" -gt 20000 ] 2>/dev/null && v=$((v / 1000)); echo "$v"; }

PWR=$(dumpsys battery 2>/dev/null | grep -E "(AC|USB|Wireless|Dock) powered: true" | sed 's/ powered: true//; s/^ *//' | tr '\n' ' ')
echo "Battery : $(rd capacity)%"

# Not charging: nothing to do
if [ -z "$PWR" ]; then
  echo "Charger : not plugged in"
  echo "Status  : discharging"
  exit 0
fi

echo "Charger : $PWR"
LIM=$(settings get system bypass_charge_value 2>/dev/null)
case "$LIM" in ''|*[!0-9]*) ;; *) echo "Limit   : $LIM%" ;; esac

# Charging: show the bypass state, and turn bypass on if it is off
case "$(settings get system bypass_charge_state 2>/dev/null)" in
  1) echo "Bypass  : ON ✅" ;;
  0) settings put system bypass_charge_state 1 2>/dev/null
     sleep 2
     if [ "$(settings get system bypass_charge_state 2>/dev/null)" = "1" ]; then
       echo "Bypass  : was OFF, turned ON ✅"
     else
       echo "Bypass  : OFF, could not turn it on ⚠️"
     fi ;;
  *) echo "Bypass  : unknown (bypass_charge_state key not found)" ;;
esac

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
echo "Average : $((sum / 3)) mA"
