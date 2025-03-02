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
        Lynis is a comprehensive security auditing tool that analyzes your system, detects vulnerabilities, and provides recommendations for improving security.
      </p>
      <p className="mb-4">
        <strong>How it works:</strong> Lynis scans the system and evaluates various security parameters, including:
      </p>
      <ul className="list-disc pl-5 mb-4">
        <li>Kernel security and system settings</li>
        <li>Authentication policies (SSH, user passwords, etc.)</li>
        <li>Network configurations and firewall rules</li>
        <li>File permissions and system integrity</li>
        <li>Malware detection and system hardening suggestions</li>
      </ul>
      <p className="text-lg mb-2">This adjustment automates the following command:</p>
      <CopyableCode
        code={`
# Install Lynis
apt-get -y install lynis
        `}
      />
      <p className="text-lg mt-4">To run a system security audit, execute:</p>
      <CopyableCode
        code={`
# Perform a full security audit
lynis audit system
        `}
      />


    <h3 className="text-xl font-semibold mt-16 mb-4 flex items-center">
      <StepNumber number={3} />
      Protect Web Interface with Fail2Ban
    </h3>
    <p className="mb-4">
      Fail2Ban enhances security by monitoring login attempts and banning malicious IPs that attempt unauthorized access.
    </p>
    <p className="mb-4">
      <strong>How it works:</strong> Fail2Ban analyzes logs, detects repeated authentication failures, and automatically bans the source IP address to prevent further attacks.
    </p>
    <ul className="list-disc pl-5 mb-4">
      <li>Protects the Proxmox VE web interface from brute-force attacks</li>
      <li>Prevents unauthorized SSH access by banning repeated failed login attempts</li>
      <li>Automatically blocks malicious IPs to reduce attack vectors</li>
    </ul>

    <h4 className="text-lg font-semibold mt-4">Fail2Ban Configuration Overview</h4>
    <p className="mb-4">
      Fail2Ban is configured with the following security policies:
    </p>
    <ul className="list-disc pl-5 mb-4">
      <li><strong>Ban Duration:</strong> 24 hours for SSH and 1 hour for Proxmox</li>
      <li><strong>Max Retries:</strong> 2 failed attempts for SSH, 3 for Proxmox</li>
      <li><strong>Find Time:</strong> 30 minutes for SSH, 10 minutes for Proxmox</li>
      <li><strong>Log Monitoring:</strong> <code>/var/log/auth.log</code> for SSH and <code>/var/log/daemon.log</code> for Proxmox</li>
    </ul>

    <p className="text-lg mb-2">Install and configure Fail2Ban with the following commands:</p>
    <CopyableCode
      code={`
    # Install Fail2Ban
    apt-get -y install fail2ban
      `}
    />

    <p className="text-lg mt-4">Configure the Proxmox filter to detect failed logins:</p>
    <CopyableCode
      code={`
    # Create the Fail2Ban filter for Proxmox
    cat <<EOF > /etc/fail2ban/filter.d/proxmox.conf
    [Definition]
    failregex = pvedaemon\\[.*authentication failure; rhost=<HOST> user=.* msg=.*
    ignoreregex =
    EOF
      `}
    />

    <p className="text-lg mt-4">Define security rules for Proxmox:</p>
    <CopyableCode
      code={`
    # Create a jail configuration for Proxmox
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
      `}
    />

    <p className="text-lg mt-4">Set up global Fail2Ban policies:</p>
    <CopyableCode
      code={`
    # Configure general Fail2Ban settings
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
      `}
    />

    <p className="text-lg mt-4">Enable and restart the Fail2Ban service:</p>
    <CopyableCode
      code={`
    # Enable and restart Fail2Ban
    systemctl enable fail2ban
    systemctl restart fail2ban
      `}
    />

    <p className="text-lg mt-4">Check active Fail2Ban jails:</p>
    <CopyableCode
      code={`
    # Display Fail2Ban status
    fail2ban-client status

    # Check status of Proxmox protection
    fail2ban-client status proxmox

    # Check status of SSH protection
    fail2ban-client status ssh-iptables
      `}
    />

    <h4 className="text-lg font-semibold mt-4">Managing Fail2Ban</h4>
    <p className="mb-4">You can manually unban an IP if needed:</p>
    <CopyableCode
      code={`
    # Unban an IP from SSH protection
    fail2ban-client set ssh-iptables unbanip <IP_ADDRESS>

    # Unban an IP from Proxmox protection
    fail2ban-client set proxmox unbanip <IP_ADDRESS>
      `}
    />

<p className="mt-4">Fail2Ban will now automatically protect your Proxmox VE and SSH access, reducing the risk of brute-force attacks.</p>


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

