import type { Metadata } from "next"
import { Steps } from "@/components/ui/steps"

export const metadata: Metadata = {
  title: "Show IP Information | ProxMenux Documentation",
  description: "Learn how to display IP information for Proxmox VE and its virtual machines using ProxMenux.",
}

export default function ShowIPInformation() {
  return (
    <div className="max-w-3xl mx-auto">
      <h1 className="text-3xl font-bold mb-6">Show IP Information</h1>

      <p className="mb-4">
        The Show IP Information function is part of the network management script in ProxMenux. It provides a quick and
        easy way to view the IP configurations of all relevant network interfaces in your Proxmox VE system.
      </p>

      <h2 className="text-2xl font-semibold mt-8 mb-4">What Does Show IP Information Do?</h2>
      <p className="mb-4">When you select the Show IP Information option, the script performs the following actions:</p>
      <ol className="list-decimal pl-6 space-y-2 mb-6">
        <li>Detects all relevant network interfaces (physical and bridges)</li>
        <li>Retrieves the IP address for each detected interface</li>
        <li>Displays a comprehensive list of interfaces and their associated IP addresses</li>
        <li>Indicates if an interface has no IP assigned</li>
      </ol>

      <h2 className="text-2xl font-semibold mt-8 mb-4">How to Use Show IP Information</h2>
      <Steps>
        <Steps.Step title="Access the Network Repair Menu">
          <p>Run the network management script and select the "Network Repair Menu" option.</p>
        </Steps.Step>
        <Steps.Step title="Choose Show IP Information">
          <p>From the menu, select the "Show IP Information" option.</p>
        </Steps.Step>
        <Steps.Step title="Review the IP Information">
          <p>The script will display a list of all detected interfaces and their IP addresses.</p>
        </Steps.Step>
        <Steps.Step title="Interpret the Results">
          <p>Use this information to verify IP assignments or troubleshoot network issues.</p>
        </Steps.Step>
      </Steps>

      <h2 className="text-2xl font-semibold mt-8 mb-4">Key Features of Show IP Information</h2>
      <ul className="list-disc pl-6 space-y-2 mb-6">
        <li>Comprehensive detection of all relevant network interfaces</li>
        <li>Display of IP addresses for each detected interface</li>
        <li>Indication of interfaces without assigned IP addresses</li>
        <li>Quick and easy access to network configuration information</li>
        <li>Non-intrusive operation (does not make any changes to the system)</li>
      </ul>
    </div>
  )
}
