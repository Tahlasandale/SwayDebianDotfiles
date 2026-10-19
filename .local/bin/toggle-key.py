#!/usr/bin/env python3
# toggle-key.py — Bascule l'état de CapsLock ou NumLock au niveau matériel (Linux evdev)
import glob
import struct
import sys
import time

target = sys.argv[1].lower() if len(sys.argv) > 1 else 'caps'
code = 58 if 'caps' in target else 69  # KEY_CAPSLOCK = 58, KEY_NUMLOCK = 69

EV_KEY = 1
EV_SYN = 0
SYN_REPORT = 0

# Trouve les claviers physiques
devs = glob.glob('/dev/input/by-path/*-event-kbd')
if not devs:
    devs = ['/dev/input/event0']

for dev in devs:
    try:
        with open(dev, 'wb') as f:
            now = time.time()
            sec = int(now)
            usec = int((now - sec) * 1000000)
            ev_press = struct.pack('qqHHi', sec, usec, EV_KEY, code, 1)
            ev_syn = struct.pack('qqHHi', sec, usec, EV_SYN, SYN_REPORT, 0)
            f.write(ev_press + ev_syn)
            f.flush()

            time.sleep(0.02)

            now = time.time()
            sec = int(now)
            usec = int((now - sec) * 1000000)
            ev_release = struct.pack('qqHHi', sec, usec, EV_KEY, code, 0)
            ev_syn = struct.pack('qqHHi', sec, usec, EV_SYN, SYN_REPORT, 0)
            f.write(ev_release + ev_syn)
            f.flush()
    except (PermissionError, OSError):
        pass
