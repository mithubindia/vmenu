import type { Metadata } from "next"
import { Server } from "lucide-react"
import CopyableCode from "@/components/CopyableCode"

export const metadata: Metadata = {
  title: "ProxMenux Post-Install: System Settings",
  description:
    "Detailed guide to the System Settings category in the ProxMenux post-install script for Proxmox VE optimization.",
  openGraph: {
    title: "ProxMenux Post-Install: System Settings",
    description:
      "Detailed guide to the System Settings category in the ProxMenux post-install script for Proxmox VE optimization.",
    type: "article",
    url: "https://macrimi.github.io/ProxMenux/docs/post-install/system",
    images: [
      {
        url: "https://macrimi.github.io/ProxMenux/system-settings-image.png",
        width: 1200,
        height: 630,
        alt: "ProxMenux Post-Install System Settings",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "ProxMenux Post-Install: System Settings",
    description:
      "Detailed guide to the System Settings category in the ProxMenux post-install script for Proxmox VE optimization.",
    images: ["https://macrimi.github.io/ProxMenux/system-settings-image.png"],
  },
}

export default function SystemSettingsPage() {
  const fastRebootCode = `
# Install kexec-tools
sudo apt-get install -y kexec-tools

# Create kexec-pve service file
sudo tee /etc/systemd/system/kexec-pve.service > /dev/null <<EOF
[Unit]
Description=Loading new kernel into memory
Documentation=man:kexec(8)
DefaultDependencies=no
Before=reboot.target
RequiresMountsFor=/boot

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/sbin/kexec -d -l /boot/pve/vmlinuz --initrd=/boot/pve/initrd.img --reuse-cmdline

[Install]
WantedBy=default.target
EOF

# Enable the service
sudo systemctl enable kexec-pve.service

# Add alias for reboot-quick
echo "alias reboot-quick='systemctl kexec'" >> ~/.bash_profile
  `

  const kernelPanicCode = `
# Create kernel panic configuration file
sudo tee /etc/sysctl.d/99-kernelpanic.conf > /dev/null <<EOF
kernel.core_pattern = /var/crash/core.%t.%p
kernel.panic = 10
kernel.panic_on_oops = 1
kernel.hardlockup_panic = 1
EOF

# Apply the changes
sudo sysctl -p /etc/sysctl.d/99-kernelpanic.conf
  `

  const entropyCode = `
# Install haveged
sudo apt-get install -y haveged

# Configure haveged
sudo tee /etc/default/haveged > /dev/null <<EOF
DAEMON_ARGS="-w 1024"
EOF

# Enable haveged service
sudo systemctl enable haveged
  `

  const systemLimitsCode = `
# Increase max user watches
sudo tee /etc/sysctl.d/99-maxwatches.conf > /dev/null <<EOF
fs.inotify.max_user_watches = 1048576
fs.inotify.max_user_instances = 1048576
fs.inotify.max_queued_events = 1048576
EOF

# Increase max FD limit / ulimit
sudo tee /etc/security/limits.d/99-limits.conf > /dev/null <<EOF
* soft     nproc          1048576
* hard     nproc          1048576
* soft     nofile         1048576
* hard     nofile         1048576
root soft     nproc          unlimited
root hard     nproc          unlimited
root soft     nofile         unlimited
root hard     nofile         unlimited
EOF

# Increase kernel max Key limit
sudo tee /etc/sysctl.d/99-maxkeys.conf > /dev/null <<EOF
kernel.keys.root_maxkeys=1000000
kernel.keys.maxkeys=1000000
EOF

# Set systemd ulimits
echo "DefaultLimitNOFILE=256000" | sudo tee -a /etc/systemd/system.conf /etc/systemd/user.conf

# Configure PAM limits
echo 'session required pam_limits.so' | sudo tee -a /etc/pam.d/common-session /etc/pam.d/runuser-l

# Set ulimit for the shell user
echo "ulimit -n 256000" >> ~/.profile

# Configure swappiness
sudo tee /etc/sysctl.d/99-swap.conf > /dev/null <<EOF
vm.swappiness = 10
vm.vfs_cache_pressure = 100
EOF

# Increase Max FS open files
sudo tee /etc/sysctl.d/99-fs.conf > /dev/null <<EOF
fs.nr_open = 12000000
fs.file-max = 9223372036854775807
fs.aio-max-nr = 1048576
EOF

# Apply sysctl changes
sudo sysctl --system
  `

  const kernelHeadersCode = `
# Install kernel headers for the current kernel version
sudo apt-get install -y linux-headers-$(uname -r)
  `

  const journaldCode = `
# Configure journald
sudo tee /etc/systemd/journald.conf > /dev/null <<EOF
[Journal]
Storage=persistent
SplitMode=none
RateLimitInterval=0
RateLimitIntervalSec=0
RateLimitBurst=0
ForwardToSyslog=no
ForwardToWall=yes
Seal=no
Compress=yes
SystemMaxUse=64M
RuntimeMaxUse=60M
MaxLevelStore=warning
MaxLevelSyslog=warning
MaxLevelKMsg=warning
MaxLevelConsole=notice
MaxLevelWall=crit
EOF

# Restart journald service
sudo systemctl restart systemd-journald.service

# Clean and rotate logs
sudo journalctl --vacuum-size=64M --vacuum-time=1d
sudo journalctl --rotate
  `

  const logrotateCode = `
# Optimize logrotate configuration
sudo tee /etc/logrotate.conf > /dev/null <<EOF
daily
su root adm
rotate 7
create
compress
size=10M
delaycompress
copytruncate

include /etc/logrotate.d
EOF

# Restart logrotate service
sudo systemctl restart logrotate
  `

  const memorySettingsCode = `
# Optimize memory settings
sudo tee /etc/sysctl.d/99-memory.conf > /dev/null <<EOF
vm.min_free_kbytes = 1048576
vm.nr_hugepages = 2000
vm.max_map_count = 1048576
vm.overcommit_memory = 1
EOF

# Apply sysctl changes
sudo sysctl -p /etc/sysctl.d/99-memory.conf
  `

  const timeSyncCode = `
# Set timezone (replace 'America/New_York' with your timezone)
sudo timedatectl set-timezone America/New_York

# Enable automatic time synchronization
sudo timedatectl set-ntp true

# Note: Automatic timezone setting based on IP is commented out to avoid errors
# To set timezone automatically based on IP, you would need to run:
# IP=$(dig +short myip.opendns.com @resolver1.opendns.com)
# TIMEZONE=$(curl -s "https://ipapi.co/$IP/timezone")
# sudo timedatectl set-timezone "$TIMEZONE"
`

  return (
    <div className="container mx-auto px-4 py-8">
      <div className="flex items-center mb-6">
        <Server className="h-8 w-8 mr-2 text-blue-500" />
        <h1 className="text-3xl font-bold">System Settings</h1>
      </div>
      <p className="mb-4">
        The System Settings category in the customizable_post_install.sh script focuses on core system configurations
        and optimizations for your Proxmox VE installation. These settings are crucial for improving system performance,
        stability, and resource management.
      </p>

      <h2 className="text-2xl font-semibold mt-8 mb-4">Available Optimizations</h2>

      <section className="mb-8">
        <h3 className="text-xl font-semibold mb-2">1. Enable Fast Reboots</h3>
        <p className="mb-4">
          This optimization configures kexec for quick reboots, significantly reducing the time needed for system
          restarts.
        </p>
        <p className="mb-4">
          <strong>Why it's beneficial:</strong> Fast reboots are crucial in a virtualization environment where downtime
          needs to be minimized. By using kexec, the system can skip the time-consuming hardware initialization process
          during a reboot, resulting in much faster restart times.
        </p>
        <h4 className="text-lg font-semibold mb-2">To apply this optimization manually, run these commands:</h4>
        <CopyableCode code={fastRebootCode} />
      </section>

      <section className="mb-8">
        <h3 className="text-xl font-semibold mb-2">2. Configure Kernel Panic Behavior</h3>
        <p className="mb-4">
          This optimization sets up the system to automatically restart on kernel panic, improving system resilience and
          uptime.
        </p>
        <p className="mb-4">
          <strong>Why it's beneficial:</strong> Automatic restarts on kernel panic help maintain system availability.
          Instead of remaining in a crashed state, the system will attempt to recover by rebooting, potentially
          resolving the issue without manual intervention.
        </p>
        <h4 className="text-lg font-semibold mb-2">To apply this optimization manually, run these commands:</h4>
        <CopyableCode code={kernelPanicCode} />
      </section>

      <section className="mb-8">
        <h3 className="text-xl font-semibold mb-2">3. Ensure Entropy Pools are Populated</h3>
        <p className="mb-4">
          This optimization installs and configures haveged to ensure sufficient entropy, preventing potential slowdowns
          in cryptographic operations.
        </p>
        <p className="mb-4">
          <strong>Why it's beneficial:</strong> Many cryptographic operations rely on a pool of random numbers. In
          virtual environments, generating true randomness can be challenging, leading to potential bottlenecks. Haveged
          helps maintain a healthy entropy pool, ensuring smooth operation of cryptographic tasks.
        </p>
        <h4 className="text-lg font-semibold mb-2">To apply this optimization manually, run these commands:</h4>
        <CopyableCode code={entropyCode} />
      </section>

      <section className="mb-8">
        <h3 className="text-xl font-semibold mb-2">4. Increase Various System Limits</h3>
        <p className="mb-4">
          This optimization increases various system limits to improve resource management and system performance.
        </p>
        <p className="mb-4">
          <strong>Why it's beneficial:</strong> Default system limits can be too restrictive for high-performance
          virtualization environments. Increasing these limits allows for better utilization of system resources,
          accommodating more concurrent operations and larger workloads without hitting artificial bottlenecks.
        </p>
        <h4 className="text-lg font-semibold mb-2">To apply this optimization manually, run these commands:</h4>
        <CopyableCode code={systemLimitsCode} />
      </section>

      <section className="mb-8">
        <h3 className="text-xl font-semibold mb-2">5. Install Kernel Headers</h3>
        <p className="mb-4">This optimization installs the kernel headers for the current kernel version.</p>
        <p className="mb-4">
          <strong>Why it's beneficial:</strong> Kernel headers are necessary for building kernel modules, which may be
          required by certain software or drivers. Having them installed ensures that you can compile and use custom
          kernel modules if needed, enhancing system flexibility and compatibility.
        </p>
        <h4 className="text-lg font-semibold mb-2">To apply this optimization manually, run these commands:</h4>
        <CopyableCode code={kernelHeadersCode} />
      </section>

      <section className="mb-8">
        <h3 className="text-xl font-semibold mb-2">6. Optimize Journald</h3>
        <p className="mb-4">This optimization configures journald for better performance and resource usage.</p>
        <p className="mb-4">
          <strong>Why it's beneficial:</strong> Optimizing journald helps manage system logs more efficiently. By
          limiting log sizes and adjusting logging levels, you can prevent logs from consuming excessive disk space
          while still maintaining useful system information for troubleshooting.
        </p>
        <h4 className="text-lg font-semibold mb-2">To apply this optimization manually, run these commands:</h4>
        <CopyableCode code={journaldCode} />
      </section>

      <section className="mb-8">
        <h3 className="text-xl font-semibold mb-2">7. Optimize Logrotate</h3>
        <p className="mb-4">This optimization configures logrotate for better log management.</p>
        <p className="mb-4">
          <strong>Why it's beneficial:</strong> Proper log rotation is crucial for managing disk space and maintaining
          system performance. By compressing old logs and limiting their size, you prevent log files from growing
          indefinitely and potentially filling up your disk.
        </p>
        <h4 className="text-lg font-semibold mb-2">To apply this optimization manually, run these commands:</h4>
        <CopyableCode code={logrotateCode} />
      </section>

      <section className="mb-8">
        <h3 className="text-xl font-semibold mb-2">8. Optimize Memory Settings</h3>
        <p className="mb-4">
          This optimization adjusts various memory-related kernel parameters for better performance.
        </p>
        <p className="mb-4">
          <strong>Why it's beneficial:</strong> These memory optimizations can significantly improve system performance,
          especially in virtualized environments. They help ensure that memory is used efficiently, reduce the
          likelihood of out-of-memory errors, and improve the performance of memory-intensive applications.
        </p>
        <h4 className="text-lg font-semibold mb-2">To apply this optimization manually, run these commands:</h4>
        <CopyableCode code={memorySettingsCode} />
      </section>
      <section className="mb-8">
        <h3 className="text-xl font-semibold mb-2">9. Synchronize Time Automatically</h3>
        <p className="mb-4">
          This optimization configures the system to automatically synchronize its time, ensuring accurate timekeeping.
        </p>
        <p className="mb-4">
          <strong>Why it's beneficial:</strong> Accurate timekeeping is crucial for many system operations, log
          consistency, and proper functioning of time-sensitive applications. Automatic synchronization ensures your
          Proxmox VE system maintains the correct time without manual intervention.
        </p>
        <h4 className="text-lg font-semibold mb-2">To apply this optimization manually, run these commands:</h4>
        <CopyableCode code={timeSyncCode} />
      </section>

      <section className="mt-12 p-4 bg-blue-100 rounded-md">
        <h2 className="text-xl font-semibold mb-2">Automatic Application</h2>
        <p>
          All of these optimizations are automatically applied when selected in the System section of the
          customizable_post_install.sh script. This automation ensures that these beneficial settings are applied
          consistently and correctly, saving time and reducing the potential for human error.
        </p>
      </section>
    </div>
  )
}

