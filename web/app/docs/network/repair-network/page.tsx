import { Steps } from "@/components/ui/steps"
import CopyableCode from "@/components/CopyableCode"

export const metadata = {
  title: "Repair Network | ProxMenux Documentation",
  description: "Step-by-step guide to repair network configurations in Proxmox VE using ProxMenux.",
}

export default function RepairNetwork() {
  return (
    <div className="max-w-3xl mx-auto">
      <h1 className="text-3xl font-bold mb-6">Repair Network</h1>
      
      <p className="mb-4">
        The <strong>Repair Network</strong> function in <strong>ProxMenux</strong> automates the process of detecting and fixing network issues in
        <strong>Proxmox VE</strong>. It ensures stable connectivity by verifying network configurations, cleaning unused interfaces,
        and correcting bridge settings.
      </p>
      
      <h2 className="text-2xl font-semibold mt-8 mb-4">Overview</h2>
      <p className="mb-4">The script executes the following steps:</p>
      <ol className="list-decimal pl-6 space-y-2 mb-6">
        <li>Detects physical network interfaces.</li>
        <li>Cleans up non-existent or unused network interfaces.</li>
        <li>Checks and repairs bridge configurations.</li>
        <li>Configures detected physical interfaces.</li>
        <li>Provides an option to restart the network service.</li>
        <li>Verifies network connectivity and displays updated IP information.</li>
      </ol>
      
      <h2 className="text-2xl font-semibold mt-8 mb-4">Implementation Steps</h2>
      <Steps>
        <Steps.Step title="Detect Network Interfaces">
          <p>The script scans the system for available network interfaces and identifies the primary physical adapters.</p>
        </Steps.Step>
        <Steps.Step title="Clean Up Non-Existent Interfaces">
          <p>Removes outdated or missing interfaces from the configuration files to prevent conflicts.</p>
        </Steps.Step>
        <Steps.Step title="Check and Fix Bridges">
          <p>Verifies the bridge network settings and updates them if necessary to ensure correct operation.</p>
        </Steps.Step>
        <Steps.Step title="Configure Physical Interfaces">
          <p>Ensures that all detected physical interfaces are properly configured in the network settings.</p>
        </Steps.Step>
        <Steps.Step title="Restart Networking">
          <p>If necessary, the script prompts the user to restart the network service to apply changes.</p>
        </Steps.Step>
        <Steps.Step title="Verify Network Connectivity">
          <p>Performs a final connectivity check and displays updated network information.</p>
        </Steps.Step>
      </Steps>
      
      <h2 className="text-2xl font-semibold mt-8 mb-4">Expected Results</h2>
      <ul className="list-disc pl-6 space-y-2 mb-6">
        <li>Network interfaces are correctly detected and configured.</li>
        <li>Unused or missing network configurations are removed.</li>
        <li>Bridge settings are corrected if necessary.</li>
        <li>The system maintains a stable and functional network configuration.</li>
      </ul>
      
      <h2 className="text-2xl font-semibold mt-8 mb-4">Important Considerations</h2>
      <ul className="list-disc pl-6 space-y-2 mb-6">
        <li>Restarting the network service may cause temporary disconnection.</li>
        <li>Ensure an alternative access method (such as IPMI or console) in case of network misconfiguration.</li>
        <li>It is recommended to back up network configurations before running the script.</li>
      </ul>
      
    </div>
  )
}
