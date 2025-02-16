import type { Metadata } from "next"

export const metadata: Metadata = {
  title: "Verify Network | ProxMenux Documentation",
  description: "Learn how to verify network configuration and connectivity in Proxmox VE using ProxMenux.",
}

export default function VerifyNetwork() {
  return (
    <div className="max-w-3xl mx-auto">
      <h1 className="text-3xl font-bold mb-6">Verify Network</h1>
      <p className="mb-4">
        This guide will show you how to verify network configuration and connectivity in Proxmox VE using ProxMenux.
      </p>
      <h2 className="text-2xl font-semibold mt-8 mb-4">Network Verification Steps</h2>
      <ol className="list-decimal pl-6 space-y-2">
        <li>Check network interface status</li>
        <li>Verify IP address configuration</li>
        <li>Test DNS resolution</li>
        <li>Ping gateway and external servers</li>
        <li>Verify network throughput</li>
      </ol>
      <h2 className="text-2xl font-semibold mt-8 mb-4">Using ProxMenux for Network Verification</h2>
      <p className="mb-4">
        Detailed instructions on how to use ProxMenux to perform these verification steps will be provided here.
      </p>
      {/* Add more content here */}
    </div>
  )
}

