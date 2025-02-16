import type { Metadata } from "next"
import { Steps } from "@/components/ui/steps"

export const metadata: Metadata = {
  title: "Install Coral TPU on the Host | ProxMenux Documentation",
  description: "Learn how to install Coral TPU drivers on your Proxmox VE host.",
}

export default function InstallCoralTPUHost() {
  return (
    <div className="max-w-3xl mx-auto">
      <h1 className="text-3xl font-bold mb-6">Install Coral TPU on the Host</h1>

      <p className="mb-4">
        This script automates the installation of Google Coral TPU (Tensor Processing Unit) drivers on your Proxmox VE
        host. It ensures that all necessary packages are installed and compiles the Coral TPU drivers for proper
        functionality.
      </p>

      <h2 className="text-2xl font-semibold mt-8 mb-4">What Does This Script Do?</h2>
      <p className="mb-4">When executed, this script performs the following actions:</p>
      <ol className="list-decimal pl-6 space-y-2 mb-6">
        <li>Prompts for confirmation before proceeding with the installation</li>
        <li>Verifies and configures necessary repositories on the host</li>
        <li>Installs required packages for driver compilation</li>
        <li>Clones the Coral TPU driver repository</li>
        <li>Builds and installs the Coral TPU drivers</li>
        <li>Prompts for a system restart to apply changes</li>
      </ol>

      <h2 className="text-2xl font-semibold mt-8 mb-4">Key Steps</h2>
      <Steps>
        <Steps.Step title="Pre-Installation Prompt">
          <p>The script asks for confirmation before proceeding, warning that a system restart will be required.</p>
        </Steps.Step>
        <Steps.Step title="Repository Configuration">
          <p>Verifies and adds necessary repositories:</p>
          <ul className="list-disc pl-6 space-y-1 mt-2">
            <li>Adds the pve-no-subscription repository if not present</li>
            <li>Adds non-free-firmware repositories to the sources list</li>
            <li>Updates the package lists</li>
          </ul>
        </Steps.Step>
        <Steps.Step title="Driver Installation">
          <p>Installs Coral TPU drivers:</p>
          <ul className="list-disc pl-6 space-y-1 mt-2">
            <li>Installs necessary packages (git, devscripts, dh-dkms, etc.)</li>
            <li>Clones the gasket-driver repository</li>
            <li>Builds the driver packages</li>
            <li>Installs the compiled driver packages</li>
          </ul>
        </Steps.Step>
        <Steps.Step title="Post-Installation Prompt">
          <p>Prompts the user to restart the server to apply the changes.</p>
        </Steps.Step>
      </Steps>

      <h2 className="text-2xl font-semibold mt-8 mb-4">What to Expect</h2>
      <ul className="list-disc pl-6 space-y-2 mb-6">
        <li>The script will guide you through the process with clear prompts.</li>
        <li>Installation may take several minutes, depending on your system's performance.</li>
        <li>A system restart is required after the installation to apply the changes.</li>
        <li>After the restart, your Proxmox VE host will be ready to use Coral TPU devices.</li>
      </ul>

      <h2 className="text-2xl font-semibold mt-8 mb-4">Important Notes</h2>
      <ul className="list-disc pl-6 space-y-2 mb-6">
        <li>Ensure you have a stable internet connection for downloading packages and repositories.</li>
        <li>
          This script modifies system repositories and installs new packages. Make sure you understand the implications.
        </li>
        <li>The installation requires root or sudo privileges to execute.</li>
        <li>It's recommended to perform a system backup before running this script.</li>
        <li>If you encounter any issues during installation, check the Proxmox VE logs for more information.</li>
      </ul>

      <p className="mt-6 italic">
        This script simplifies the process of installing Coral TPU drivers on your Proxmox VE host, enabling you to use
        Coral TPU devices for AI and machine learning tasks. After installation and restart, you can proceed to
        configure individual LXC containers or VMs to use the Coral TPU.
      </p>
    </div>
  )
}

