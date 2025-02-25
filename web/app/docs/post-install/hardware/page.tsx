import type { Metadata } from "next"

export const metadata: Metadata = {
  title: "ProxMenux Post-Install: Hardware Settings",
  description:
    "Comprehensive guide to Hardware Settings in the ProxMenux post-install script for Proxmox VE hardware optimization.",
  openGraph: {
    title: "ProxMenux Post-Install: Hardware Settings",
    description:
      "Comprehensive guide to Hardware Settings in the ProxMenux post-install script for Proxmox VE hardware optimization.",
    type: "article",
    url: "https://macrimi.github.io/ProxMenux/docs/post-install/hardware",
    images: [
      {
        url: "https://macrimi.github.io/ProxMenux/hardware-settings-image.png",
        width: 1200,
        height: 630,
        alt: "ProxMenux Post-Install Hardware Settings",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "ProxMenux Post-Install: Hardware Settings",
    description:
      "Comprehensive guide to Hardware Settings in the ProxMenux post-install script for Proxmox VE hardware optimization.",
    images: ["https://macrimi.github.io/ProxMenux/hardware-settings-image.png"],
  },
}

export default function HardwareSettingsPage() {
  return (
    <div className="container mx-auto px-4 py-8">
      <h1 className="text-3xl font-bold mb-6">Hardware Settings</h1>
      <p className="mb-4">
        The Hardware Settings category in the customizable_post_install.sh script focuses on optimizing Proxmox VE for
        your specific hardware configuration.
      </p>
      <h2 className="text-2xl font-semibold mt-6 mb-4">Available Optimizations</h2>
      <ul className="list-disc pl-5 mb-6">
        <li className="mb-2">
          <strong>CPU Optimizations:</strong> Configure settings for optimal CPU performance.
        </li>
        <li className="mb-2">
          <strong>Memory Management:</strong> Optimize memory usage and allocation.
        </li>
        <li className="mb-2">
          <strong>Storage Performance:</strong> Tune storage settings for improved I/O performance.
        </li>
        {/* Add more list items for each optimization in this category */}
      </ul>
      <h2 className="text-2xl font-semibold mt-6 mb-4">Usage</h2>
      <p className="mb-4">
        During the execution of customizable_post_install.sh, you'll have the option to apply various Hardware Settings
        optimizations. Choose the ones that are most relevant to your hardware setup for best results.
      </p>
    </div>
  )
}

