import type { Metadata } from "next"

export const metadata: Metadata = {
  title: "Disk Passthrough to a VM | ProxMenux Documentation",
  description: "Learn how to set up disk passthrough to a virtual machine in Proxmox VE using ProxMenux.",
}

export default function DiskPassthroughVM() {
  return (
    <div className="max-w-3xl mx-auto">
      <h1 className="text-3xl font-bold mb-6">Disk Passthrough to a VM</h1>
      <p className="mb-4">
        This guide will walk you through the process of setting up disk passthrough to a virtual machine in Proxmox VE
        using ProxMenux.
      </p>
      {/* Add more content here */}
    </div>
  )
}

