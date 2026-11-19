#!/bin/sh
# cycle-workspace.sh next|prev — rotation circulaire des workspaces 1..5
nxt=$(python3 -c "import json, subprocess
try:
    ws = json.loads(subprocess.check_output(['swaymsg', '-t', 'get_workspaces', '-r']))
    cur = next((w['num'] for w in ws if w.get('focused')), 1)
    nxt = ((cur + 3) % 5 + 1) if '$1' == 'prev' else ((cur % 5) + 1)
    print(nxt)
except Exception:
    print(1)
")
swaymsg workspace number "$nxt"
