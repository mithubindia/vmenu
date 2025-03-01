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
  return (
    <div className="container mx-auto px-4 py-8">
      <div className="flex items-center mb-6">
        <Server className="h-8 w-8 mr-2 text-blue-500" />
        <h1 className="text-3xl font-bold">System Settings</h1>
      </div>
      <p className="mb-4">
        The <strong>System Settings</strong> category in the <code>customizable_post_install.sh</code> script focuses on core system configurations
        and optimizations for your Proxmox VE installation. These settings improve performance, stability, and resource management.
      </p>
      <h2 className="text-2xl font-semibold mt-8 mb-4">Available Optimizations</h2>
      
      <section className="mb-8">
        <h3 className="text-xl font-semibold mb-2">Enable Fast Reboots</h3>
        <p className="mb-4">This optimization enables <code>kexec</code>, allowing the system to reboot quickly without full hardware reinitialization.</p>
        <h4 className="text-lg font-semibold mb-2">To apply this setting manually, run:</h4>
        <CopyableCode code={`sudo apt-get install -y kexec-tools\nsudo systemctl enable kexec-pve.service\necho "alias reboot-quick='systemctl kexec'" >> ~/.bash_profile`} />
      </section>

      <section className="mb-8">
        <h3 className="text-xl font-semibold mb-2">Configure Kernel Panic Behavior</h3>
        <p className="mb-4">Ensures the system reboots automatically after a kernel panic to reduce downtime.</p>
        <h4 className="text-lg font-semibold mb-2">To apply this setting manually, run:</h4>
        <CopyableCode code={`echo "kernel.panic = 10" | sudo tee /etc/sysctl.d/99-kernelpanic.conf\necho "kernel.panic_on_oops = 1" | sudo tee -a /etc/sysctl.d/99-kernelpanic.conf\nsudo sysctl -p /etc/sysctl.d/99-kernelpanic.conf`} />
      </section>
      
      <section className="mb-8">
        <h3 className="text-xl font-semibold mb-2">Increase System Limits</h3>
        <p className="mb-4">Optimizes system resource management by increasing user and file limits.</p>
        <h4 className="text-lg font-semibold mb-2">To apply this setting manually, run:</h4>
        <CopyableCode code={`echo "fs.inotify.max_user_watches = 1048576" | sudo tee /etc/sysctl.d/99-maxwatches.conf\necho "* soft nofile 1048576" | sudo tee /etc/security/limits.d/99-limits.conf\nsudo sysctl -p`} />
      </section>
      
      <section className="mb-8">
        <h3 className="text-xl font-semibold mb-2">Optimize Journald</h3>
        <p className="mb-4">Configures system logs to limit excessive disk usage and improve performance.</p>
        <h4 className="text-lg font-semibold mb-2">To apply this setting manually, run:</h4>
        <CopyableCode code={`echo "SystemMaxUse=64M" | sudo tee -a /etc/systemd/journald.conf\nsudo systemctl restart systemd-journald`} />
      </section>
      
      <section className="mt-12 p-4 bg-blue-100 rounded-md">
        <h2 className="text-xl font-semibold mb-2">Automatic Application</h2>
        <p>
          All of these optimizations are automatically applied when selected in the System section of the
          <code>customizable_post_install.sh</code> script. This ensures that beneficial settings are consistently applied,
          improving efficiency and reducing manual setup time.
        </p>
      </section>
    </div>
  );
}
