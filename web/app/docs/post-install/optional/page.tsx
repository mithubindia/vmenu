import type { Metadata } from "next"
import { Plus } from "lucide-react"

export const metadata: Metadata = {
  title: "ProxMenux Post-Install: Optional Settings",
  description:
    "Guide to Optional Settings in the ProxMenux post-install script for additional Proxmox VE customizations and features.",
  openGraph: {
    title: "ProxMenux Post-Install: Optional Settings",
    description:
      "Guide to Optional Settings in the ProxMenux post-install script for additional Proxmox VE customizations and features.",
    type: "article",
    url: "https://macrimi.github.io/ProxMenux/docs/post-install/optional",
    images: [
      {
        url: "https://macrimi.github.io/ProxMenux/optional-settings-image.png",
        width: 1200,
        height: 630,
        alt: "ProxMenux Post-Install Optional Settings",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "ProxMenux Post-Install: Optional Settings",
    description:
      "Guide to Optional Settings in the ProxMenux post-install script for additional Proxmox VE customizations and features.",
    images: ["https://macrimi.github.io/ProxMenux/optional-settings-image.png"],
  },
}

export default function OptionalSettingsPage() {
  return (
    <div className="container mx-auto px-4 py-8">
      <div className="flex items-center mb-6">
        <Plus className="h-8 w-8 mr-2 text-blue-500" />
        <h1 className="text-3xl font-bold">Optional Settings</h1>
      </div>
      <p className="mb-4">
        The Optional Settings category in the customizable_post_install.sh script provides additional customizations and
        features that you may choose to implement in your Proxmox VE environment.
      </p>
      <h2 className="text-2xl font-semibold mt-6 mb-4">Available Options</h2>
      <ul className="list-disc pl-5 mb-6">
        <li className="mb-2">
          <strong>Additional Software:</strong> Install optional software packages or tools.
        </li>
        <li className="mb-2">
          <strong>Custom Scripts:</strong> Add your own scripts to run post-installation.
        </li>
        <li className="mb-2">
          <strong>Extended Configurations:</strong> Apply additional, non-essential configurations.
        </li>
        {/* Add more list items for each option in this category */}
      </ul>
      <h2 className="text-2xl font-semibold mt-6 mb-4">Usage</h2>
      <p className="mb-4">
        When running the customizable_post_install.sh script, you'll be presented with these Optional Settings. You can
        choose to apply any or all of these settings based on your specific needs and preferences.
      </p>
    </div>
  )
}

