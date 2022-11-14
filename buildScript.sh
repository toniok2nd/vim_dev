

cat template |sed -e "/<<<PAT>>>/r bashrcFile" -e "s/<<<PAT>>>//g" -e "/<<<PAT2>>>/r tmuxFile" -e "s/<<<PAT2>>>//g" > out.sh
bash out.sh
