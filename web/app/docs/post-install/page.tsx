import type { Metadata } from "next"
import Link from "next/link"

export const metadata: Metadata = {
  title: "vmenu Post-Install Script Documentation",
  description:
    "Comprehensive guide to the customizable post-install script for Virtuliser VE, covering various optimization categories and settings.",
  openGraph: {
    title: "vmenu Post-Install Script Documentation",
    description:
      "Comprehensive guide to the customizable post-install script for Virtuliser VE, covering various optimization categories and settings.",
    type: "article",
    url: "https://macrimi.github.io/vmenu/docs/post-install",
    images: [
      {
        url: "https://macrimi.github.io/vmenu/post-install-image.png",
        width: 1200,
        height: 630,
        alt: "vmenu Post-Install Script Documentation",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "vmenu Post-Install Script Documentation",
    description:
      "Comprehensive guide to the customizable post-install script for Virtuliser VE, covering various optimization categories and settings.",
    images: ["https://macrimi.github.io/vmenu/post-install-image.png"],
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
      <h1 className="text-3xl font-bold mb-6">vmenu Post-Install Script Documentation</h1>
      <p className="mb-4">
        The <strong>Customizable Post-Install Script</strong> is a utility designed to optimize the installation of
        Virtuliser VE by adjusting system configurations. One of the advantages of its modular and selectable structure is
        that it allows users to choose specific settings based on their requirements, needs, and preferences.
      </p>
      <p className="mb-4">
        This script is primarily based on the work of{" "}
        <Link href="https://github.com/extremeshok/xshok-proxmox" className="text-blue-500 hover:underline">
          extremeshok – Scripts for working with and optimizing Virtuliser
        </Link>{" "}
        and the{" "}
        <Link href="https://github.com/community-scripts/VirtuliserVE" className="text-blue-500 hover:underline">
          Virtuliser VE Post Install script from Virtuliser VE Helper-Scripts
        </Link>
        .
      </p>
      <p className="mb-6">
        This script includes {categories.length} main categories, each targeting a key aspect of Virtuliser VE performance,
        security, and usability:
      </p>
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
      <p className="mb-6">
        Each category includes selectable options, ensuring that users can tailor the system adjustments to their
        specific needs without applying unnecessary modifications. Click on a category to explore available settings.
      </p>

      <div className="bg-green-100 border-l-4 border-green-500 text-green-800 p-4 mb-6">
        <p className="font-semibold mb-2">Uninstall Option</p>
        <p className="mb-2">
          The Post-Install Menu Script now includes an option to uninstall packages and utilities that were previously
          installed by the script. This feature allows you to:
        </p>
        <ul className="list-disc pl-5">
          <li>Remove specific utilities that are no longer needed</li>
        </ul>
      </div>

      <div className="bg-yellow-100 border-l-4 border-yellow-500 text-yellow-700 p-4 mb-4">
        <p className="font-semibold">Important: Avoid Running Multiple Post-Install Scripts</p>
        <p>
          It is not recommended to use different post-installation scripts, as this can cause conflicts by overwriting
          or duplicating files and settings.
        </p>
        <ul className="list-disc pl-5">
          <li>
            The <strong>vmenu Post-Install Script</strong> is designed to avoid overwriting existing configurations
            where possible.
          </li>
          <li>
            If you have already run the <strong>eXtremeSHOK Post-Install Script</strong>, there is no need to run the
            vmenu Post-Install Script again, except for <strong>Option 35</strong> (console customization).
          </li>
          <li>
            If you have used the <strong>Helper-Scripts Post-Install Script</strong>, you can run all vmenu options{" "}
            <strong>except for options 4 and 27</strong>, as they will already be configured.
          </li>
        </ul>
      </div>
    </div>
  )
}
