import type { Metadata } from "next"
import { Steps } from "@/components/ui/steps"

export const metadata: Metadata = {
  title: "Coral TPU to an LXC | ProxMenux Documentation",
  description: "Learn how to add Coral TPU support to an LXC container in Proxmox VE.",
}

export default function CoralTPULXC() {
  return (
    <div className="max-w-3xl mx-auto">
      <h1 className="text-3xl font-bold mb-6">Coral TPU to an LXC</h1>

      <p className="mb-4">
        This script automates the process of adding Google Coral TPU (Tensor Processing Unit) support to LXC containers
        in Proxmox VE. It configures containers to leverage the power of Coral TPU for AI and machine learning tasks,
        significantly accelerating inference operations.
      </p>

      <h2 className="text-2xl font-semibold mt-8 mb-4">What Does This Script Do?</h2>
      <p className="mb-4">When executed, this script performs the following actions:</p>
      <ol className="list-decimal pl-6 space-y-2 mb-6">
        <li>Presents a list of available LXC containers for selection</li>
        <li>Configures the selected container to support both Coral TPU and Intel iGPU</li>
        <li>Installs necessary drivers and tools inside the container</li>
        <li>Sets up proper permissions and mounts for hardware access</li>
      </ol>

      <h2 className="text-2xl font-semibold mt-8 mb-4">Key Steps</h2>
      <Steps>
        <Steps.Step title="Container Selection">
          <p>You'll be prompted to select the LXC container you want to enable Coral TPU support for.</p>
        </Steps.Step>
        <Steps.Step title="Container Configuration">
          <p>The script modifies the container's configuration to allow Coral TPU and iGPU access. This includes:</p>
          <ul className="list-disc pl-6 space-y-1 mt-2">
            <li>Ensuring the container is privileged (for necessary permissions)</li>
            <li>Enabling nesting feature</li>
            <li>Adding device permissions for TPU and GPU access</li>
            <li>Setting up proper mounts for TPU and GPU devices</li>
          </ul>
        </Steps.Step>
        <Steps.Step title="Driver Installation">
          <p>Inside the container, the script installs required packages:</p>
          <ul className="list-disc pl-6 space-y-1 mt-2">
            <li>GPU drivers (va-driver-all, intel-opencl-icd)</li>
            <li>Coral TPU dependencies and drivers</li>
            <li>Python and necessary libraries</li>
          </ul>
        </Steps.Step>
        <Steps.Step title="Coral TPU Driver Selection">
          <p>
            If a Coral M.2 device is detected, you'll be prompted to choose between standard and maximum performance
            drivers.
          </p>
        </Steps.Step>
      </Steps>

      <h2 className="text-2xl font-semibold mt-8 mb-4">What to Expect</h2>
      <ul className="list-disc pl-6 space-y-2 mb-6">
        <li>The script will guide you through the process with clear prompts.</li>
        <li>Your selected container will be stopped briefly during configuration.</li>
        <li>The entire process usually takes a few minutes to complete.</li>
        <li>After completion, your container will be ready to use both Coral TPU and the host's iGPU.</li>
      </ul>

      <h2 className="text-2xl font-semibold mt-8 mb-4">Important Notes</h2>
      <ul className="list-disc pl-6 space-y-2 mb-6">
        <li>This script supports both USB and M.2 versions of Coral TPU.</li>
        <li>The container will be changed to privileged mode if it wasn't already.</li>
        <li>Ensure your Proxmox host has the necessary Coral TPU and Intel GPU drivers installed.</li>
        <li>
          For M.2 Coral TPUs, you can choose between standard and maximum performance modes. The maximum performance
          mode may generate more heat.
        </li>
        <li>Some applications inside the container may require additional setup to utilize the Coral TPU.</li>
      </ul>

      <p className="mt-6 italic">
        This script simplifies the process of enabling Coral TPU and iGPU acceleration in your LXC containers without
        the need for manual configuration file editing or running complex commands. This setup is ideal for AI and
        machine learning workloads that can benefit from hardware acceleration.
      </p>
    </div>
  )
}

