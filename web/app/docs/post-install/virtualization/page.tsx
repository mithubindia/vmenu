import type { Metadata } from "next"
import { Box } from "lucide-react"

export const metadata: Metadata = {
  title: "ProxMenux Post-Install: Virtualization Settings",
  description:
    "In-depth guide to Virtualization Settings in the ProxMenux post-install script for optimizing Proxmox VE virtualization capabilities.",
  openGraph: {
    title: "ProxMenux Post-Install: Virtualization Settings",
    description:
      "In-depth guide to Virtualization Settings in the ProxMenux post-install script for optimizing Proxmox VE virtualization capabilities.",
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
      "In-depth guide to Virtualization Settings in the ProxMenux post-install script for optimizing Proxmox VE virtualization capabilities.",
    images: ["https://macrimi.github.io/ProxMenux/virtualization-settings-image.png"],
  },
}

export default function VirtualizationSettingsPage() {
  return (
    <div className="container mx-auto px-4 py-8">
      <div className="flex items-center mb-6">
        <Box className="h-8 w-8 mr-2 text-blue-500" />
        <h1 className="text-3xl font-bold">Virtualization Settings</h1>
      <p className="mb-4">
        The Virtualization Settings category in the customizable_post_install.sh script is dedicated to optimizing the
        core virtualization capabilities of Proxmox VE.
      </p>
      <h2 className="text-2xl font-semibold mt-6 mb-4">Available Optimizations</h2>
      <ul className="list-disc pl-5 mb-6">
        <li className="mb-2">
          <strong>KVM Optimizations:</strong> Enhance KVM performance and features.
        </li>
        <li className="mb-2">
          <strong>LXC Container Settings:</strong> Optimize LXC container configurations.
        </li>
        <li className="mb-2">
          <strong>VM Template Configurations:</strong> Set up efficient VM templates for quick deployment.
        </li>
        {/* Add more list items for each optimization in this category */}
      </ul>
      <h2 className="text-2xl font-semibold mt-6 mb-4">Usage</h2>
      <p className="mb-4">
        When running the customizable_post_install.sh script, you can select specific Virtualization Settings
        optimizations to apply. Choose the options that best align with your virtualization needs and workload types.
      </p>
    </div>
  )
}

