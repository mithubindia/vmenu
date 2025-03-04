import { Steps } from "@/components/ui/steps"
import CopyableCode from "@/components/CopyableCode"

export const metadata = {
  title: "Import Disk Image to a VM | ProxMenux Documentation",
  description: "Step-by-step guide to import a disk image into a virtual machine in Proxmox VE using ProxMenux.",
}

export default function ImportDiskImageVM() {
  return (
    <div className="max-w-3xl mx-auto">
      <h1 className="text-3xl font-bold mb-6">Import Disk Image to a VM</h1>
      
      <p className="mb-4">
        This guide explains how to import a disk image into a virtual machine (VM) in <strong>Proxmox VE</strong> using <strong>ProxMenux</strong>.
        The script simplifies the process by scanning for available disk images and allowing users to attach them to VMs without manual configuration.
      </p>
      
      <h2 className="text-2xl font-semibold mt-8 mb-4">Overview</h2>
      <p className="mb-4">The script automates the following steps:</p>
      <ol className="list-decimal pl-6 space-y-2 mb-6">
        <li>Scans for disk images (.img, .qcow2, .vmdk) in <code>/var/lib/vz/template/images/</code>.</li>
        <li>Displays a list of available virtual machines (VMs) for selection.</li>
        <li>Allows users to choose one or multiple disk images for import.</li>
        <li>Provides storage volume options for placing the imported disk.</li>
        <li>Offers an interface choice (SATA, SCSI, VirtIO, or IDE) for each imported disk.</li>
        <li>Imports and attaches the selected disk images to the chosen VM.</li>
      </ol>
      
      <h2 className="text-2xl font-semibold mt-8 mb-4">Implementation Steps</h2>
      <Steps>
        <Steps.Step title="Preparation">
          <p>Ensure that the disk images you want to import are placed in <code>/var/lib/vz/template/images/</code>.</p>
        </Steps.Step>
        <Steps.Step title="VM Selection">
          <p>Select the VM where the disk image(s) will be imported.</p>
        </Steps.Step>
        <Steps.Step title="Storage Selection">
          <p>Choose the Proxmox storage volume where the imported disk(s) will be placed.</p>
        </Steps.Step>
        <Steps.Step title="Image Selection">
          <p>Select one or more disk images to import from the list of detected compatible images.</p>
        </Steps.Step>
        <Steps.Step title="Configuration">
          <p>For each selected image:</p>
          <ul className="list-disc pl-6 space-y-1 mt-2">
            <li>Choose the interface type (SATA, SCSI, VirtIO, or IDE).</li>
            <li>Optionally enable SSD emulation (for non-VirtIO interfaces).</li>
            <li>Decide whether to make the disk bootable.</li>
          </ul>
        </Steps.Step>
        <Steps.Step title="Import Process">
          <p>The script will import each selected disk image and display real-time progress updates.</p>
        </Steps.Step>
        <Steps.Step title="Finalization">
          <p>After the import is complete, the script attaches the disks to the VM and applies the selected settings.</p>
        </Steps.Step>
      </Steps>
      
      <h2 className="text-2xl font-semibold mt-8 mb-4">Expected Results</h2>
      <ul className="list-disc pl-6 space-y-2 mb-6">
        <li>The selected disk images are successfully imported and attached to the specified VM.</li>
        <li>Users receive confirmation of the import operation.</li>
        <li>The VM is configured to recognize the new disks upon startup.</li>
      </ul>
      
      <h2 className="text-2xl font-semibold mt-8 mb-4">Important Considerations</h2>
      <ul className="list-disc pl-6 space-y-2 mb-6">
        <li>Ensure you have sufficient storage space in the selected Proxmox storage volume.</li>
        <li>Supported disk image formats include <code>.img</code>, <code>.qcow2</code>, and <code>.vmdk</code>.</li>
        <li>The target VM must be powered off before importing disk images.</li>
        <li>SSD emulation is only available for non-VirtIO interfaces (SATA, SCSI, IDE).</li>
        <li>Importing a disk as bootable will modify the VM’s boot order. Adjust boot settings as needed.</li>
      </ul>
      

    </div>
  )
}
