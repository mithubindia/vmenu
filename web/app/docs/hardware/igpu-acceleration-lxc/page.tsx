import type { Metadata } from "next"

export const metadata: Metadata = {
  title: "Add HW iGPU acceleration to an LXC | ProxMenux Documentation",
  description:
    "Learn how to configure Intel iGPU acceleration for an LXC container in Proxmox VE using ProxMenux. This guide covers the setup process, required modifications, and driver installation.",
}

export default function IGPUAccelerationLXC() {
  return (
    <div className="max-w-3xl mx-auto">
      <h1 className="text-3xl font-bold mb-6">Enable Intel iGPU in an LXC</h1>
      <p className="mb-4">
        This guide explains how to enable Intel Integrated GPU (iGPU) support in LXC containers within Proxmox VE using
        ProxMenux. The script automates the configuration, ensuring the container has access to GPU resources for
        hardware-accelerated tasks such as video transcoding, rendering, and OpenCL applications.
      </p>

      <h2 className="text-2xl font-bold mb-4">🔹 What This Script Does</h2>
      <ul className="list-disc list-inside mb-4">
        <li>Lists available LXC containers and allows the user to select one.</li>
        <li>Validates the selected container and ensures it is properly stopped before making changes.</li>
        <li>Configures the LXC container to enable Intel iGPU access.</li>
        <li>Modifies the container configuration to allow GPU passthrough.</li>
        <li>Ensures the container is privileged for proper hardware access.</li>
        <li>Installs necessary iGPU drivers inside the container.</li>
        <li>Sets permissions for `/dev/dri` to allow GPU access.</li>
      </ul>

      <h2 className="text-2xl font-bold mb-4">🛠️ Prerequisites</h2>
      <ul className="list-disc list-inside mb-4">
        <li>Proxmox VE installed and running.</li>
        <li>An LXC container created and available.</li>
        <li>An Intel iGPU compatible with VA-API and OpenCL.</li>
        <li>ProxMenux installed and updated.</li>
      </ul>

      <h2 className="text-2xl font-bold mb-4">⚙️ How to Use</h2>
      <p className="mb-4">
        To enable Intel iGPU support for an LXC container, run the following command from ProxMenux:
      </p>
      <pre className="bg-gray-900 text-white p-4 rounded-md overflow-auto mb-4">
        ./proxmenux.sh --enable-igpu
      </pre>
      <p className="mb-4">
        This will launch an interactive menu where you can select an LXC container. The script will then apply the
        necessary configurations and install required drivers.
      </p>

      <h2 className="text-2xl font-bold mb-4">🔧 Script Breakdown</h2>

      <h3 className="text-xl font-semibold mt-4 mb-2">1️⃣ Select an LXC Container</h3>
      <p className="mb-4">
        The script lists all available LXC containers and allows the user to choose one. If no container is selected or
        available, it exits with an error.
      </p>

      <h3 className="text-xl font-semibold mt-4 mb-2">2️⃣ Validate and Stop the Container</h3>
      <p className="mb-4">
        Before applying modifications, the script ensures that the container is stopped. If it is running, it is
        automatically stopped to prevent conflicts.
      </p>

      <h3 className="text-xl font-semibold mt-4 mb-2">3️⃣ Configure the LXC Container</h3>
      <p className="mb-4">
        The script modifies the container configuration file (`/etc/pve/lxc/[ID].conf`) to:
      </p>
      <ul className="list-disc list-inside mb-4">
        <li>Ensure the container is **privileged**.</li>
        <li>Add GPU-related permissions (`cgroup2.devices.allow`).</li>
        <li>Mount `/dev/dri` and `/dev/fb0` for GPU access.</li>
      </ul>

      <h3 className="text-xl font-semibold mt-4 mb-2">4️⃣ Install iGPU Drivers</h3>
      <p className="mb-4">
        The script starts the container and installs essential Intel iGPU drivers, including:
      </p>
      <pre className="bg-gray-900 text-white p-4 rounded-md overflow-auto mb-4">
        apt-get install -y va-driver-all ocl-icd-libopencl1 intel-opencl-icd vainfo intel-gpu-tools
      </pre>
      <p className="mb-4">
        It also ensures that necessary user permissions are applied for access to `/dev/dri`.
      </p>

      <h2 className="text-2xl font-bold mb-4">🎯 Expected Outcome</h2>
      <p className="mb-4">
        Once the script finishes, the LXC container will have Intel iGPU access enabled, allowing applications inside
        the container to leverage hardware acceleration for graphics and compute tasks.
      </p>

      <h2 className="text-2xl font-bold mb-4">📌 Notes</h2>
      <ul className="list-disc list-inside mb-4">
        <li>This script modifies the LXC container's configuration. Always back up your settings before proceeding.</li>
        <li>Ensure that your Proxmox host has the necessary drivers installed for Intel iGPU support.</li>
        <li>For troubleshooting, check logs inside the container after running the script.</li>
      </ul>

      <h2 className="text-2xl font-bold mb-4">📖 Additional Resources</h2>
      <ul className="list-disc list-inside mb-4">
        <li>
          <a href="https://pve.proxmox.com/wiki/Linux_Containers" className="text-blue-400 hover:underline">
            Proxmox LXC Documentation
          </a>
        </li>
        <li>
          <a href="https://pve.proxmox.com/wiki/PCI_Passthrough" className="text-blue-400 hover:underline">
            PCI Passthrough Guide
          </a>
        </li>
      </ul>

      <p className="text-gray-400 mt-6">
        If you encounter issues or have suggestions, consider contributing to the
        <a
          href="https://github.com/MacRimi/ProxMenux"
          className="text-blue-400 hover:underline ml-1"
        >
          ProxMenux GitHub repository
        </a>
        .
      </p>
    </div>
  )
}
