import type { Metadata } from "next"
import { Steps } from "@/components/ui/steps"

export const metadata: Metadata = {
  title: "Repair Network | ProxMenux Documentation",
  description: "Learn how to repair and verify network configurations in Proxmox VE using ProxMenux.",
}

export default function RepairNetwork() {
  return (
    <div className="max-w-3xl mx-auto">
      <h1 className="text-3xl font-bold mb-6">Repair Network</h1>

      <p className="mb-4">
        This script provides comprehensive network repair and verification functionality for Proxmox VE systems. It
        helps users troubleshoot and fix common network issues, ensuring stable connectivity and proper configuration.
      </p>

      <h2 className="text-2xl font-semibold mt-8 mb-4">What Does This Script Do?</h2>
      <p className="mb-4">When executed, this script offers the following main functions:</p>
      <ol className="list-decimal pl-6 space-y-2 mb-6">
        <li>Repair Network: Automatically detects and fixes common network issues</li>
        <li>Verify Network: Checks the current network configuration and connectivity</li>
        <li>Show IP Information: Displays IP addresses for all relevant network interfaces</li>
      </ol>

      <h2 className="text-2xl font-semibold mt-8 mb-4">Key Features</h2>
      <ul className="list-disc pl-6 space-y-2 mb-6">
        <li>Detects and lists physical and network interfaces</li>
        <li>Verifies and repairs bridge configurations</li>
        <li>Cleans up non-existent interfaces from the configuration</li>
        <li>Configures physical interfaces automatically</li>
        <li>Checks network connectivity</li>
        <li>Provides options to restart networking services</li>
        <li>Offers an interactive menu for easy navigation</li>
      </ul>

      <h2 className="text-2xl font-semibold mt-8 mb-4">How to Use</h2>
      <Steps>
        <Steps.Step title="Access the Network Repair Menu">
          <p>Run the script and select the "Network Repair Menu" option from the main ProxMenux interface.</p>
        </Steps.Step>
        <Steps.Step title="Choose an Option">
          <p>Select one of the following options:</p>
          <ul className="list-disc pl-6 space-y-1 mt-2">
            <li>Repair Network</li>
            <li>Verify Network</li>
            <li>Show IP Information</li>
          </ul>
        </Steps.Step>
        <Steps.Step title="Follow the Prompts">
          <p>The script will guide you through the process with clear prompts and information dialogs.</p>
        </Steps.Step>
        <Steps.Step title="Review Results">
          <p>After each operation, review the results displayed in the dialog boxes.</p>
        </Steps.Step>
        <Steps.Step title="Repeat or Exit">
          <p>Choose another option or return to the main menu when finished.</p>
        </Steps.Step>
      </Steps>

      <h2 className="text-2xl font-semibold mt-8 mb-4">Repair Network Process</h2>
      <p className="mb-4">When you select "Repair Network", the script performs the following actions:</p>
      <ol className="list-decimal pl-6 space-y-2 mb-6">
        <li>Detects physical network interfaces</li>
        <li>Cleans up non-existent interfaces from the configuration</li>
        <li>Checks and fixes bridge configurations</li>
        <li>Configures physical interfaces</li>
        <li>Offers to restart the networking service</li>
        <li>Verifies network connectivity</li>
        <li>Displays updated IP information</li>
      </ol>

      <h2 className="text-2xl font-semibold mt-8 mb-4">Important Notes</h2>
      <ul className="list-disc pl-6 space-y-2 mb-6">
        <li>This script requires root or sudo privileges to execute.</li>
        <li>Restarting the network service may cause a brief disconnection.</li>
        <li>Always ensure you have an alternative way to access your Proxmox VE system in case of network issues.</li>
        <li>It's recommended to create a backup of your network configuration before making changes.</li>
        <li>If you're unsure about any step, use the "Verify Network" option first to check the current status.</li>
      </ul>

      <p className="mt-6 italic">
        This script simplifies the process of troubleshooting and repairing network issues in Proxmox VE. It provides an
        easy-to-use interface for common network maintenance tasks, helping to ensure your Proxmox system maintains
        stable connectivity.
      </p>
    </div>
  )
}

