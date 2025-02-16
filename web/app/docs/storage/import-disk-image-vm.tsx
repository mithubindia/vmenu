import type { Metadata } from "next"

export const metadata: Metadata = {
  title: "Import Disk Image to a VM | ProxMenux Documentation",
  description: "Learn how to import a disk image to a virtual machine in Proxmox VE using ProxMenux.",
}

export default function ImportDiskImageVM() {
  return (
    <div className="max-w-3xl mx-auto">
      <h1 className="text-3xl font-bold mb-6">Import Disk Image to a VM</h1>
      <p className="mb-4">
        This guide will walk you through the process of importing a disk image to a virtual machine in Proxmox VE using
        ProxMenux.
      </p>
      {/* Add more content here */}
    </div>
  )
}

