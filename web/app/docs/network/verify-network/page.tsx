import { Steps } from "@/components/ui/steps"
import CopyableCode from "@/components/CopyableCode"

export const metadata = {
  title: "Verify Network | ProxMenux Documentation",
  description: "Step-by-step guide to verify network configuration and connectivity in Proxmox VE using ProxMenux.",
}

export default function VerifyNetwork() {
  return (
    <div className="max-w-3xl mx-auto">
      <h1 className="text-3xl font-bold mb-6">Verify Network</h1>
      
      <p className="mb-4">
        The <strong>Verify Network</strong> function in ProxMenux allows users to check the current network
        configuration and connectivity in <strong>Proxmox VE</strong>. It provides a quick way to identify potential
        network issues and verify that all network interfaces are correctly configured.
      </p>
      
      <h2 className="text-2xl font-semibold mt-8 mb-4">Overview</h2>
      <p className="mb-4">When executed, the script performs the following actions:</p>
      <ol className="list-decimal pl-6 space-y-2 mb-6">
        <li>Detects and lists all physical network interfaces.</li>
        <li>Retrieves the current IP configuration for each detected interface.</li>
        <li>Verifies network connectivity by testing external server reachability.</li>
        <li>Displays a summary of the network status.</li>
      </ol>
      
      
      <h2 className="text-2xl font-semibold mt-8 mb-4">Expected Results</h2>
      <ul className="list-disc pl-6 space-y-2 mb-6">
        <li>All active network interfaces are detected and displayed.</li>
        <li>Current IP configurations are listed for reference.</li>
        <li>Connectivity to an external server is confirmed or flagged if there is an issue.</li>
      </ul>
      
    </div>
  )
}
