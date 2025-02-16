import type { Metadata } from "next"

export const metadata: Metadata = {
  title: "HW iGPU acceleration to an LXC | ProxMenux Documentation",
  description: "Learn how to enable hardware iGPU acceleration for an LXC container in Proxmox VE using ProxMenux.",
}

export default function IGPUAccelerationLXC() {
  return (
    <div className="max-w-3xl mx-auto">
      <h1 className="text-3xl font-bold mb-6">HW iGPU acceleration to an LXC</h1>
      <p className="mb-4">
        This guide will walk you through the process of enabling hardware iGPU acceleration for an LXC container in
        Proxmox VE using ProxMenux.
      </p>
      {/* Add more content here */}
    </div>
  )
}

