import { Steps } from "@/components/ui/steps"
import CopyableCode from "@/components/CopyableCode"
import Image from "next/image"

export const metadata = {
  title: "Enable Coral TPU in LXC | ProxMenux Documentation",
  description: "Step-by-step guide to enable Google Coral TPU support in an LXC container using ProxMenux.",
}

export default function CoralTPULXC() {
  return (
    <div className="max-w-3xl mx-auto">
      <h1 className="text-3xl font-bold mb-6">Enable Coral TPU in an LXC</h1>
      
      <p className="mb-4">
        This guide explains how to configure Google Coral TPU support for LXC containers in Proxmox VE using <strong>ProxMenux</strong>.
        Coral TPU provides dedicated AI acceleration, improving inference performance for machine learning applications.
      </p>
      
      <h2 className="text-2xl font-semibold mt-8 mb-4">Overview</h2>
      <p className="mb-4">The script automates the following steps:</p>
      <ol className="list-decimal pl-6 space-y-2 mb-6">
        <li>Allows selection of an existing LXC container.</li>
        <li>Ensures the container is privileged for hardware access.</li>
        <li>Configures LXC parameters for Coral TPU and Intel iGPU.</li>
        <li>Installs required drivers and dependencies inside the container.</li>
      </ol>
      
      <h2 className="text-2xl font-semibold mt-8 mb-4">Implementation Steps</h2>
      <Steps>
        <Steps.Step title="Select an LXC Container">
          <p>The script lists available LXC containers and prompts for selection.</p>
        </Steps.Step>
        <Steps.Step title="Modify Container Configuration">
          <p>The script applies necessary changes to enable Coral TPU:</p>
          <ul className="list-disc pl-6 space-y-1 mt-2">
            <li>Switches the container to privileged mode if required.</li>
            <li>Enables nesting to allow GPU and TPU usage.</li>
            <li>Sets device permissions for TPU and iGPU.</li>
            <li>Configures proper device mounts.</li>
          </ul>
        </Steps.Step>
        <Steps.Step title="Install Required Drivers">
          <p>The script installs the necessary components inside the container:</p>
          <ul className="list-disc pl-6 space-y-1 mt-2">
            <li>GPU drivers (va-driver-all, intel-opencl-icd).</li>
            <li>Coral TPU dependencies (Python, GPG keys, repository setup).</li>
            <li>Coral TPU drivers (USB and M.2 support).</li>
          </ul>
        </Steps.Step>
        <Steps.Step title="Select Coral TPU Driver Version">
          <p>If a Coral M.2 device is detected, the script prompts the user to select:</p>
          <ul className="list-disc pl-6 space-y-1 mt-2">
            <li><strong>Standard mode</strong> - balanced performance.</li>
            <li><strong>Maximum performance mode</strong> - higher speed, increased power usage.</li>
          </ul>
        </Steps.Step>
      </Steps>
      
      <h2 className="text-2xl font-semibold mt-8 mb-4">Expected Results</h2>
      <ul className="list-disc pl-6 space-y-2 mb-6">
        <li>The selected container is correctly configured for TPU and iGPU usage.</li>
        <li>Required drivers and dependencies are installed inside the container.</li>
        <li>The container will restart as needed during the process.</li>
        <li>After completion, applications inside the container can utilize Coral TPU acceleration.</li>
      </ul>
      
      <h2 className="text-2xl font-semibold mt-8 mb-4">Important Considerations</h2>
      <ul className="list-disc pl-6 space-y-2 mb-6">
        <li>The script supports both USB and M.2 Coral TPU devices.</li>
        <li>The container must be privileged to access TPU hardware.</li>
        <li>The Proxmox host must have the required Coral TPU and Intel GPU drivers installed.</li>
        <li>Additional application-specific configurations may be required inside the container.</li>
      </ul>
      
      <p className="mt-6 italic">
        By using ProxMenux, Coral TPU and iGPU support can be enabled in LXC containers efficiently, avoiding manual configuration steps.
      </p>
    </div>
  )
}
