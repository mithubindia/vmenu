import type { Metadata } from "next"
import { Steps } from "@/components/ui/steps"

export const metadata: Metadata = {
  title: "Import Disk Image to a VM | ProxMenux Documentation",
  description: "Learn how to import a disk image to a virtual machine in Proxmox VE.",
}

export default function ImportDiskImageVM() {
  return (
    <div className="max-w-3xl mx-auto">
      <h1 className="text-3xl font-bold mb-6">Import Disk Image to a VM</h1>

      <p className="mb-4">
        This script automates the process of importing disk images into Proxmox VE virtual machines (VMs). It simplifies
        the task of attaching pre-existing disk files to VMs without requiring manual configuration.
      </p>

      <h2 className="text-2xl font-semibold mt-8 mb-4">What Does This Script Do?</h2>
      <p className="mb-4">When executed, this script performs the following actions:</p>
      <ol className="list-decimal pl-6 space-y-2 mb-6">
        <li>Scans for compatible disk images (.img, .qcow2, .vmdk) in the /var/lib/vz/template/images/ directory</li>
        <li>Presents a list of available VMs for selection</li>
        <li>Allows you to choose one or multiple disk images for import</li>
        <li>Lets you select a storage volume in Proxmox for disk placement</li>
        <li>Offers options for interface type (SATA, SCSI, VirtIO, IDE) for each imported disk</li>
        <li>Provides optional settings like SSD emulation and bootable disk configuration</li>
        <li>Imports the selected disk images and attaches them to the chosen VM</li>
      </ol>

      <h2 className="text-2xl font-semibold mt-8 mb-4">Key Steps</h2>
      <Steps>
        <Steps.Step title="Preparation">
          <p>
            Ensure that the disk images you want to import are placed in the /var/lib/vz/template/images/ directory.
          </p>
        </Steps.Step>
        <Steps.Step title="VM Selection">
          <p>Choose the VM where you want to import the disk image(s) from a list of available VMs.</p>
        </Steps.Step>
        <Steps.Step title="Storage Selection">
          <p>Select the Proxmox storage volume where the imported disk(s) will be placed.</p>
        </Steps.Step>
        <Steps.Step title="Image Selection">
          <p>
            Choose one or more disk images to import from the list of compatible images found in the specified
            directory.
          </p>
        </Steps.Step>
        <Steps.Step title="Configuration">
          <p>For each selected image:</p>
          <ul className="list-disc pl-6 space-y-1 mt-2">
            <li>Choose the interface type (SATA, SCSI, VirtIO, or IDE)</li>
            <li>Optionally enable SSD emulation (for non-VirtIO interfaces)</li>
            <li>Decide whether to make the disk bootable</li>
          </ul>
        </Steps.Step>
        <Steps.Step title="Import Process">
          <p>The script will import each selected disk image, showing real-time progress updates.</p>
        </Steps.Step>
        <Steps.Step title="Finalization">
          <p>After import, the script configures the disks in the VM and applies the chosen settings.</p>
        </Steps.Step>
      </Steps>

      <h2 className="text-2xl font-semibold mt-8 mb-4">What to Expect</h2>
      <ul className="list-disc pl-6 space-y-2 mb-6">
        <li>The script will guide you through the process with clear prompts and menus.</li>
        <li>You'll need to make selections for the target VM, storage, disk images, and configuration options.</li>
        <li>The import process may take some time, depending on the size and number of disk images.</li>
        <li>Real-time progress updates will be displayed during the import process.</li>
        <li>After completion, the imported disks will be available and configured in the selected VM.</li>
      </ul>

      <h2 className="text-2xl font-semibold mt-8 mb-4">Important Notes</h2>
      <ul className="list-disc pl-6 space-y-2 mb-6">
        <li>Ensure you have sufficient storage space in the selected Proxmox storage volume before importing.</li>
        <li>The script supports .img, .qcow2, and .vmdk disk image formats.</li>
        <li>Make sure the VM is powered off before importing disk images to avoid potential conflicts.</li>
        <li>
          Importing a disk as bootable will modify the VM's boot order. Adjust the boot order in the VM settings if
          necessary.
        </li>
        <li>SSD emulation is only available for non-VirtIO interfaces (SATA, SCSI, IDE).</li>
        <li>This script requires root or sudo privileges to execute.</li>
      </ul>

      <p className="mt-6 italic">
        This script simplifies the process of importing disk images to VMs in Proxmox VE, making it easy to add
        pre-existing disks or migrate disks from other environments. It handles the technical details of import and
        configuration, allowing you to quickly add new storage to your VMs.
      </p>
    </div>
  )
}

