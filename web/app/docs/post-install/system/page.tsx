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

function StepNumber({ number }: { number: number }) {
  return (
    <div className="inline-flex items-center justify-center w-8 h-8 mr-3 text-white bg-blue-500 rounded-full">
      <span className="text-sm font-bold">{number}</span>
    </div>
  )
}

export default function SystemSettingsPage() {
  return (
    <div className="container mx-auto px-4 py-8">
      <div className="flex items-center mb-6">
        <Server className="h-8 w-8 mr-2 text-blue-500" />
        <h1 className="text-3xl font-bold">System Settings</h1>
      </div>
      <p className="mb-4">
        The <strong>System Settings</strong> category includes core system configurations and optimizations for Proxmox VE, 
        focusing on performance, stability, and resource management.
      </p>
      <h2 className="text-2xl font-semibold mt-8 mb-4">Available Optimizations</h2>

      <h3 className="text-xl font-semibold mt-16 mb-4 flex items-center">
        <StepNumber number={1} />
        Enable Fast Reboots
      </h3>
      <p className="mb-4">
        This optimization enables <code>kexec</code>, allowing the system to boot directly into a new kernel 
        without going through the BIOS/firmware and bootloader.
      </p>
      <p className="mb-4">
      <strong className="block">Why it's beneficial:</strong>
        Fast reboots reduce system downtime during updates and maintenance. 
        This is particularly useful in virtualization environments where minimizing host downtime helps maintain service availability.
      </p>
      <p className="text-lg mb-2">This adjustment automates the following commands:</p>
      <CopyableCode
        code={`
sudo apt-get install -y kexec-tools
sudo systemctl enable kexec-pve.service
echo "alias reboot-quick='systemctl kexec'" >> ~/.bash_profile
      `}
      />

      <h3 className="text-xl font-semibold mt-16 mb-4 flex items-center">
        <StepNumber number={2} />
        Configure Kernel Panic Behavior
      </h3>
      <p className="mb-4">
      This setting configures the system to automatically reboot after a <strong>kernel panic</strong> instead of remaining unresponsive.
      </p>
      <p className="mb-4">
      <strong className="block">Why it's beneficial:</strong>
        Automatic recovery reduces downtime and prevents the need for manual intervention, 
        which is critical in remote or unattended environments where physical access is limited.
      </p>
      <p className="text-lg mb-2">This adjustment automates the following commands:</p>
      <CopyableCode
        code={`
echo "kernel.panic = 10" | sudo tee /etc/sysctl.d/99-kernelpanic.conf
echo "kernel.panic_on_oops = 1" | sudo tee -a /etc/sysctl.d/99-kernelpanic.conf
sudo sysctl -p /etc/sysctl.d/99-kernelpanic.conf
      `}
      />

      <h3 className="text-xl font-semibold mt-16 mb-4 flex items-center">
        <StepNumber number={3} />
        Increase System Limits
      </h3>
      <p className="mb-4">
      This optimization increases system resource limits, including the maximum number of <strong>file watches</strong> and <strong>open file descriptors.</strong>
      </p>
      <p className="mb-4">
      <strong className="block">Why it's beneficial:</strong>
        Higher limits enhance resource utilization, improving performance for applications 
        that monitor large numbers of files or handle high concurrent connections. This is essential 
        for servers running multiple VMs or containers.
      </p>
      <p className="text-lg mb-2">This adjustment automates the following commands:</p>
      <CopyableCode
        code={`
echo "fs.inotify.max_user_watches = 1048576" | sudo tee /etc/sysctl.d/99-maxwatches.conf
echo "* soft nofile 1048576" | sudo tee /etc/security/limits.d/99-limits.conf
sudo sysctl -p
      `}
      />

      <h3 className="text-xl font-semibold mt-16 mb-4 flex items-center">
        <StepNumber number={4} />
        Optimize Journald
      </h3>
      <p className="mb-4">
      This setting configures <strong>systemd-journald</strong> to limit disk usage and optimize logging performance.
      </p>
      <p className="mb-4">
      <strong className="block">Why it's beneficial:</strong>
        Restricting log size prevents excessive disk consumption, 
        reducing the risk of system partitions filling up. Optimized logging also decreases I/O operations, 
        improving system performance, especially in disk-constrained environments.
      </p>
      <p className="text-lg mb-2">This adjustment automates the following commands:</p>
      <CopyableCode
        code={`
echo "SystemMaxUse=64M" | sudo tee -a /etc/systemd/journald.conf
sudo systemctl restart systemd-journald
      `}
      />

      <h3 className="text-xl font-semibold mt-16 mb-4 flex items-center">
        <StepNumber number={5} />
        Optimize Memory Management
      </h3>
      <p className="mb-4">
      This optimization adjusts kernel parameters to improve <strong>memory allocation</strong> and <strong>system responsiveness.</strong>
      </p>
      <p className="mb-4">
      <strong className="block">Why it's beneficial:</strong>
        Efficient memory management prevents out-of-memory (OOM) conditions, 
        enhances stability, and optimizes resource allocation in virtualization environments. 
        This is particularly important for hosts running memory-intensive workloads or multiple VMs.
      </p>
      <p className="text-lg mb-2">This adjustment automates the following commands:</p>
      <CopyableCode
        code={`
echo "vm.swappiness = 10" | sudo tee /etc/sysctl.d/99-memory.conf
echo "vm.vfs_cache_pressure = 50" | sudo tee -a /etc/sysctl.d/99-memory.conf
sudo sysctl -p /etc/sysctl.d/99-memory.conf
      `}
      />


<h3 className="text-xl font-semibold mt-16 mb-4 flex items-center">
        <StepNumber number={6} />
        Improve Entropy Generation with Haveged
      </h3>

      <p className="mb-4">
        <strong>What is entropy?</strong> In computing, entropy is a measure of randomness used by the system for cryptographic operations, secure connections, and random number generation.
      </p>

      <p className="mb-4">
        On Proxmox VE and other virtualized or headless environments, entropy can become insufficient—causing delays or even freezes during operations like generating SSH keys or starting services that rely on encryption.
      </p>

      <p className="mb-4">
        This optimization installs and configures <code>haveged</code>, a daemon that generates high-quality entropy using CPU timing variations to ensure the system always has enough randomness available.
      </p>

      <p className="mb-4">
        <strong>Why it's beneficial:</strong>
      </p>
      <ul className="list-disc pl-5 mb-4">
        <li>Prevents system slowdowns during cryptographic operations</li>
        <li>Improves reliability of secure services and key generation</li>
        <li>Essential for virtual machines and servers without input peripherals</li>
      </ul>

      <p className="text-lg mb-2">This adjustment automates the following steps:</p>
      <CopyableCode
        code={`
      # Install haveged
      apt-get install -y haveged

      # Configure daemon with low-entropy threshold
      cat <<EOF > /etc/default/haveged
      DAEMON_ARGS="-w 1024"
      EOF

      # Enable haveged to run at startup
      systemctl daemon-reload
      systemctl enable haveged
        `}
      />

      <p className="mt-4">
        Once applied, your system will maintain sufficient entropy levels at all times—leading to better performance, stability, and responsiveness.
      </p>

      

      <section className="mt-12 p-4 bg-blue-100 rounded-md">
        <h2 className="text-xl font-semibold mb-2">Automatic Application</h2>
        <p>
          All of these optimizations are automatically applied when selected in the System section. This automation
          ensures that these beneficial settings are applied consistently and correctly, saving time and reducing the
          potential for human error during manual configuration.
        </p>
      </section>
    </div>
  )
}

