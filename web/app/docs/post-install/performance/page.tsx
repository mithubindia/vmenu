import type { Metadata } from "next"
import { Zap } from "lucide-react"

export const metadata: Metadata = {
  title: "ProxMenux Post-Install: Performance Settings",
  description:
    "Detailed guide to Performance Settings in the ProxMenux post-install script for optimizing Proxmox VE system performance.",
  openGraph: {
    title: "ProxMenux Post-Install: Performance Settings",
    description:
      "Detailed guide to Performance Settings in the ProxMenux post-install script for optimizing Proxmox VE system performance.",
    type: "article",
    url: "https://macrimi.github.io/ProxMenux/docs/post-install/performance",
    images: [
      {
        url: "https://macrimi.github.io/ProxMenux/performance-settings-image.png",
        width: 1200,
        height: 630,
        alt: "ProxMenux Post-Install Performance Settings",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "ProxMenux Post-Install: Performance Settings",
    description:
      "Detailed guide to Performance Settings in the ProxMenux post-install script for optimizing Proxmox VE system performance.",
    images: ["https://macrimi.github.io/ProxMenux/performance-settings-image.png"],
  },
}

export default function PerformanceSettingsPage() {
  return (
    <div className="container mx-auto px-4 py-8">
      <div className="flex items-center mb-6">
        <Zap className="h-8 w-8 mr-2 text-blue-500" />
        <h1 className="text-3xl font-bold">Performance Settings</h1>
      </div>
      <p className="mb-4">
        The Performance Settings category in the customizable_post_install.sh script is dedicated to optimizing the
        overall performance of your Proxmox VE system.
      </p>
      <h2 className="text-2xl font-semibold mt-6 mb-4">Available Optimizations</h2>
      <ul className="list-disc pl-5 mb-6">
        <li className="mb-2">
          <strong>CPU Tuning:</strong> Optimize CPU governor and other CPU-related settings.
        </li>
        <li className="mb-2">
          <strong>Memory Management:</strong> Fine-tune memory allocation and swapping behavior.
        </li>
        <li className="mb-2">
          <strong>I/O Optimization:</strong> Adjust I/O scheduler and other disk-related performance settings.
        </li>
        {/* Add more list items for each optimization in this category */}
      </ul>
      <h2 className="text-2xl font-semibold mt-6 mb-4">Usage</h2>
      <p className="mb-4">
        During the execution of customizable_post_install.sh, you'll have the option to apply various Performance
        Settings. Choose the optimizations that best match your hardware configuration and workload requirements.
      </p>
    </div>
  )
}

