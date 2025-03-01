import type { Metadata } from "next"
import { Network } from "lucide-react"
import CopyableCode from "@/components/CopyableCode"

export const metadata: Metadata = {
  title: "ProxMenux Post-Install: Network Settings",
  description:
    "Comprehensive guide to Network Settings in the ProxMenux post-install script for optimizing Proxmox VE network performance and configuration.",
  openGraph: {
    title: "ProxMenux Post-Install: Network Settings",
    description:
      "Comprehensive guide to Network Settings in the ProxMenux post-install script for optimizing Proxmox VE network performance and configuration.",
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
      "Comprehensive guide to Network Settings in the ProxMenux post-install script for optimizing Proxmox VE network performance and configuration.",
    images: ["https://macrimi.github.io/ProxMenux/network-settings-image.png"],
  },
}

function StepNumber({ number }: { number: number }) {
  return (
    <div className="inline-flex items-center justify-center w-8 h-8 mr-3 text-white bg-blue-500 rounded-full">
      <span className="text-sm font-bold">{number}</span>
    </div>
  )
}

export default function NetworkSettingsPage() {
  return (
    <div className="container mx-auto px-4 py-8">
      <div className="flex items-center mb-6">
        <Network className="h-8 w-8 mr-2 text-blue-500" />
        <h1 className="text-3xl font-bold">Network Settings</h1>
      </div>
      <p className="mb-4">
        The <strong>Network Settings</strong> category focuses on optimizing network performance and configuration for
        your Proxmox VE installation. These settings are crucial for ensuring efficient network operations, which is
        vital in a virtualized environment where multiple VMs and containers share network resources.
      </p>
      <h2 className="text-2xl font-semibold mt-8 mb-4">Available Optimizations</h2>

      <h3 className="text-xl font-semibold mt-16 mb-4 flex items-center">
        <StepNumber number={1} />
        Apply Network Optimizations
      </h3>
      <p className="mb-4">
        This optimization applies various network-related sysctl settings to improve network performance, security, and
        stability.
      </p>
      <p className="mb-4">
        <strong>Why it's beneficial:</strong> These optimizations can significantly improve network throughput, reduce
        latency, and enhance security. They adjust various kernel parameters related to networking, which is crucial in
        a virtualization environment where network performance directly impacts the performance of VMs and containers.
      </p>
      <p className="text-lg font-semibold mb-2">This adjustment automates the following commands:</p>
      <CopyableCode
        code={`
cat <<EOF | sudo tee /etc/sysctl.d/99-network-performance.conf
net.core.netdev_max_backlog=8192
net.core.optmem_max=8192
net.core.rmem_max=16777216
net.core.somaxconn=8151
net.core.wmem_max=16777216
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.all.log_martians = 0
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.default.log_martians = 0
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.ip_local_port_range=1024 65535
net.ipv4.tcp_base_mss = 1024
net.ipv4.tcp_challenge_ack_limit = 999999999
net.ipv4.tcp_fin_timeout=10
net.ipv4.tcp_keepalive_intvl=30
net.ipv4.tcp_keepalive_probes=3
net.ipv4.tcp_keepalive_time=240
net.ipv4.tcp_limit_output_bytes=65536
net.ipv4.tcp_max_syn_backlog=8192
net.ipv4.tcp_max_tw_buckets = 1440000
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_rfc1337=1
net.ipv4.tcp_rmem=8192 87380 16777216
net.ipv4.tcp_sack=1
net.ipv4.tcp_slow_start_after_idle=0
net.ipv4.tcp_syn_retries=3
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_tw_recycle = 0
net.ipv4.tcp_tw_reuse = 0
net.ipv4.tcp_wmem=8192 65536 16777216
net.netfilter.nf_conntrack_generic_timeout = 60
net.netfilter.nf_conntrack_helper=0
net.netfilter.nf_conntrack_max = 524288
net.netfilter.nf_conntrack_tcp_timeout_established = 28800
net.unix.max_dgram_qlen = 4096
EOF

sudo sysctl -p /etc/sysctl.d/99-network-performance.conf
      `}
      />

      <h3 className="text-xl font-semibold mt-16 mb-4 flex items-center">
        <StepNumber number={2} />
        Enable TCP BBR and Fast Open
      </h3>
      <p className="mb-4">This optimization enables Google's TCP BBR congestion control algorithm and TCP Fast Open.</p>
      <p className="mb-4">
        <strong>Why it's beneficial:</strong> TCP BBR can significantly improve network throughput and reduce latency,
        especially on long-distance or congested networks. TCP Fast Open reduces connection establishment time,
        improving the speed of short-lived connections. These optimizations are particularly beneficial in virtualized
        environments where network performance is crucial for overall system responsiveness.
      </p>
      <p className="text-lg font-semibold mb-2">This adjustment automates the following commands:</p>
      <CopyableCode
        code={`
echo "net.core.default_qdisc = fq" | sudo tee -a /etc/sysctl.d/99-tcp-bbr.conf
echo "net.ipv4.tcp_congestion_control = bbr" | sudo tee -a /etc/sysctl.d/99-tcp-bbr.conf
echo "net.ipv4.tcp_fastopen = 3" | sudo tee -a /etc/sysctl.d/99-tcp-fastopen.conf

sudo modprobe tcp_bbr
sudo sysctl -p /etc/sysctl.d/99-tcp-bbr.conf
sudo sysctl -p /etc/sysctl.d/99-tcp-fastopen.conf
      `}
      />

      <h3 className="text-xl font-semibold mt-16 mb-4 flex items-center">
        <StepNumber number={3} />
        Force APT to Use IPv4
      </h3>
      <p className="mb-4">This optimization configures APT (Advanced Package Tool) to use IPv4 exclusively.</p>
      <p className="mb-4">
        <strong>Why it's beneficial:</strong> Forcing APT to use IPv4 can resolve issues in environments where IPv6 is
        not properly configured or is causing slowdowns. This ensures more reliable package management operations, which
        is crucial for maintaining and updating your Proxmox VE system. It's particularly useful in networks where IPv6
        connectivity might be unreliable or not fully supported.
      </p>
      <p className="text-lg font-semibold mb-2">This adjustment automates the following commands:</p>
      <CopyableCode
        code={`
echo 'Acquire::ForceIPv4 "true";' | sudo tee /etc/apt/apt.conf.d/99force-ipv4
      `}
      />

      <h3 className="text-xl font-semibold mt-16 mb-4 flex items-center">
        <StepNumber number={4} />
        Install Open vSwitch
      </h3>
      <p className="mb-4">This optimization installs Open vSwitch, a production quality, multilayer virtual switch.</p>
      <p className="mb-4">
        <strong>Why it's beneficial:</strong> Open vSwitch provides advanced networking capabilities for virtualized
        environments. It allows for more flexible and powerful network configurations, including support for VLAN
        tagging and trunking, advanced traffic shaping, and Quality of Service (QoS) capabilities. This is particularly
        beneficial for complex virtualization setups where fine-grained control over network traffic is required.
      </p>
      <p className="text-lg font-semibold mb-2">This adjustment automates the following commands:</p>
      <CopyableCode
        code={`
sudo apt-get update
sudo apt-get install -y openvswitch-switch

# Verify installation
sudo ovs-vsctl --version
      `}
      />

      <h3 className="text-xl font-semibold mt-16 mb-4 flex items-center">
        <StepNumber number={5} />
        Optimize Network Interface Settings
      </h3>
      <p className="mb-4">
        This optimization adjusts settings for network interfaces to improve performance and reliability.
      </p>
      <p className="mb-4">
        <strong>Why it's beneficial:</strong> Proper configuration of network interfaces can significantly improve
        network performance, reduce latency, and increase stability. This is particularly important in virtualized
        environments where multiple VMs and containers share network resources. Optimizations like increasing the TX
        queue length can help prevent packet drops under high load.
      </p>
      <p className="text-lg font-semibold mb-2">This adjustment automates the following commands:</p>
      <CopyableCode
        code={`
# Replace eth0 with your actual interface name
sudo ip link set eth0 txqueuelen 10000

# Make the change persistent
echo 'ACTION=="add", SUBSYSTEM=="net", KERNEL=="eth0", RUN+="/sbin/ip link set eth0 txqueuelen 10000"' | sudo tee /etc/udev/rules.d/60-net-txqueue.rules

# Enable TCP timestamps
echo 'net.ipv4.tcp_timestamps = 1' | sudo tee -a /etc/sysctl.d/99-network-performance.conf

sudo sysctl -p /etc/sysctl.d/99-network-performance.conf
      `}
      />

      <section className="mt-12 p-4 bg-blue-100 rounded-md">
        <h2 className="text-xl font-semibold mb-2">Automatic Application</h2>
        <p>
          All of these optimizations are automatically applied when selected in the Network section. This automation
          ensures that these beneficial settings are applied consistently and correctly, saving time and reducing the
          potential for human error during manual configuration.
        </p>
      </section>
    </div>
  )
}

