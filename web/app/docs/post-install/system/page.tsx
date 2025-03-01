import type { Metadata } from "next"
import { Server } from "lucide-react"

export const metadata: Metadata = {
  title: "ProxMenux Post-Install: System Settings",
  description:
    "Detailed guide to the System Settings category in the ProxMenux post-install script for Proxmox VE optimization.",
  // ... (rest of the metadata remains the same)
}

export default function SystemSettingsPage() {
  return (
    <div className="container mx-auto px-4 py-8">
      <div className="flex items-center mb-6">
        <Server className="h-8 w-8 mr-2 text-blue-500" />
        <h1 className="text-3xl font-bold">System Settings</h1>
      </div>
      <p className="mb-4">
        The System Settings category in the customizable_post_install.sh script focuses on core system configurations
        and optimizations for your Proxmox VE installation.
      </p>
      <h2 className="text-2xl font-semibold mt-6 mb-4">Available Optimizations</h2>
      <ul className="list-disc pl-5 mb-6">
        <li className="mb-2">
          <strong>Kernel Parameters:</strong> Optimize kernel settings for improved performance and stability.
        </li>
        <li className="mb-2">
          <strong>System Limits:</strong> Adjust system limits for better resource management.
        </li>
        <li className="mb-2">
          <strong>Scheduled Tasks:</strong> Set up important system maintenance tasks.
        </li>
        {/* Add more list items for each optimization in this category */}
      </ul>
      <h2 className="text-2xl font-semibold mt-6 mb-4">Usage</h2>
      <p className="mb-4">
        When running the customizable_post_install.sh script, you'll be prompted to choose which System Settings
        optimizations to apply. Select the ones that best suit your Proxmox VE environment and requirements.
      </p>
    </div>
  )
}

