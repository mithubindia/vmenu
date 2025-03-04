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
        The <strong>Repair Network</strong> function in <strong>ProxMenux</strong> addresses issues caused by changes in network interface identifiers
        that occur when modifying hardware components such as network adapters or GPUs. This can lead to a loss of
        network connectivity because the system retains old configurations that no longer match the new interface IDs.
      </p>
      
      <h2 className="text-2xl font-semibold mt-8 mb-4">Purpose</h2>
      <p className="mb-4">
        In many cases, when adding or removing hardware (e.g., network cards, GPUs), network interfaces may be renamed
        due to changes in the system's PCI device enumeration. As a result, Proxmox VE may fail to establish a network
        connection because the <code>/etc/network/interfaces</code> file references outdated interface names.
      </p>
      <p className="mb-4">
        Restoring a backup of <code>/etc/network/interfaces</code> is not a viable solution, as the IDs of the interfaces have changed. Instead,
        the system needs to detect the new identifiers and update the configuration accordingly. <strong>Repair Network</strong>
        automates this process by identifying the correct interface names and applying the necessary corrections.
      </p>
      
      <h2 className="text-2xl font-semibold mt-8 mb-4">How It Works</h2>
      <ul className="list-disc pl-6 space-y-2 mb-6">
        <li>Detects the current physical network interfaces and their updated identifiers.</li>
        <li>Checks the <code>/etc/network/interfaces</code> file for outdated interface names.</li>
        <li>Replaces incorrect or missing network interface names with the correct ones.</li>
        <li>Verifies the integrity of bridge configurations and updates them if necessary.</li>
        <li>Provides an option to restart the network service to apply changes.</li>
      </ul>
      
      <h2 className="text-2xl font-semibold mt-8 mb-4">Expected Results</h2>
      <ul className="list-disc pl-6 space-y-2 mb-6">
        <li>Network connectivity is restored automatically without manual intervention.</li>
        <li>Updated interface names are correctly assigned in <code>/etc/network/interfaces</code>.</li>
        <li>Bridges and other network settings remain functional after hardware changes.</li>
      </ul>
      
      <h2 className="text-2xl font-semibold mt-8 mb-4">Important Considerations</h2>
      <ul className="list-disc pl-6 space-y-2 mb-6">
        <li>Restarting the network service is recommended to apply the changes.</li>
        <li>This script is useful when network connectivity is lost due to hardware modifications.</li>
        <li>Having an alternative access method (such as IPMI or console) is advisable in case of unforeseen issues.</li>
      </ul>
      
    </div>
  )
}
