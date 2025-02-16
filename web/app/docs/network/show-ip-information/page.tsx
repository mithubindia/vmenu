import type { Metadata } from "next"

export const metadata: Metadata = {
  title: "Show IP Information | ProxMenux Documentation",
  description: "Learn how to display IP information for Proxmox VE and its virtual machines using ProxMenux.",
}

export default function ShowIPInformation() {
  return (
    <div className="max-w-3xl mx-auto">
      <h1 className="text-3xl font-bold mb-6">Show IP Information</h1>
      <p className="mb-4">
        This guide explains how to display IP information for Proxmox VE and its virtual machines using ProxMenux.
      </p>
      <h2 className="text-2xl font-semibold mt-8 mb-4">IP Information Available</h2>
      <ul className="list-disc pl-6 space-y-2">
        <li>Host IP addresses</li>
        <li>Virtual machine IP addresses</li>
        <li>Network interface details</li>
        <li>Routing information</li>
      </ul>
      <h2 className="text-2xl font-semibold mt-8 mb-4">Using ProxMenux to Show IP Information</h2>
      <p className="mb-4">
        Step-by-step instructions on how to use ProxMenux to display various types of IP information will be provided
        here.
      </p>
      {/* Add more content here */}
    </div>
  )
}

