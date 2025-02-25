import type { Metadata } from "next"
import { Settings } from "lucide-react"

export const metadata: Metadata = {
  title: "ProxMenux Post-Install: Basic Settings",
  description:
    "Detailed guide to the Basic Settings category in the ProxMenux post-install script for Proxmox VE optimization.",
  openGraph: {
    title: "ProxMenux Post-Install: Basic Settings",
    description:
      "Detailed guide to the Basic Settings category in the ProxMenux post-install script for Proxmox VE optimization.",
    type: "article",
    url: "https://macrimi.github.io/ProxMenux/docs/post-install/basic-settings",
    images: [
      {
        url: "https://macrimi.github.io/ProxMenux/basic-settings-image.png",
        width: 1200,
        height: 630,
        alt: "ProxMenux Post-Install Basic Settings",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "ProxMenux Post-Install: Basic Settings",
    description:
      "Detailed guide to the Basic Settings category in the ProxMenux post-install script for Proxmox VE optimization.",
    images: ["https://macrimi.github.io/ProxMenux/basic-settings-image.png"],
  },
}

export default function BasicSettingsPage() {
  return (
    <div className="container mx-auto px-4 py-8">
      <div className="flex items-center mb-6">
        <Settings className="h-8 w-8 mr-2 text-blue-500" />
        <h1 className="text-3xl font-bold">Basic Settings</h1>
      </div>
      <p className="mb-4">
        The Basic Settings category in the customizable_post_install.sh script covers fundamental configurations for
        your Proxmox VE installation. These settings lay the groundwork for a well-optimized system.
      </p>
      <h2 className="text-2xl font-semibold mt-6 mb-4">Available Optimizations</h2>
      <ul className="list-disc pl-5 mb-6">
        <li className="mb-2">
          <strong>Timezone Configuration:</strong> Set the system timezone to ensure accurate time-based operations.
        </li>
        <li className="mb-2">
          <strong>Hostname Setup:</strong> Configure a custom hostname for easier identification of your Proxmox VE
          server.
        </li>
        <li className="mb-2">
          <strong>Repository Management:</strong> Optimize package repositories for faster updates and access to
          necessary software.
        </li>
        {/* Add more list items for each optimization in this category */}
      </ul>
      <h2 className="text-2xl font-semibold mt-6 mb-4">Usage</h2>
      <p className="mb-4">
        When running the customizable_post_install.sh script, you'll be prompted to choose which Basic Settings
        optimizations to apply. You can select all or pick specific ones based on your needs.
      </p>
      <p>
        For detailed information on each optimization and its impact, refer to the script comments or consult the
        ProxMenux documentation.
      </p>
    </div>
  )
}

