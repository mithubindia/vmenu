find /home/gs/Projects/vmenu -type f -name "*.sh" \
  -exec sed -i 's|^REPO_URL="https://raw.githubusercontent.com/MacRimi/vmenu/main"$|REPO_URL="https://raw.githubusercontent.com/mithubindia/vmenu/main"|' {} +
