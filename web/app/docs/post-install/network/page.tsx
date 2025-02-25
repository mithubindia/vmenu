import type { Metadata } from "next"

export const metadata: Metadata = {
  title: "ProxMenux Post-Install: Network Settings",
  description:
    "Detailed guide to Network Settings in the ProxMenux post-install script for optimizing Proxmox VE network performance and configuration.",
  openGraph: {
    title: "ProxMenux Post-Install: Network Settings",
    description:
      "Detailed guide to Network Settings in the ProxMenux post-install script for optimizing Proxmox VE network performance and configuration.",
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
      "Detailed guide to Network Settings in the ProxMenux post-install script for optimizing Proxmox VE network performance and configuration.",
    images: ["https://macrimi.github.io/ProxMenux/network-settings-image.png"],
  },
}

export default function NetworkSettingsPage() {
  return (
    <div className="container mx-auto px-4 py-8">
      <h1 className="text-3xl font-bold mb-6">Network Settings</h1>
      <p className="mb-4">
        The Network Settings category in the customizable_post_install.sh script focuses on optimizing network
        configurations and performance for your Proxmox VE installation.
      </p>
      <h2 className="text-2xl font-semibold mt-6 mb-4">Available Optimizations</h2>
      <ul className="list-disc pl-5 mb-6">
        <li className="mb-2">
          <strong>Network Interface Tuning:</strong> Optimize network interface settings for improved performance.
        </li>
        <li className="mb-2">
          <strong>Firewall Configurations:</strong> Set up and configure firewall rules for enhanced security.
        </li>
        <li className="mb-2">
          <strong>Network Bridge Settings:</strong> Optimize network bridging for efficient VM and container networking.
        </li>
        {/* Add more list items for each optimization in this category */}
      </ul>
      <h2 className="text-2xl font-semibold mt-6 mb-4">Usage</h2>
      <p className="mb-4">
        During the execution of customizable_post_install.sh, you'll have the option to apply various Network Settings
        optimizations. Select the configurations that best suit your network infrastructure and requirements.
      </p>
    </div>
  )
}

