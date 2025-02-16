import type { Metadata } from "next"
import { Steps } from "@/components/ui/steps"

export const metadata: Metadata = {
  title: "Disk Passthrough to a VM | ProxMenux Documentation",
  description: "Learn how to set up disk passthrough to a virtual machine in Proxmox VE.",
}

export default function DiskPassthroughVM() {
  return (
    <div className="max-w-3xl mx-auto">
      <h1 className="text-3xl font-bold mb-6">Disk Passthrough to a VM</h1>

      <p className="mb-4">
        This script automates the process of setting up disk passthrough to a virtual machine (VM) in Proxmox VE. Disk
        passthrough allows a VM to have direct access to a physical disk or partition, which can be useful for certain
        applications that require low-level disk access or for maximizing storage performance.
      </p>

      <h2 className="text-2xl font-semibold mt-8 mb-4">What Does This Script Do?</h2>
      <p className="mb-4">When executed, this script performs the following actions:</p>
      <ol className="list-decimal pl-6 space-y-2 mb-6">
        <li>Lists available disks on the Proxmox host</li>
        <li>Allows you to select a disk for passthrough</li>
        <li>Lists available VMs</li>
        <li>Allows you to select a VM to receive the disk passthrough</li>
        <li>Configures the selected disk for passthrough</li>
        <li>Adds the disk to the chosen VM's configuration</li>
      </ol>

      <h2 className="text-2xl font-semibold mt-8 mb-4">Key Steps</h2>
      <Steps>
        <Steps.Step title="Disk Selection">
          <p>
            The script will display a list of available disks on your Proxmox host. You'll be prompted to select the
            disk you want to pass through to a VM.
          </p>
        </Steps.Step>
        <Steps.Step title="VM Selection">
          <p>
            After selecting a disk, you'll be presented with a list of available VMs. Choose the VM that should receive
            the passed-through disk.
          </p>
        </Steps.Step>
        <Steps.Step title="Disk Configuration">
          <p>The script will configure the selected disk for passthrough. This involves:</p>
          <ul className="list-disc pl-6 space-y-1 mt-2">
            <li>Unmounting the disk if it's currently mounted</li>
            <li>Removing any existing partitions or logical volumes</li>
            <li>Clearing the partition table</li>
          </ul>
        </Steps.Step>
        <Steps.Step title="VM Configuration">
          <p>The script will modify the chosen VM's configuration to include the passed-through disk. This includes:</p>
          <ul className="list-disc pl-6 space-y-1 mt-2">
            <li>Adding the disk to the VM's configuration file</li>
            <li>Setting up the appropriate SCSI controller if necessary</li>
          </ul>
        </Steps.Step>
      </Steps>

      <h2 className="text-2xl font-semibold mt-8 mb-4">What to Expect</h2>
      <ul className="list-disc pl-6 space-y-2 mb-6">
        <li>The script will guide you through the process with clear prompts.</li>
        <li>You'll need to make selections for both the disk and the target VM.</li>
        <li>The process is typically quick, but it may take a few moments to configure larger disks.</li>
        <li>After completion, the selected disk will be available to the chosen VM as a raw device.</li>
        <li>You may need to restart the VM to recognize the new disk.</li>
      </ul>

      <h2 className="text-2xl font-semibold mt-8 mb-4">Important Notes</h2>
      <ul className="list-disc pl-6 space-y-2 mb-6">
        <li>Disk passthrough gives the VM direct access to the physical disk. Use this feature with caution.</li>
        <li>
          All data on the selected disk will be erased during the process. Make sure to backup any important data before
          proceeding.
        </li>
        <li>
          The disk will be exclusively used by the selected VM and will not be available to the host or other VMs.
        </li>
        <li>Ensure that the VM is shut down before running this script to avoid potential data corruption.</li>
        <li>Some features like live migration may be limited or unavailable for VMs with passed-through disks.</li>
        <li>This script requires root or sudo privileges to execute.</li>
      </ul>

      <p className="mt-6 italic">
        This script simplifies the process of setting up disk passthrough in Proxmox VE, allowing you to easily assign
        physical disks to specific VMs. This can be particularly useful for applications that require direct disk access
        or for maximizing storage performance in certain scenarios.
      </p>
    </div>
  )
}

