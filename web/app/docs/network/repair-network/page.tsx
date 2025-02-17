import type { Metadata } from "next"
import { Steps } from "@/components/ui/steps"

export const metadata: Metadata = {
  title: "Repair Network | ProxMenux Documentation",
  description: "Learn how to repair network configurations in Proxmox VE using ProxMenux.",
}

export default function RepairNetwork() {
  return (
    <div className="max-w-3xl mx-auto">
      <h1 className="text-3xl font-bold mb-6">Repair Network</h1>

      <p className="mb-4">
        The Repair Network function is part of the network management script in ProxMenux. It automatically detects and
        fixes common network issues in Proxmox VE systems, ensuring stable connectivity and proper configuration.
      </p>

      <h2 className="text-2xl font-semibold mt-8 mb-4">What Does Repair Network Do?</h2>
      <p className="mb-4">When you select the Repair Network option, the script performs the following actions:</p>
      <ol className="list-decimal pl-6 space-y-2 mb-6">
        <li>Detects physical network interfaces</li>
        <li>Cleans up non-existent interfaces from the configuration</li>
        <li>Checks and fixes bridge configurations</li>
        <li>Configures physical interfaces</li>
        <li>Offers to restart the networking service</li>
        <li>Verifies network connectivity</li>
        <li>Displays updated IP information</li>
      </ol>

      <h2 className="text-2xl font-semibold mt-8 mb-4">How to Use Repair Network</h2>
      <Steps>
        <Steps.Step title="Access the Network Repair Menu">
          <p>Run the network management script and select the "Network Repair Menu" option.</p>
        </Steps.Step>
        <Steps.Step title="Choose Repair Network">
          <p>From the menu, select the "Repair Network" option.</p>
        </Steps.Step>
        <Steps.Step title="Follow the Prompts">
          <p>The script will guide you through the repair process with clear prompts and information dialogs.</p>
        </Steps.Step>
        <Steps.Step title="Review Results">
          <p>After the repair process, review the results displayed in the dialog boxes.</p>
        </Steps.Step>
        <Steps.Step title="Restart Networking (if prompted)">
          <p>If prompted, decide whether to restart the networking service to apply changes.</p>
        </Steps.Step>
      </Steps>

      <h2 className="text-2xl font-semibold mt-8 mb-4">Key Features of Repair Network</h2>
      <ul className="list-disc pl-6 space-y-2 mb-6">
        <li>Automatic detection and repair of common network issues</li>
        <li>Bridge configuration verification and fixing</li>
        <li>Cleanup of non-existent interfaces</li>
        <li>Automatic configuration of physical interfaces</li>
        <li>Network connectivity check after repairs</li>
        <li>Option to restart networking services</li>
        <li>Display of updated IP information post-repair</li>
      </ul>

      <h2 className="text-2xl font-semibold mt-8 mb-4">Important Notes</h2>
      <ul className="list-disc pl-6 space-y-2 mb-6">
        <li>This function requires root or sudo privileges to execute.</li>
        <li>Restarting the network service may cause a brief disconnection.</li>
        <li>Always ensure you have an alternative way to access your Proxmox VE system in case of network issues.</li>
        <li>It's recommended to create a backup of your network configuration before making changes.</li>
        <li>If you're unsure about any step, use the "Verify Network" option first to check the current status.</li>
      </ul>

      <p className="mt-6 italic">
        The Repair Network function simplifies the process of troubleshooting and fixing network issues in Proxmox VE.
        It provides an automated approach to common network maintenance tasks, helping to ensure your Proxmox system
        maintains stable connectivity.
      </p>
    </div>
  )
}

