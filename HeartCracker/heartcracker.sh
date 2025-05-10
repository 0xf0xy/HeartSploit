#!/bin/bash

RED="\033[1;31m"
GREEN="\033[1;32m"
BLUE="\033[1;34m"
RESET="\033[0m"

especial_date="14:02:25"
current_time=$(date +"%H:%M")

bssid="${especial_date}:00:${current_time}"
essid=""
channel=""
target="${especial_date}:1L:0V:3U"
wordlist="iloveyou.txt"

user=$(whoami)

while getopts "e:c:w:h" opt; do
  case $opt in
    e) essid="$OPTARG" ;;
    c) channel="$OPTARG" ;;
    w) wordlist="$OPTARG" ;;
    h) echo "Usage: $0 -e <essid> -c <channel> -w <wordlist> [-h]"; exit 1 ;;
  esac
done

if [[ -z "$essid" || -z "$channel" ]]; then
  echo -e "${RED}Error: ESSID or channel not passed.${RESET}"
  exit 1
fi

clear
echo -e "\nStarting ${RED}HeartCracker${RESET} v1.0"
sleep 1
echo -e "\n[${GREEN}+${RESET}] wlan0 monitor mode ${GREEN}ENABLED${RESET}"
sleep 2
clear
echo -e "\n[${BLUE}*${RESET}] Monitoring ${BLUE}${essid}${RESET} on channel ${channel}..."

echo -e "\nBSSID              PWR  Beacons    #Data, #/s  CH  MB   ENC  CIPHER AUTH ESSID"
echo -e "${bssid}   -35      110       0     0   ${channel}  54e  WPA2 CCMP   PSK  ${essid}\n"

for i in {1..10}; do
    rx=$((i * 1024))
    tx=$((i * 2))
    elapsed="00:00:0$i"
    echo -ne "\rCH ${channel} ][ Elapsed: ${elapsed} | rx: ${rx} | tx: ${tx}    "
    sleep 1
done

echo -e "\n\n[${RED}-${RESET}] ${RED}Handshake not found!${RESET}"
sleep 1
clear
echo -e "\n[${BLUE}*${RESET}] Starting deauth attack on ${BLUE}${essid}${RESET} (${bssid})..."
sleep 1

for i in {1..10}; do
    echo -ne "\r[${GREEN}+${RESET}] Injecting deauth packet: ESSID=${essid}, Target=${target}, Channel=${channel} - (${i}0 packets sent)"
    sleep 0.5
done

clear
echo -e "\n[${BLUE}*${RESET}] Waiting for reauthentication..."
echo -e "\nBSSID              PWR  Beacons    #Data, #/s  CH  MB   ENC  CIPHER AUTH ESSID"
echo -e "${bssid}   -35      110       0     0   ${channel}  54e  WPA2 CCMP   PSK  ${essid}\n"

for i in {1..5}; do
    rx=$((i * 1024))
    tx=$((i * 2))
    elapsed="00:00:0$i"
    echo -ne "\rCH ${channel} ][ Elapsed: ${elapsed} | rx: ${rx} | tx: ${tx}    "
    sleep 1
done

echo "[WPA handshake]"
sleep 1
echo -e "\n[${GREEN}+${RESET}] ${GREEN}Handshake captured successfully!${RESET}"

cat <<EOF > "$essid.cap"
# HeartCracker Capture File
# ESSID: $essid
# BSSID: $bssid
# Channel: $channel
# Timestamp: $(date)

[Handshake Packet]
From: $user
To: $essid
Message: I was a lost signal… until you connected.

[Deauth Attack Log]
Reason: Too much love in the air
Injected by: HeartCracker

[End of Capture]
EOF
sleep 1

echo -e "[${GREEN}+${RESET}] Saved to ${GREEN}${essid}.cap${RESET}..."
sleep 2

clear
echo -e "\n[${BLUE}*${RESET}] Starting brute-force with ${BLUE}${wordlist}${RESET}..."

while IFS= read -r line; do
  sleep 2
  if [[ "$line" == "I love you, \${essid}!" ]]; then
    echo -ne "\r\033[K[${GREEN}+${RESET}] Key found! Password: ${GREEN}${line//\$\{essid\}/$essid}${RESET}"
    exit 0
  else
    echo -ne "\r\033[K[${BLUE}*${RESET}] Trying: ${BLUE}${line//\$\{essid\}/$essid}${RESET}"
  fi
done < "$wordlist"

echo -e "\n${RED}No key matched... ${essid}'s heart can't be cracked!${RESET}"
sleep 1
exit 1
