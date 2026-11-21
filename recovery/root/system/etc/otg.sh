#!/system/bin/sh
L=/tmp/otg.log
ROLE=/sys/class/usb_role/mt_usb-role-switch/role

R=
n=0
while [ $n -lt 60 ]; do
  for f in /sys/bus/i2c/devices/*/sc8950_registers_debug; do
    [ -e "$f" ] && R=$f
  done
  [ -n "$R" ] && break
  n=$((n+1)); sleep 1
done
[ -n "$R" ] || { echo "sc8950_registers_debug not found" >> $L; exit 1; }

rd() { grep "Reg\[$1\]" $R | sed 's/.*0x//'; }
wr() { echo "$1 $2" > $R; }

state=off
kp=

keeper() {
  while true; do wr 03 2a; sleep 1; done
}

do_on() {
  [ $state = on ] && return
  i=0
  while [ $i -lt 25 ]; do
    v=$(rd 0B)
    [ -n "$v" ] && [ $(( 0x$v & 0xe0 )) -eq 0 ] && break
    i=$((i+1)); sleep 0.2
  done
  [ $i -lt 25 ] || { echo "$(date +%T) skip ON: external VBUS" >> $L; return; }
  o00=$(rd 00); o03=$(rd 03); o0a=$(rd 0A)
  echo host > $ROLE
  wr 0a f6; wr 00 40; wr 03 2a
  keeper &
  kp=$!
  state=on
  echo "$(date +%T) ON (saved 00=$o00 03=$o03 0A=$o0a)" >> $L
}

do_off() {
  [ $state = on ] || return
  kill $kp 2>/dev/null; wait $kp 2>/dev/null
  wr 03 $o03; wr 00 $o00; wr 0a $o0a
  state=off
  echo "$(date +%T) OFF" >> $L
}

M="otg_fix marker $$ $(date +%s)"
echo "$M" > /dev/kmsg

ready=0
cat /dev/kmsg | while read -r line; do
  if [ $ready = 0 ]; then
    case "$line" in
      *"$M"*)
        ready=1
        last=$(dmesg | grep 'extcon_usb: source vbus' | tail -n 1)
        case "$last" in *5000mv*) do_on;; esac
        ;;
    esac
    continue
  fi
  case "$line" in
    *'source vbus = 5000mv'*) do_on;;
    *'source vbus = 0mv'*)    do_off;;
    *'vbus ocp'*)             echo "$(date +%T) $line" >> $L;;
  esac
done
