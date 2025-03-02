import type { Metadata } from "next"
import { Sliders } from "lucide-react"

export const metadata: Metadata = {
  title: "ProxMenux Post-Install: Customization Settings",
  description:
    "Detailed guide to Customization Settings in the ProxMenux post-install script for personalizing your Proxmox VE environment.",
  // ... (rest of the metadata remains the same)
}

export default function CustomizationSettingsPage() {
  return (
    <div className="container mx-auto px-4 py-8">
      <div className="flex items-center mb-6">
        <Sliders className="h-8 w-8 mr-2 text-blue-500" />
        <h1 className="text-3xl font-bold">Customization Settings</h1>
      </div>
      {/* ... (rest of the component remains the same) */}
    </div>
  )
}

