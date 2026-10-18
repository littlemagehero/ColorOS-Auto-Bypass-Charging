# Hot install: apply the new version without a reboot
MODID=coloros_autobypass
LIVE=/data/adb/modules/$MODID

# Refresh the live copies so the Action button uses the new scripts right away
if [ -d "$LIVE" ]; then
  for f in service.sh action.sh; do
    cp -f "$MODPATH/$f" "$LIVE/$f" 2>/dev/null && chmod 755 "$LIVE/$f"
  done
fi
chmod 755 "$MODPATH/service.sh" "$MODPATH/action.sh"

# Stop the running copy (and its logcat), then start the new one
for p in /proc/[0-9]*; do
  pid=${p#/proc/}
  [ "$pid" = "$$" ] && continue
  case "$(tr '\0' ' ' < "$p/cmdline" 2>/dev/null)" in
    *"$MODID/service.sh"*|*"logcat -b events -T 1 -s battery_status"*) kill "$pid" 2>/dev/null ;;
  esac
done
nohup sh "$MODPATH/service.sh" now >/dev/null 2>&1 &
ui_print "- Started without reboot (a reboot is still fine)"
