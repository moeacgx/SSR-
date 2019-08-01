#!/system/bin/sh
cd "${0%/*}"
./start.sh S
sleep 1
./check.sh