#!/bin/sh

simProvider='giffgaff'
payloadLink='https://gist.githubusercontent.com/simplerick-simplefun/51762586531d6a9cb838c148b09e286d/raw/giffgaff.txt'
payloadSize=0
payloadSize_KB=0
payload=''
# Temporary file path (Works on both Linux and Android /data/local/tmp/)
tmpFile="payload.tmp"

# Cleared out invisible characters and optimized loop syntax
simInterface=$(for ip in $(ip route show | grep rmnet | awk '{print $NF}'); do
  if dumpsys telephony.registry 2>/dev/null | grep -i "${simProvider}" | grep "CONNECTED" | grep "rmnet" | grep -q "$ip"; then
    ip route show | grep "$ip" | awk '{print $3}'
    break # Exit loop early once found
  fi
done)

echo "The interface of ${simProvider} is: ${simInterface}"

#simInterface=eth0

if [ -n "${simInterface}" ]; then
  # -f forces curl to return an error code if the server drops a 404 or 500 error
  curl -s -f --interface "${simInterface}" --connect-timeout 5 "${payloadLink}" -o "$tmpFile"
  
  curlExitCode=$?
else
  echo "Error: Network interface for ${simProvider} not found."
  curlExitCode=1
fi

# 1. Check if curl downloaded the payload successfully (Exit code 0 means success)
if [ "$curlExitCode" -eq 0 ] && [ -f "$tmpFile" ]; then
  # 2. Safely get the file size in bytes using 'wc -c'
  payloadSize=$(wc -c < "$tmpFile" | tr -d '[:space:]')
  # Clean up the file immediately after getting the size
  rm -f "$tmpFile"
else
  echo "Error: Curl failed to download the payload correctly."
  payloadSize=0
  rm -f "$tmpFile"
fi

# Ensure payloadSize defaults to 0 if anything went sideways
payloadSize=${payloadSize:-0}

# Final logic checks, size: 120KB>payload<150KB
if [ "$payloadSize" -gt 122880 ] && [ "$payloadSize" -lt 153600 ]; then
  payloadSize_KB=$(( payloadSize / 1024 ))
  echo "BaoHao ChengGong, payload size is ${payloadSize_KB} KB."
else
  payloadSize_KB=$(( payloadSize / 1024 ))
  echo "BaoHao ShiBai, payload size is ${payloadSize_KB} KB."
fi
