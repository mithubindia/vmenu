import type { Metadata } from "next"
import { Server } from 'lucide-react'
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
        and optimizations for your Proxmox VE installation. These settings are crucial for improving system performance,
        stability, and resource management, ensuring your virtualization environment operates at peak efficiency.
      </p>
      <h2 className="text-2xl font-semibold mt-8 mb-4">Available Optimizations</h2>
      
      <section className="mb-8">
        <h3 className="text-xl font-semibold mb-2">Enable Fast Reboots</h3>
        <p className="mb-4">
          This optimization enables <code>kexec</code>, a mechanism that allows the system to boot directly into a new kernel from an existing running kernel, bypassing the BIOS/firmware and bootloader stages.
        </p>
        <p className="mb-4">
          <strong>Why it's important:</strong> Fast reboots significantly reduce system downtime during maintenance or updates. In a virtualization environment where multiple VMs might be running, minimizing host downtime is crucial for maintaining high availability and reducing disruption to services.
        </p>
        <h4 className="text-lg font-semibold mb-2">To apply this setting manually, run:</h4>
        <CopyableCode code={`sudo apt-get install -y kexec-tools
sudo systemctl enable kexec-pve.service
echo "alias reboot-quick='systemctl kexec'" >> ~/.bash_profile`} />
      </section>

      <section className="mb-8">
        <h3 className="text-xl font-semibold mb-2">Configure Kernel Panic Behavior</h3>
        <p className="mb-4">
          This setting configures the system to automatically reboot after a kernel panic occurs, rather than hanging indefinitely.
        </p>
        <p className="mb-4">
          <strong>Why it's important:</strong> Automatic reboots after kernel panics help maintain system availability. Instead of requiring manual intervention, which could lead to extended downtime, the system attempts to recover on its own. This is particularly crucial in remote or lights-out data center environments where immediate physical access might not be possible.
        </p>
        <h4 className="text-lg font-semibold mb-2">To apply this setting manually, run:</h4>
        <CopyableCode code={`echo "kernel.panic = 10" | sudo tee /etc/sysctl.d/99-kernelpanic.conf
echo "kernel.panic_on_oops = 1" | sudo tee -a /etc/sysctl.d/99-kernelpanic.conf
sudo sysctl -p /etc/sysctl.d/99-kernelpanic.conf`} />
      </section>
      
      <section className="mb-8">
        <h3 className="text-xl font-semibold mb-2">Increase System Limits</h3>
        <p className="mb-4">
          This optimization increases various system limits, including the maximum number of file watches and open file descriptors.
        </p>
        <p className="mb-4">
          <strong>Why it's important:</strong> Higher system limits allow for better resource utilization, especially in high-density virtualization environments. Increased file watch limits improve performance for applications that monitor many files (like backup systems or development environments). Higher open file limits allow more concurrent connections and file operations, which is crucial for busy servers hosting multiple VMs or containers.
        </p>
        <h4 className="text-lg font-semibold mb-2">To apply this setting manually, run:</h4>
        <CopyableCode code={`echo "fs.inotify.max_user_watches = 1048576" | sudo tee /etc/sysctl.d/99-maxwatches.conf
echo "* soft nofile 1048576" | sudo tee /etc/security/limits.d/99-limits.conf
sudo sysctl -p`} />
      </section>
      
      <section className="mb-8">
        <h3 className="text-xl font-semibold mb-2">Optimize Journald</h3>
        <p className="mb-4">
          This setting configures systemd's journald logging service to limit its disk usage and optimize performance.
        </p>
        <p className="mb-4">
          <strong>Why it's important:</strong> Proper log management is crucial for system health and troubleshooting. By limiting the maximum size of the journal, you prevent logs from consuming excessive disk space, which could potentially fill up the system partition. This is especially important in virtualization environments where disk space is often at a premium. Additionally, optimized logging reduces I/O operations, potentially improving overall system performance.
        </p>
        <h4 className="text-lg font-semibold mb-2">To apply this setting manually, run:</h4>
        <CopyableCode code={`echo "SystemMaxUse=64M" | sudo tee -a /etc/systemd/journald.conf
sudo systemctl restart systemd-journald`} />
      </section>
      
      <section className="mb-8">
        <h3 className="text-xl font-semibold mb-2">Optimize Memory Management</h3>
        <p className="mb-4">
          This optimization adjusts various memory-related kernel parameters to improve system performance and stability.
        </p>
        <p className="mb-4">
          <strong>Why it's important:</strong> Proper memory management is critical in virtualization environments where multiple VMs compete for resources. These optimizations can help prevent out-of-memory situations, improve memory allocation efficiency, and enhance overall system responsiveness. This is particularly beneficial for hosts running memory-intensive workloads or a high number of VMs.
        </p>
        <h4 className="text-lg font-semibold mb-2">To apply this setting manually, run:</h4>
        <CopyableCode code={`echo "vm.swappiness = 10" | sudo tee /etc/sysctl.d/99-memory.conf
echo "vm.vfs_cache_pressure = 50" | sudo tee -a /etc/sysctl.d/99-memory.conf
sudo sysctl -p /etc/sysctl.d/99-memory.conf`} />
      </section>
      
      <section className="mt-12 p-4 bg-blue-100 rounded-md">
        <h2 className="text-xl font-semibold mb-2">Automatic Application</h2>
        <p>
          All of these optimizations are automatically applied when selected in the Basic Settings section of the
          customizable_post_install.sh script. This automation ensures that these beneficial settings are applied
          consistently and correctly, saving time and reducing the potential for human error during manual
          configuration.
        </p>
      </section>
    </div>
  );
}