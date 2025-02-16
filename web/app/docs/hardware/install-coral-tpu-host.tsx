import type { Metadata } from "next"

export const metadata: Metadata = {
  title: "Install Coral TPU on the Host | ProxMenux Documentation",
  description: "Learn how to install a Coral TPU on the Proxmox VE host using ProxMenux.",
}

export default function InstallCoralTPUHost() {
  return (
    <div className="max-w-3xl mx-auto">
      <h1 className="text-3xl font-bold mb-6">Install Coral TPU on the Host</h1>
      <p className="mb-4">
        This guide will walk you through the process of installing a Coral TPU on your Proxmox VE host using ProxMenux.
      </p>
      {/* Add more content here */}
    </div>
  )
}

