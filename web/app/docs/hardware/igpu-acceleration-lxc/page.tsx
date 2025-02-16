import type { Metadata } from "next"
import { Steps } from "@/components/ui/steps"

export const metadata: Metadata = {
  title: "HW iGPU Acceleration to an LXC | ProxMenux Documentation",
  description: "Learn how to enable hardware iGPU acceleration for an LXC container in Proxmox VE using ProxMenux.",
}

export default function IGPUAccelerationLXC() {
  return (
    <div className="max-w-3xl mx-auto">
      <h1 className="text-3xl font-bold mb-6">HW iGPU Acceleration to an LXC</h1>

      <p className="mb-4">
        This guide explains how ProxMenux helps you enable Intel Integrated GPU (iGPU) acceleration for LXC containers
        in Proxmox VE. This feature allows your containers to use the host's Intel GPU for tasks like video transcoding,
        rendering, and accelerating graphics-intensive applications.
      </p>

      <h2 className="text-2xl font-semibold mt-8 mb-4">What Does This Script Do?</h2>
      <p className="mb-4">When you run this script through ProxMenux, it performs the following actions:</p>
      <ol className="list-decimal pl-6 space-y-2 mb-6">
        <li>Presents a list of your LXC containers for you to choose from</li>
        <li>Configures the selected container to support iGPU acceleration</li>
        <li>Installs necessary drivers and tools inside the container</li>
      </ol>

      <h2 className="text-2xl font-semibold mt-8 mb-4">Key Steps</h2>
      <Steps>
        <Steps.Step title="Container Selection">
          <p>You'll be prompted to select the LXC container you want to enable iGPU acceleration for.</p>
        </Steps.Step>
        <Steps.Step title="Container Configuration">
          <p>The script modifies the container's configuration to allow iGPU access. This includes:</p>
          <ul className="list-disc pl-6 space-y-1 mt-2">
            <li>Ensuring the container is privileged (for necessary permissions)</li>
            <li>Enabling nesting feature</li>
            <li>Adding device permissions for GPU access</li>
            <li>Setting up proper mounts for GPU devices</li>
          </ul>
        </Steps.Step>
        <Steps.Step title="Driver Installation">
          <p>Inside the container, the script installs required packages:</p>
          <ul className="list-disc pl-6 space-y-1 mt-2">
            <li>GPU drivers (va-driver-all)</li>
            <li>OpenCL libraries</li>
            <li>Intel GPU tools</li>
          </ul>
        </Steps.Step>
        <Steps.Step title="Permission Setup">
          <p>The script sets up proper permissions for GPU access within the container.</p>
        </Steps.Step>
      </Steps>

      <h2 className="text-2xl font-semibold mt-8 mb-4">What to Expect</h2>
      <ul className="list-disc pl-6 space-y-2 mb-6">
        <li>The script will guide you through the process with clear prompts.</li>
        <li>Your selected container will be stopped briefly during configuration.</li>
        <li>The entire process usually takes a few minutes to complete.</li>
        <li>After completion, your container will be ready to use the host's iGPU.</li>
      </ul>

      <h2 className="text-2xl font-semibold mt-8 mb-4">Important Notes</h2>
      <ul className="list-disc pl-6 space-y-2 mb-6">
        <li>This script is designed for Intel iGPUs. It may not work with other GPU types.</li>
        <li>The container will be changed to privileged mode if it wasn't already.</li>
        <li>Ensure your Proxmox host has the necessary Intel GPU drivers installed.</li>
        <li>Some applications inside the container may require additional setup to utilize the GPU.</li>
      </ul>

      <p className="mt-6 italic">
        By using this ProxMenux script, you can easily enable iGPU acceleration in your LXC containers without needing
        to manually edit configuration files or run complex commands.
      </p>
    </div>
  )
}
