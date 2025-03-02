import type { Metadata } from "next"
import Link from "next/link"

export const metadata: Metadata = {
  title: "ProxMenux Post-Install Script Documentation",
  description:
    "Comprehensive guide to the customizable post-install script for Proxmox VE, covering various optimization categories and settings.",
  openGraph: {
    title: "ProxMenux Post-Install Script Documentation",
    description:
      "Comprehensive guide to the customizable post-install script for Proxmox VE, covering various optimization categories and settings.",
    type: "article",
    url: "https://macrimi.github.io/ProxMenux/docs/post-install",
    images: [
      {
        url: "https://macrimi.github.io/ProxMenux/post-install-image.png",
        width: 1200,
        height: 630,
        alt: "ProxMenux Post-Install Script Documentation",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "ProxMenux Post-Install Script Documentation",
    description:
      "Comprehensive guide to the customizable post-install script for Proxmox VE, covering various optimization categories and settings.",
    images: ["https://macrimi.github.io/ProxMenux/post-install-image.png"],
  },
}

const categories = [
  { name: "Basic Settings", order: 1 },
  { name: "System", order: 2 },
  { name: "Virtualization", order: 3 },
  { name: "Network", order: 4 },
  { name: "Storage", order: 5 },
  { name: "Security", order: 6 },
  { name: "Customization", order: 7 },
  { name: "Monitoring", order: 8 },
  { name: "Performance", order: 9 },
  { name: "Optional", order: 10 },
]

export default function PostInstallPage() {
  return (
    <div className="container mx-auto px-4 py-8">
      <h1 className="text-3xl font-bold mb-6">ProxMenux Post-Install Script Documentation</h1>
      <p className="mb-4">
        The customizable_post_install.sh script is a comprehensive tool for optimizing and customizing your Proxmox VE
        installation. It covers a wide range of settings across various categories, allowing you to fine-tune your
        system according to your specific needs.
      </p>
      <p className="mb-6">This script includes {categories.length} main categories of optimizations and settings:</p>
      <ul className="list-disc pl-5 mb-6">
        {categories.map((category) => (
          <li key={category.order} className="mb-2">
            <Link
              href={`/docs/post-install/${category.name.toLowerCase().replace(" ", "-")}`}
              className="text-blue-500 hover:underline"
            >
              {category.name}
            </Link>
          </li>
        ))}
      </ul>
      <p>Click on each category to learn more about the specific optimizations and settings available.</p>
    </div>
  )
}

