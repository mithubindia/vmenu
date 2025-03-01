import type { Metadata } from "next"
import { Shield } from "lucide-react"

export const metadata: Metadata = {
  title: "ProxMenux Post-Install: Security Settings",
  description:
    "In-depth guide to Security Settings in the ProxMenux post-install script for enhancing Proxmox VE security measures and configurations.",
  openGraph: {
    title: "ProxMenux Post-Install: Security Settings",
    description:
      "In-depth guide to Security Settings in the ProxMenux post-install script for enhancing Proxmox VE security measures and configurations.",
    type: "article",
    url: "https://macrimi.github.io/ProxMenux/docs/post-install/security",
    images: [
      {
        url: "https://macrimi.github.io/ProxMenux/security-settings-image.png",
        width: 1200,
        height: 630,
        alt: "ProxMenux Post-Install Security Settings",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "ProxMenux Post-Install: Security Settings",
    description:
      "In-depth guide to Security Settings in the ProxMenux post-install script for enhancing Proxmox VE security measures and configurations.",
    images: ["https://macrimi.github.io/ProxMenux/security-settings-image.png"],
  },
}

export default function SecuritySettingsPage() {
  return (
    <div className="container mx-auto px-4 py-8">
      <div className="flex items-center mb-6">
        <Shield className="h-8 w-8 mr-2 text-blue-500" />
        <h1 className="text-3xl font-bold">Security Settings</h1>
      <p className="mb-4">
        The Security Settings category in the customizable_post_install.sh script focuses on enhancing the security
        measures and configurations of your Proxmox VE installation.
      </p>
      <h2 className="text-2xl font-semibold mt-6 mb-4">Available Optimizations</h2>
      <ul className="list-disc pl-5 mb-6">
        <li className="mb-2">
          <strong>SSH Hardening:</strong> Implement best practices for securing SSH access.
        </li>
        <li className="mb-2">
          <strong>Firewall Rules:</strong> Set up and configure robust firewall rules.
        </li>
        <li className="mb-2">
          <strong>User Authentication:</strong> Enhance user authentication mechanisms.
        </li>
        {/* Add more list items for each optimization in this category */}
      </ul>
      <h2 className="text-2xl font-semibold mt-6 mb-4">Usage</h2>
      <p className="mb-4">
        When running the customizable_post_install.sh script, you can select specific Security Settings optimizations to
        apply. Choose the options that best align with your security requirements and policies.
      </p>
    </div>
  )
}

