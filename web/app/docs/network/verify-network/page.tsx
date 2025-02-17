import type { Metadata } from "next"
import { Steps } from "@/components/ui/steps"

export const metadata: Metadata = {
  title: "Verify Network | ProxMenux Documentation",
  description: "Learn how to verify network configuration and connectivity in Proxmox VE using ProxMenux.",
}

export default function VerifyNetwork() {
  return (
    <div className="max-w-3xl mx-auto">
      <h1 className="text-3xl font-bold mb-6">Verify Network</h1>

      <p className="mb-4">
        The Verify Network function is part of the network management script in ProxMenux. It checks the current network
        configuration and connectivity in Proxmox VE systems, providing a comprehensive overview of the network status.
      </p>

      <h2 className="text-2xl font-semibold mt-8 mb-4">What Does Verify Network Do?</h2>
      <p className="mb-4">When you select the Verify Network option, the script performs the following actions:</p>
      <ol className="list-decimal pl-6 space-y-2 mb-6">
        <li>Detects and lists physical network interfaces</li>
        <li>Checks the current IP configuration for all relevant interfaces</li>
        <li>Verifies network connectivity by pinging an external server</li>
        <li>Displays a summary of the network status</li>
      </ol>

      <h2 className="text-2xl font-semibold mt-8 mb-4">How to Use Verify Network</h2>
      <Steps>
        <Steps.Step title="Access the Network Repair Menu">
          <p>Run the network management script and select the "Network Repair Menu" option.</p>
        </Steps.Step>
        <Steps.Step title="Choose Verify Network">
          <p>From the menu, select the "Verify Network" option.</p>
        </Steps.Step>
        <Steps.Step title="Review the Results">
          <p>
            The script will display information about detected interfaces, IP configurations, and connectivity status.
          </p>
        </Steps.Step>
        <Steps.Step title="Interpret the Findings">
          <p>
            Based on the results, determine if any further action is needed (e.g., running the Repair Network function).
          </p>
        </Steps.Step>
      </Steps>

      <h2 className="text-2xl font-semibold mt-8 mb-4">Key Features of Verify Network</h2>
      <ul className="list-disc pl-6 space-y-2 mb-6">
        <li>Detection and listing of physical network interfaces</li>
        <li>Display of current IP configurations for all relevant interfaces</li>
        <li>Network connectivity check to an external server</li>
        <li>Comprehensive summary of the network status</li>
        <li>Non-intrusive operation (does not make any changes to the system)</li>
      </ul>

      <h2 className="text-2xl font-semibold mt-8 mb-4">Important Notes</h2>
      <ul className="list-disc pl-6 space-y-2 mb-6">
        <li>
          This function requires root or sudo privileges to execute, as it needs to access system network information.
        </li>
        <li>Verify Network does not make any changes to your system; it only reports the current status.</li>
        <li>If issues are detected, consider using the "Repair Network" function to address them.</li>
        <li>Regular network verification can help prevent connectivity issues before they become critical.</li>
      </ul>

      <p className="mt-6 italic">
        The Verify Network function provides a quick and easy way to check the status of your Proxmox VE system's
        network configuration and connectivity. Use it regularly as part of your system maintenance routine or whenever
        you suspect network issues.
      </p>
    </div>
  )
}

