import type { Metadata } from "next"
import { Box } from 'lucide-react'
import CopyableCode from "@/components/CopyableCode"

export const metadata: Metadata = {
  title: "ProxMenux Post-Install: Virtualization Settings",
  description:
    "Detailed guide to the Virtualization Settings category in the ProxMenux post-install script for Proxmox VE optimization.",
  openGraph: {
    title: "ProxMenux Post-Install: Virtualization Settings",
    description:
      "Detailed guide to the Virtualization Settings category in the ProxMenux post-install script for Proxmox VE optimization.",
    type: "article",
    url: "https://macrimi.github.io/ProxMenux/docs/post-install/virtualization",
    images: [
      {
        url: "https://macrimi.github.io/ProxMenux/virtualization-settings-image.png",
        width: 1200,
        height: 630,
        alt: "ProxMenux Post-Install Virtualization Settings",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "ProxMenux Post-Install: Virtualization Settings",
    description:
      "Detailed guide to the Virtualization Settings category in the ProxMenux post-install script for Proxmox VE optimization.",
    images: ["https://macrimi.github.io/ProxMenux/virtualization-settings-image.png"],
  },
}

export default function VirtualizationSettingsPage() {
  return (
    <div className="container mx-auto px-4 py-8">
      <div className="flex items-center mb-6">
        <Box className="h-8 w-8 mr-2 text-blue-500" />
        <h1 className="text-3xl font-bold">Virtualization Settings</h1>
      </div>
      <p className="mb-4">
        The <strong>Virtualization Settings</strong> category focuses on optimizing your
        Proxmox VE installation for enhanced virtualization performance, compatibility, and functionality. These settings
        are crucial for creating a robust and efficient virtualization environment.
      </p>
      <h2 className="text-2xl font-semibold mt-8 mb-4">Available Optimizations</h2>
      
      <section className="mb-8">
        <h3 className="text-xl font-semibold mb-2">Enable VFIO IOMMU Support</h3>
        <p className="mb-4">
          This optimization enables IOMMU (Input-Output Memory Management Unit) and configures VFIO (Virtual Function I/O) for PCI passthrough, allowing direct assignment of PCI devices to virtual machines.
        </p>
        <p className="mb-4">
          <strong>Why it's important:</strong> IOMMU and VFIO support enables near-native performance for PCI devices (like GPUs or network cards) in virtual machines. This is crucial for high-performance virtualization scenarios, such as GPU-accelerated workloads or network-intensive applications. It allows VMs to directly access hardware, bypassing the hypervisor, which significantly improves performance and reduces latency.
        </p>
        <h4 className="text-lg font-semibold mb-2">To apply this setting manually, run:</h4>
        <CopyableCode code={`# For Intel CPUs
echo "intel_iommu=on" | sudo tee -a /etc/default/grub
# For AMD CPUs
echo "amd_iommu=on" | sudo tee -a /etc/default/grub

echo "vfio vfio_iommu_type1 vfio_pci vfio_virqfd" | sudo tee -a /etc/modules

sudo update-grub
sudo update-initramfs -u -k all`} />
      </section>

      <section className="mb-8">
        <h3 className="text-xl font-semibold mb-2">Install Relevant Guest Agent</h3>
        <p className="mb-4">
          This optimization detects the virtualization environment and installs the appropriate guest agent for improved integration between the host and guest systems.
        </p>
        <p className="mb-4">
          <strong>Why it's important:</strong> Guest agents improve communication and integration between the host and guest systems. They enable features like graceful shutdown of virtual machines, file sharing between host and guest, better performance monitoring, and enhanced resource allocation. This leads to more efficient management of VMs and improved overall system performance.
        </p>
        <h4 className="text-lg font-semibold mb-2">To apply this setting manually, run:</h4>
        <CopyableCode code={`# For QEMU/KVM VMs
sudo apt-get install -y qemu-guest-agent

# For VMware VMs
sudo apt-get install -y open-vm-tools

# For VirtualBox VMs
sudo apt-get install -y virtualbox-guest-utils`} />
      </section>
      
      <section className="mb-8">
        <h3 className="text-xl font-semibold mb-2">Configure KSM (Kernel Samepage Merging)</h3>
        <p className="mb-4">
          This optimization installs and configures the KSM control daemon, which helps optimize memory usage in virtualized environments by sharing identical memory pages between multiple virtual machines.
        </p>
        <p className="mb-4">
          <strong>Why it's important:</strong> KSM can significantly reduce memory usage in environments with many similar VMs, allowing for higher VM density on a single host. This is particularly beneficial for scenarios where many VMs run similar operating systems or applications. By reducing overall memory usage, KSM can improve system performance and allow for more efficient resource utilization.
        </p>
        <h4 className="text-lg font-semibold mb-2">To apply this setting manually, run:</h4>
        <CopyableCode code={`sudo apt-get install -y ksm-control-daemon

echo "KSM_ENABLED=1" | sudo tee -a /etc/default/ksm
echo "KSM_SLEEP_MSEC=100" | sudo tee -a /etc/default/ksm

sudo systemctl enable ksm
sudo systemctl start ksm`} />
      </section>
      
      <section className="mb-8">
        <h3 className="text-xl font-semibold mb-2">Optimize CPU Governor</h3>
        <p className="mb-4">
          This setting configures the CPU governor to optimize performance for virtualization workloads.
        </p>
        <p className="mb-4">
          <strong>Why it's important:</strong> The CPU governor controls how the processor scales its frequency based on system load. For virtualization environments, setting the governor to 'performance' ensures that the CPU always runs at its maximum frequency, providing consistent performance for VMs. This is crucial for workloads that require predictable and high CPU performance.
        </p>
        <h4 className="text-lg font-semibold mb-2">To apply this setting manually, run:</h4>
        <CopyableCode code={`sudo apt-get install -y cpufrequtils
echo 'GOVERNOR="performance"' | sudo tee /etc/default/cpufrequtils
sudo systemctl restart cpufrequtils`} />
      </section>
      
      <section className="mb-8">
        <h3 className="text-xl font-semibold mb-2">Enable Huge Pages Support</h3>
        <p className="mb-4">
          This optimization enables and configures huge pages support, which can improve memory management efficiency for large-memory VMs.
        </p>
        <p className="mb-4">
          <strong>Why it's important:</strong> Huge pages reduce the overhead of Translation Lookaside Buffer (TLB) lookups, which can significantly improve performance for memory-intensive applications running in VMs. This is particularly beneficial for databases, in-memory caches, and other applications that manage large amounts of memory.
        </p>
        <h4 className="text-lg font-semibold mb-2">To apply this setting manually, run:</h4>
        <CopyableCode code={`echo "vm.nr_hugepages = 1024" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

echo "hugetlbfs /dev/hugepages hugetlbfs defaults 0 0" | sudo tee -a /etc/fstab
sudo mount -a`} />
      </section>
      
      <section className="mt-12 p-4 bg-blue-100 rounded-md">
        <h2 className="text-xl font-semibold mb-2">Automatic Application</h2>
        <p>
          All of these optimizations are automatically applied when selected in the Virtualization section. This automation ensures that these beneficial settings are applied
          consistently and correctly, saving time and reducing the potential for human error during manual
          configuration.
        </p>
      </section>
    </div>
  );
}