import type { Metadata } from "next"
import { Shield } from "lucide-react"
import CopyableCode from "@/components/CopyableCode"

export const metadata: Metadata = {
  title: "ProxMenux Post-Install: Security Settings",
  description:
    "Comprehensive guide to Security Settings in the ProxMenux post-install script for enhancing Proxmox VE security.",
  openGraph: {
    title: "ProxMenux Post-Install: Security Settings",
    description:
      "Comprehensive guide to Security Settings in the ProxMenux post-install script for enhancing Proxmox VE security.",
    type: "article",
    url: "https://macrimi.github.io/ProxMenux/docs/post-install/security",
    images: [
      {
        url: "https://macrimi.github.io/ProxMenux/security-settings-image.png",
        width: 1200,
        height: 630,
        alt: "ProxMenux Post-Install Security Settings",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "ProxMenux Post-Install: Security Settings",
    description:
      "Comprehensive guide to Security Settings in the ProxMenux post-install script for enhancing Proxmox VE security.",
    images: ["https://macrimi.github.io/ProxMenux/security-settings-image.png"],
  },
}

function StepNumber({ number }: { number: number }) {
  return (
    <div className="inline-flex items-center justify-center w-8 h-8 mr-3 text-white bg-blue-500 rounded-full">
      <span className="text-sm font-bold">{number}</span>
    </div>
  )
}

export default function SecuritySettingsPage() {
  return (
    <div className="container mx-auto px-4 py-8">
      <div className="flex items-center mb-6">
        <Shield className="h-8 w-8 mr-2 text-blue-500" />
        <h1 className="text-3xl font-bold">Security Settings</h1>
      </div>
      <p className="mb-4">
        The <strong>Security Settings</strong> category focuses on enhancing the security of your Proxmox VE
        installation. These settings are crucial for protecting your virtualization environment from potential threats
        and unauthorized access.
      </p>
      <h2 className="text-2xl font-semibold mt-8 mb-4">Available Optimizations</h2>

      <h3 className="text-xl font-semibold mt-16 mb-4 flex items-center">
        <StepNumber number={1} />
        Disable portmapper/rpcbind
      </h3>
      <p className="mb-4">This optimization disables the portmapper/rpcbind service for improved security.</p>
      <p className="mb-4">
        <strong>Why it's beneficial:</strong> Disabling unnecessary services like portmapper/rpcbind reduces the attack
        surface of your system. This service is often not needed in modern environments and can be a potential security
        risk if left enabled.
      </p>
      <p className="text-lg mb-2">This adjustment automates the following commands:</p>
      <CopyableCode
        code={`
# Disable and stop rpcbind
systemctl disable rpcbind
systemctl stop rpcbind
      `}
      />

      <h3 className="text-xl font-semibold mt-16 mb-4 flex items-center">
        <StepNumber number={2} />
        Install Lynis Security Tool
      </h3>
      <p className="mb-4">
        This optimization installs Lynis, a powerful security auditing tool for Unix-based systems.
      </p>
      <p className="mb-4">
        <strong>Why it's beneficial:</strong> Lynis helps identify security vulnerabilities, configuration errors, and
        provides recommendations for system hardening. Regular security audits with Lynis can significantly improve your
        system's overall security posture.
      </p>
      <p className="text-lg mb-2">This adjustment automates the following commands:</p>
      <CopyableCode
        code={`
# Install Lynis
apt-get -y install lynis
      `}
      />

      <h3 className="text-xl font-semibold mt-16 mb-4 flex items-center">
        <StepNumber number={3} />
        Protect Web Interface with fail2ban
      </h3>
      <p className="mb-4">
        This optimization installs and configures fail2ban to protect the Proxmox VE web interface from brute-force
        attacks.
      </p>
      <p className="mb-4">
        <strong>Why it's beneficial:</strong> fail2ban helps prevent unauthorized access attempts by temporarily banning
        IP addresses that show malicious signs, such as too many password failures. This adds an extra layer of security
        to your Proxmox VE web interface.
      </p>
      <p className="text-lg mb-2">This adjustment automates the following commands:</p>
      <CopyableCode
        code={`
# Install fail2ban
apt-get -y install fail2ban

# Configure Proxmox filter
cat <<EOF > /etc/fail2ban/filter.d/proxmox.conf
[Definition]
failregex = pvedaemon\[.*authentication failure; rhost=<HOST> user=.* msg=.*
ignoreregex =
EOF

# Configure Proxmox jail
cat <<EOF > /etc/fail2ban/jail.d/proxmox.conf
[proxmox]
enabled = true
port = https,http,8006,8007
filter = proxmox
logpath = /var/log/daemon.log
maxretry = 3
bantime = 3600
findtime = 600
EOF

# Configure general fail2ban settings
cat <<EOF > /etc/fail2ban/jail.local
[DEFAULT]
ignoreip = 127.0.0.1
bantime = 86400
maxretry = 2
findtime = 1800
[ssh-iptables]
enabled = true
filter = sshd
action = iptables[name=SSH, port=ssh, protocol=tcp]
logpath = /var/log/auth.log
maxretry = 2
findtime = 3600
bantime = 32400
EOF

# Enable and restart fail2ban service
systemctl enable fail2ban
systemctl restart fail2ban
      `}
      />

      <section className="mt-12 p-4 bg-blue-100 rounded-md">
        <h2 className="text-xl font-semibold mb-2">Automatic Application</h2>
        <p>
          All of these optimizations are automatically applied when selected in the Security section. This automation
          ensures that these beneficial settings are applied consistently and correctly, saving time and reducing the
          potential for human error during manual configuration.
        </p>
      </section>
    </div>
  )
}

