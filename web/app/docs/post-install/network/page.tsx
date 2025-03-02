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
        The <strong>Network Settings</strong> category focuses on optimizing network performance and configuration in Proxmox VE. 
        These settings are essential for efficient network operations in virtualized environments where multiple VMs and containers 
        share network resources.
      </p>
      <h2 className="text-2xl font-semibold mt-8 mb-4">Available Optimizations</h2>

      <h3 className="text-xl font-semibold mt-16 mb-4 flex items-center">
        <StepNumber number={1} />
        Apply Network Optimizations
      </h3>
      <p className="mb-4">
      This setting adjusts various <strong>sysctl</strong> parameters to enhance network performance, security, and stability.
      </p>
      <p className="mb-4">
        <strong>Why it's beneficial:</strong> Improves <strong>throughput, reduces latency</strong>, and <strong>enhances security</strong> 
        by fine-tuning kernel network settings. These optimizations are critical in virtualization environments where network 
        efficiency directly impacts VMs and container performance.
      </p>
      <p className="text-lg mb-2">This adjustment automates the following commands:</p>
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
      <p className="mb-4">This optimization enables  <strong>TCP BBR</strong>, Google's congestion control algorithm, and  <strong>TCP Fast Open</strong>.</p>
      <p className="mb-4">
      <strong>Why it's beneficial:</strong>
      <ul className="list-disc pl-5">
        <li><strong>TCP BBR</strong> improves network throughput and reduces latency, especially over long-distance or congested links.</li>
        <li><strong>TCP Fast Open</strong> accelerates connection establishment, benefiting short-lived connections.</li>
        <li>These enhancements improve <strong>network responsiveness</strong> in virtualized environments where efficient communication between systems is critical.</li>
      </ul>
     </p>
      <p className="text-lg mb-2">This adjustment automates the following commands:</p>
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
      <p className="mb-4">This setting forces <strong>APT (Advanced Package Tool)</strong> to use <strong>IPv4</strong> exclusively.</p>
      <p className="mb-4">
        <strong>Why it's beneficial:</strong> Ensures <strong>reliable package management operations</strong> in environments where <strong>IPv6 </strong>
        is misconfigured or causes slow downloads. This is particularly useful in networks where <strong>IPv6 connectivity 
        is unstable or unsupported</strong>, reducing potential update and repository access issues.
      </p>
      <p className="text-lg mb-2">This adjustment automates the following commands:</p>
      <CopyableCode
        code={`
echo 'Acquire::ForceIPv4 "true";' | sudo tee /etc/apt/apt.conf.d/99force-ipv4
      `}
      />

      <h3 className="text-xl font-semibold mt-16 mb-4 flex items-center">
        <StepNumber number={4} />
        Install Open vSwitch
      </h3>
      <p className="mb-4">This optimization installs <strong>Open vSwitch (OVS)</strong>, a multilayer virtual switch designed for modern virtualized environments.</p>
      <p className="mb-4">
      <strong className="block">Why it's beneficial:</strong>
        Provides <strong>advanced networking capabilities</strong>, including <strong>VLAN tagging, trunking, 
        traffic shaping, and Quality of Service (QoS)</strong>. OVS enables more <strong>flexible</strong> and <strong>scalable</strong> network configurations, 
        making it ideal for complex virtualization setups requiring fine-grained traffic control.
      </p>
      <p className="text-lg mb-2">This adjustment automates the following commands:</p>
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
      This setting adjusts network interface parameters to enhance performance and reliability.
      </p>
      <p className="mb-4">
      <strong className="block">Why it's beneficial:</strong>
        PProper <strong>NIC tuning</strong> reduces <strong>latency, packet loss</strong>, and <strong>improves stability </strong>
        in environments with high network loads. Adjustments like <strong>increasing TX queue length</strong> prevent packet drops 
        and enhance network responsiveness, which is essential in virtualized infrastructures with multiple VMs and containers.
      </p>
      <p className="text-lg mb-2">This adjustment automates the following commands:</p>
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

