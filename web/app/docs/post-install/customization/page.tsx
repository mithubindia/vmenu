import type { Metadata } from "next"
import { Sliders } from "lucide-react"

export const metadata: Metadata = {
  title: "ProxMenux Post-Install: Customization Settings",
  description:
    "Detailed guide to Customization Settings in the ProxMenux post-install script for personalizing your Proxmox VE environment.",
  openGraph: {
    title: "ProxMenux Post-Install: Customization Settings",
    description:
      "Detailed guide to Customization Settings in the ProxMenux post-install script for personalizing your Proxmox VE environment.",
    type: "article",
    url: "https://macrimi.github.io/ProxMenux/docs/post-install/customization",
    images: [
      {
        url: "https://macrimi.github.io/ProxMenux/customization-settings-image.png",
        width: 1200,
        height: 630,
        alt: "ProxMenux Post-Install Customization Settings",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "ProxMenux Post-Install: Customization Settings",
    description:
      "Detailed guide to Customization Settings in the ProxMenux post-install script for personalizing your Proxmox VE environment.",
    images: ["https://macrimi.github.io/ProxMenux/customization-settings-image.png"],
  },
}

export default function CustomizationSettingsPage() {
  return (
    <div className="container mx-auto px-4 py-8">
      <div className="flex items-center mb-6">
        <Sliders className="h-8 w-8 mr-2 text-blue-500" />
        <h1 className="text-3xl font-bold">Customization Settings</h1>
      <p className="mb-4">
        The Customization Settings category in the customizable_post_install.sh script allows you to personalize various
        aspects of your Proxmox VE environment.
      </p>
      <h2 className="text-2xl font-semibold mt-6 mb-4">Available Customizations</h2>
      <ul className="list-disc pl-5 mb-6">
        <li className="mb-2">
          <strong>UI Customizations:</strong> Modify the Proxmox VE web interface appearance.
        </li>
        <li className="mb-2">
          <strong>Custom Scripts:</strong> Add your own scripts to run post-installation.
        </li>
        <li className="mb-2">
          <strong>Email Notifications:</strong> Configure email settings for system notifications.
        </li>
        {/* Add more list items for each customization option in this category */}
      </ul>
      <h2 className="text-2xl font-semibold mt-6 mb-4">Usage</h2>
      <p className="mb-4">
        During the execution of customizable_post_install.sh, you'll have the option to apply various Customization
        Settings. Select the options that best suit your preferences and operational needs.
      </p>
    </div>
  )
}

