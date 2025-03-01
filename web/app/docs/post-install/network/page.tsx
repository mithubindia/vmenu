import type { Metadata } from "next"
import { Network } from "lucide-react"

export const metadata: Metadata = {
  title: "ProxMenux Post-Install: Network Settings",
  description:
    "Detailed guide to the Network Settings category in the ProxMenux post-install script for Proxmox VE optimization.",
  openGraph: {
    title: "ProxMenux Post-Install: Network Settings",
    description:
      "Detailed guide to the Network Settings category in the ProxMenux post-install script for Proxmox VE optimization.",
    type: "article",
    url: "https://macrimi.github.io/ProxMenux/docs/post-install/network",
    images: [
      {
        url: "https://macrimi.github.io/ProxMenux/network-settings-image.png",
        width: 1200,
        height: 630,
        alt: "ProxMenux Post-Install Network Settings",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "ProxMenux Post-Install: Network Settings",
    description:
      "Detailed guide to the Network Settings category in the ProxMenux post-install script for Proxmox VE optimization.",
    images: ["https://macrimi.github.io/ProxMenux/network-settings-image.png"],
  },
}

export default function NetworkSettingsPage() {
  const applyNetworkOptimizationsCode = `
# Create or update /etc/sysctl.d/99-network.conf
cat <<EOF > /etc/sysctl.d/99-network.conf
net.core.netdev_max_backlog=8192
net.core.optmem_max=8192
net.core.rmem_max=16777216
net.core.somaxconn=8151
net.core.wmem_max=16777216
net.ipv4.tcp_rmem=8192 87380 16777216
net.ipv4.tcp_wmem=8192 65536 16777216
net.ipv4.tcp_max_syn_backlog=8192
net.ipv4.tcp_slow_start_after_idle=0
net.ipv4.tcp_tw_reuse=0
# ... (other network optimizations)
EOF

# Apply sysctl changes
sysctl --system

# Ensure /etc/network/interfaces includes the interfaces.d directory
echo "source /etc/network/interfaces.d/*" >> /etc/network/interfaces
  `

  const enableTcpFastOpenCode = `
# Enable Google TCP BBR congestion control
cat <<EOF > /etc/sysctl.d/99-kernel-bbr.conf
# TCP BBR congestion control
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
EOF

# Enable TCP Fast Open
cat <<EOF > /etc/sysctl.d/99-tcp-fastopen.conf
# TCP Fast Open (TFO)
net.ipv4.tcp_fastopen = 3
EOF

# Apply sysctl changes
sysctl --system
  `

  const forceAptIpv4Code = `
# Create APT configuration to force IPv4
echo "Acquire::ForceIPv4 \"true\";" > /etc/apt/apt.conf.d/99-force-ipv4
  `

  const installOpenVSwitchCode = `
# Install OpenVSwitch
apt-get update
apt-get install -y openvswitch-switch openvswitch-common

# Verify installation
ovs-vsctl --version
  `

  return (
    <div className="container mx-auto px-4 py-8">
      <div className="flex items-center mb-6">
        <Network className="h-8 w-8 mr-2 text-blue-500" />
        <h1 className="text-3xl font-bold">Network Settings</h1>
      </div>
      <p className="mb-4">
        The Network Settings category in the customizable_post_install.sh script focuses on optimizing network
        performance and configuration for your Proxmox VE installation.
      </p>

      <h2 className="text-2xl font-semibold mt-8 mb-4">Available Optimizations</h2>

      <section className="mb-8">
        <h3 className="text-xl font-semibold mb-2">1. Apply Network Optimizations</h3>
        <p className="mb-4">
          This optimization applies various network-related sysctl settings to improve network performance and security.
        </p>
        <p className="mb-4">
          <strong>Why it's beneficial:</strong> These optimizations can significantly improve network throughput, reduce
          latency, and enhance security by adjusting various kernel parameters related to networking.
        </p>
        <h4 className="text-lg font-semibold mb-2">To apply this optimization manually, you would run:</h4>
        <pre className="bg-gray-100 p-4 rounded-md overflow-x-auto">
          <code>{applyNetworkOptimizationsCode}</code>
        </pre>
      </section>

      <section className="mb-8">
        <h3 className="text-xl font-semibold mb-2">2. Enable TCP BBR and Fast Open</h3>
        <p className="mb-4">
          This optimization enables Google's TCP BBR congestion control algorithm and TCP Fast Open.
        </p>
        <p className="mb-4">
          <strong>Why it's beneficial:</strong> TCP BBR can significantly improve network throughput and reduce latency,
          especially on long-distance or congested networks. TCP Fast Open reduces connection establishment time,
          improving the speed of short-lived connections.
        </p>
        <h4 className="text-lg font-semibold mb-2">To apply this optimization manually, you would run:</h4>
        <pre className="bg-gray-100 p-4 rounded-md overflow-x-auto">
          <code>{enableTcpFastOpenCode}</code>
        </pre>
      </section>

      <section className="mb-8">
        <h3 className="text-xl font-semibold mb-2">3. Force APT to Use IPv4</h3>
        <p className="mb-4">This optimization configures APT (Advanced Package Tool) to use IPv4 exclusively.</p>
        <p className="mb-4">
          <strong>Why it's beneficial:</strong> Forcing APT to use IPv4 can resolve issues in environments where IPv6 is
          not properly configured or is causing slowdowns. This ensures more reliable package management operations.
        </p>
        <h4 className="text-lg font-semibold mb-2">To apply this optimization manually, you would run:</h4>
        <pre className="bg-gray-100 p-4 rounded-md overflow-x-auto">
          <code>{forceAptIpv4Code}</code>
        </pre>
      </section>

      <section className="mb-8">
        <h3 className="text-xl font-semibold mb-2">4. Install Open vSwitch</h3>
        <p className="mb-4">
          This optimization installs Open vSwitch, a production quality, multilayer virtual switch.
        </p>
        <p className="mb-4">
          <strong>Why it's beneficial:</strong> Open vSwitch provides advanced networking capabilities for virtualized
          environments. It allows for more flexible and powerful network configurations, supporting features like VLAN
          tagging, traffic shaping, and software-defined networking.
        </p>
        <h4 className="text-lg font-semibold mb-2">To apply this optimization manually, you would run:</h4>
        <pre className="bg-gray-100 p-4 rounded-md overflow-x-auto">
          <code>{installOpenVSwitchCode}</code>
        </pre>
      </section>

      <section className="mt-12 p-4 bg-blue-100 rounded-md">
        <h2 className="text-xl font-semibold mb-2">Automatic Application</h2>
        <p>
          All of these optimizations are automatically applied when selected in the Network section of the
          customizable_post_install.sh script. This automation ensures that these beneficial settings are applied
          consistently and correctly.
        </p>
      </section>
    </div>
  )
}

