import type { Metadata } from "next"
import { Network } from "lucide-react"

export const metadata: Metadata = {
  title: "ProxMenux Post-Install: Network Settings",
  description:
    "Detailed guide to Network Settings in the ProxMenux post-install script for optimizing Proxmox VE network performance and configuration.",
  // ... (rest of the metadata remains the same)
}

export default function NetworkSettingsPage() {
  return (
    <div className="container mx-auto px-4 py-8">
      <div className="flex items-center mb-6">
        <Network className="h-8 w-8 mr-2 text-blue-500" />
        <h1 className="text-3xl font-bold">Network Settings</h1>
      </div>
      {/* ... (rest of the component remains the same) */}
    </div>
  )
}

