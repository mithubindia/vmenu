import type { Metadata } from "next"
import { LineChart } from "lucide-react"

export const metadata: Metadata = {
  title: "ProxMenux Post-Install: Monitoring Settings",
  description:
    "Comprehensive guide to Monitoring Settings in the ProxMenux post-install script for optimizing Proxmox VE system monitoring and alerting.",
  openGraph: {
    title: "ProxMenux Post-Install: Monitoring Settings",
    description:
      "Comprehensive guide to Monitoring Settings in the ProxMenux post-install script for optimizing Proxmox VE system monitoring and alerting.",
    type: "article",
    url: "https://macrimi.github.io/ProxMenux/docs/post-install/monitoring",
    images: [
      {
        url: "https://macrimi.github.io/ProxMenux/monitoring-settings-image.png",
        width: 1200,
        height: 630,
        alt: "ProxMenux Post-Install Monitoring Settings",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "ProxMenux Post-Install: Monitoring Settings",
    description:
      "Comprehensive guide to Monitoring Settings in the ProxMenux post-install script for optimizing Proxmox VE system monitoring and alerting.",
    images: ["https://macrimi.github.io/ProxMenux/monitoring-settings-image.png"],
  },
}

export default function MonitoringSettingsPage() {
  return (
    <div className="container mx-auto px-4 py-8">
      <div className="flex items-center mb-6">
        <LineChart className="h-8 w-8 mr-2 text-blue-500" />
        <h1 className="text-3xl font-bold">Monitoring Settings</h1>
      </div>
      <p className="mb-4">
        The Monitoring Settings category in the customizable_post_install.sh script focuses on setting up and optimizing
        system monitoring and alerting for your Proxmox VE installation.
      </p>
      <h2 className="text-2xl font-semibold mt-6 mb-4">Available Optimizations</h2>
      <ul className="list-disc pl-5 mb-6">
        <li className="mb-2">
          <strong>System Metrics:</strong> Configure collection and storage of key system metrics.
        </li>
        <li className="mb-2">
          <strong>Alert Configuration:</strong> Set up alerts for critical system events and thresholds.
        </li>
        <li className="mb-2">
          <strong>Logging Optimization:</strong> Fine-tune system logging for better troubleshooting and analysis.
        </li>
        {/* Add more list items for each optimization in this category */}
      </ul>
      <h2 className="text-2xl font-semibold mt-6 mb-4">Usage</h2>
      <p className="mb-4">
        When running the customizable_post_install.sh script, you'll be prompted to choose which Monitoring Settings to
        apply. Select the options that best suit your monitoring needs and system requirements.
      </p>
    </div>
  )
}

