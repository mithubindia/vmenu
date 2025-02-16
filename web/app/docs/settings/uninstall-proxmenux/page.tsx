import type { Metadata } from "next"
import { Steps } from "@/components/ui/steps"

export const metadata: Metadata = {
  title: "Uninstall ProxMenux | ProxMenux Documentation",
  description: "Learn how to safely uninstall ProxMenux from your Proxmox VE system.",
}

export default function UninstallProxMenux() {
  return (
    <div className="max-w-3xl mx-auto">
      <h1 className="text-3xl font-bold mb-6">Uninstall ProxMenux</h1>
      <p className="mb-4">
        If you need to remove ProxMenux from your Proxmox VE system, this guide will walk you through the process.
        Please note that uninstalling ProxMenux will remove all its components and settings.
      </p>

      <h2 className="text-2xl font-semibold mt-8 mb-4">Before You Begin</h2>
      <p className="mb-4">Before uninstalling ProxMenux, consider the following:</p>
      <ul className="list-disc pl-6 space-y-2 mb-4">
        <li>Backup any custom scripts or configurations you've created with ProxMenux</li>
        <li>Ensure you have direct access to your Proxmox VE system in case you need to troubleshoot</li>
        <li>
          Consider if you really need to uninstall, or if updating to a newer version might solve any issues you're
          experiencing
        </li>
      </ul>

      <h2 className="text-2xl font-semibold mt-8 mb-4">Steps to Uninstall ProxMenux</h2>
      <Steps>
        <Steps.Step title="Access ProxMenux Settings">
          <p>Open ProxMenux and navigate to the Settings menu.</p>
        </Steps.Step>
        <Steps.Step title="Select Uninstall Option">
          <p>Find and select the "Uninstall ProxMenux" option.</p>
        </Steps.Step>
        <Steps.Step title="Confirm Uninstallation">
          <p>
            ProxMenux will ask you to confirm the uninstallation. Type "YES" (in all caps) when prompted to proceed.
          </p>
        </Steps.Step>
        <Steps.Step title="Wait for Uninstallation">
          <p>
            The uninstallation process will begin. This may take a few minutes. Do not interrupt the process or shut
            down your system.
          </p>
        </Steps.Step>
        <Steps.Step title="Restart Proxmox VE">
          <p>
            Once the uninstallation is complete, you'll be prompted to restart your Proxmox VE system. It's important to
            do this to ensure all ProxMenux components are fully removed.
          </p>
        </Steps.Step>
      </Steps>

      <h2 className="text-2xl font-semibold mt-8 mb-4">Manual Uninstallation (If Needed)</h2>
      <p className="mb-4">
        If the built-in uninstaller doesn't work for any reason, you can try manually uninstalling ProxMenux:
      </p>
      <ol className="list-decimal pl-6 space-y-2">
        <li>Access your Proxmox VE system via SSH or the console</li>
        <li>Navigate to the ProxMenux installation directory (typically /opt/proxmenux)</li>
        <li>
          Run the manual uninstall script: <code className="bg-gray-200 p-1 rounded">sudo ./uninstall.sh</code>
        </li>
        <li>Follow any on-screen prompts to complete the uninstallation</li>
        <li>
          Remove any remaining ProxMenux files:{" "}
          <code className="bg-gray-200 p-1 rounded">sudo rm -rf /opt/proxmenux</code>
        </li>
        <li>Restart your Proxmox VE system</li>
      </ol>

      <h2 className="text-2xl font-semibold mt-8 mb-4">After Uninstallation</h2>
      <p className="mb-4">After uninstalling ProxMenux:</p>
      <ul className="list-disc pl-6 space-y-2">
        <li>Verify that the ProxMenux command is no longer recognized in the terminal</li>
        <li>Check that any ProxMenux-specific configurations have been removed from your system</li>
        <li>
          If you plan to reinstall ProxMenux later, make sure to download the latest version from the official source
        </li>
      </ul>

      <p className="mt-6 italic">
        If you're uninstalling due to issues with ProxMenux, consider reaching out to the community support forums or
        filing a bug report before uninstalling. The developers may be able to help resolve your issue without the need
        for uninstallation.
      </p>
    </div>
  )
}

