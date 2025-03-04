import { Steps } from "@/components/ui/steps"
import CopyableCode from "@/components/CopyableCode"

export const metadata = {
  title: "Install Coral TPU on the Host | ProxMenux Documentation",
  description: "Step-by-step guide to install Google Coral TPU drivers on a Proxmox VE host using ProxMenux.",
}

export default function InstallCoralTPUHost() {
  return (
    <div className="max-w-3xl mx-auto">
      <h1 className="text-3xl font-bold mb-6">Install Coral TPU on the Host</h1>
      
      <p className="mb-4"><strong>Before using Coral TPU inside an LXC container, the drivers must first be installed on the Proxmox VE host. This script automates that process, ensuring the necessary setup is completed.</strong><br/><br/>
        This guide explains how to install and configure Google Coral TPU drivers on a Proxmox VE host using <strong>ProxMenux</strong>.
        This setup enables hardware acceleration for AI-based applications that leverage Coral TPU.
      </p>
      
      <h2 className="text-2xl font-semibold mt-8 mb-4">Overview</h2>
      <p className="mb-4">The script automates the following steps:</p>
      <ol className="list-decimal pl-6 space-y-2 mb-6">
        <li>Prompts for confirmation before proceeding with installation.</li>
        <li>Verifies and configures necessary repositories on the host.</li>
        <li>Installs required dependencies for driver compilation.</li>
        <li>Clones the Coral TPU driver repository and builds the drivers.</li>
        <li>Installs the compiled Coral TPU drivers.</li>
        <li>Prompts for a system restart to apply changes.</li>
      </ol>
      
      <h2 className="text-2xl font-semibold mt-8 mb-4">Implementation Steps</h2>
      <Steps>
        <Steps.Step title="Pre-Installation Confirmation">
          <p>The script prompts the user for confirmation before proceeding, as a system restart is required after installation.</p>
        </Steps.Step>
        <Steps.Step title="Repository Configuration">
          <p>The script verifies and configures required repositories:</p>
          <ul className="list-disc pl-6 space-y-1 mt-2">
            <li>Adds the <strong>pve-no-subscription</strong> repository if not present.</li>
            <li>Adds <strong>non-free-firmware</strong> repositories for required packages.</li>
            <li>Runs an update to fetch the latest package lists.</li>
          </ul>
        </Steps.Step>
        <Steps.Step title="Driver Installation">
          <p>The script installs and compiles the required drivers:</p>
          <ul className="list-disc pl-6 space-y-1 mt-2">
            <li>Installs dependencies such as <strong>git, dkms, devscripts</strong>, and kernel headers.</li>
            <li>Clones the <strong>gasket-driver</strong> repository from Google.</li>
            <li>Builds the Coral TPU driver packages.</li>
            <li>Installs the compiled drivers on the host.</li>
          </ul>
        </Steps.Step>
        <Steps.Step title="Post-Installation Confirmation">
          <p>The script prompts the user to restart the server to apply the changes.</p>
        </Steps.Step>
      </Steps>
      
      <h2 className="text-2xl font-semibold mt-8 mb-4">Expected Results</h2>
      <ul className="list-disc pl-6 space-y-2 mb-6">
        <li>The Coral TPU drivers are installed successfully on the Proxmox VE host.</li>
        <li>Required repositories and dependencies are configured properly.</li>
        <li>A system restart is performed to complete the installation.</li>
      </ul>
      

    </div>
  )
}
