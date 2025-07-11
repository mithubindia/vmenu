find /home/gs/Projects/vmenu -type f -name "*.sh" \
  -exec sed -i 's|^BASE_DIR="/usr/local/share/proxmenux"$|BASE_DIR="/usr/local/share/vmenu"|' {} +


#find /home/gs/Projects/vmenu -type f -name "*.sh" -exec sed -i 's/^BASE_DIR="/usr/local/share/proxmenux"$/BASE_DIR="/usr/local/share/vmenu"' {} +

#find /path/to/dir -type f -name "*.txt" -exec sed -i 's/^Old line text$/New line text/' {} +

