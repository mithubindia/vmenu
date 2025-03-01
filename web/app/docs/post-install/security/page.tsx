import type { Metadata } from "next"
import { Shield } from "lucide-react"

export const metadata: Metadata = {
  title: "ProxMenux Post-Install: Security Settings",
  description:
    "In-depth guide to Security Settings in the ProxMenux post-install script for enhancing Proxmox VE security measures and configurations.",
  // ... (rest of the metadata remains the same)
}

export default function SecuritySettingsPage() {
  return (
    <div className="container mx-auto px-4 py-8">
      <div className="flex items-center mb-6">
        <Shield className="h-8 w-8 mr-2 text-blue-500" />
        <h1 className="text-3xl font-bold">Security Settings</h1>
      </div>
      {/* ... (rest of the component remains the same) */}
    </div>
  )
}

