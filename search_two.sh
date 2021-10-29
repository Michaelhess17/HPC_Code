find . -maxdepth 1 -type d | egrep "P[0-9]|#" | grep -v "stim"| grep -v -i "bad"
