import type { Metadata } from "next"
import { Box } from "lucide-react"

export const metadata: Metadata = {
  title: "ProxMenux Post-Install: Virtualization Settings",
  description:
    "In-depth guide to Virtualization Settings in the ProxMenux post-install script for optimizing Proxmox VE virtualization capabilities.",
  // ... (rest of the metadata remains the same)
}

export default function VirtualizationSettingsPage() {
  return (
    <div className="container mx-auto px-4 py-8">
      <div className="flex items-center mb-6">
        <Box className="h-8 w-8 mr-2 text-blue-500" />
        <h1 className="text-3xl font-bold">Virtualization Settings</h1>
      </div>
      {/* ... (rest of the component remains the same) */}
    </div>
  )
}

