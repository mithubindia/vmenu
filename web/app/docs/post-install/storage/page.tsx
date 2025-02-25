import type { Metadata } from "next"

export const metadata: Metadata = {
  title: "ProxMenux Post-Install: Storage Settings",
  description:
    "Comprehensive guide to Storage Settings in the ProxMenux post-install script for optimizing Proxmox VE storage performance and management.",
  openGraph: {
    title: "ProxMenux Post-Install: Storage Settings",
    description:
      "Comprehensive guide to Storage Settings in the ProxMenux post-install script for optimizing Proxmox VE storage performance and management.",
    type: "article",
    url: "https://macrimi.github.io/ProxMenux/docs/post-install/storage",
    images: [
      {
        url: "https://macrimi.github.io/ProxMenux/storage-settings-image.png",
        width: 1200,
        height: 630,
        alt: "ProxMenux Post-Install Storage Settings",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "ProxMenux Post-Install: Storage Settings",
    description:
      "Comprehensive guide to Storage Settings in the ProxMenux post-install script for optimizing Proxmox VE storage performance and management.",
    images: ["https://macrimi.github.io/ProxMenux/storage-settings-image.png"],
  },
}

export default function StorageSettingsPage() {
  return (
    <div className="container mx-auto px-4 py-8">
      <h1 className="text-3xl font-bold mb-6">Storage Settings</h1>
      <p className="mb-4">
        The Storage Settings category in the customizable_post_install.sh script is dedicated to optimizing storage
        configurations and performance in your Proxmox VE environment.
      </p>
      <h2 className="text-2xl font-semibold mt-6 mb-4">Available Optimizations</h2>
      <ul className="list-disc pl-5 mb-6">
        <li className="mb-2">
          <strong>ZFS Optimizations:</strong> Tune ZFS parameters for optimal performance and reliability.
        </li>
        <li className="mb-2">
          <strong>LVM Configurations:</strong> Optimize Logical Volume Manager settings.
        </li>
        <li className="mb-2">
          <strong>Disk I/O Scheduler:</strong> Configure the most suitable I/O scheduler for your storage devices.
        </li>
        {/* Add more list items for each optimization in this category */}
      </ul>
      <h2 className="text-2xl font-semibold mt-6 mb-4">Usage</h2>
      <p className="mb-4">
        When running the customizable_post_install.sh script, you can select specific Storage Settings optimizations to
        apply. Choose the options that best match your storage infrastructure and performance requirements.
      </p>
    </div>
  )
}

