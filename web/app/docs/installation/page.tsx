"use client"

import CopyableCode from "@/components/CopyableCode"
import Image from "next/image"

export default function InstallationPage() {
  const installationCode = `bash -c \"$(wget -qLO - https://raw.githubusercontent.com/MacRimi/ProxMenux/main/install_proxmenux.sh)\"`

  return (
    <div className="w-full max-w-4xl mx-auto px-4 py-8 text-gray-900">
      <h1 className="text-3xl font-bold mb-6">Installing ProxMenux</h1>

      <h2 className="text-xl font-semibold mt-6 mb-2">Installation</h2>
      <p className="mb-2">To install ProxMenux, simply run the following command in your Proxmox server terminal:</p>
      <div className="w-full mb-4">
        <CopyableCode code={installationCode} />
      </div>

      <p className="mb-4">During installation, ProxMenux will automatically install and configure the following dependencies:</p>
      <ul className="list-disc list-inside mb-4">
        <li>whiptail - for interactive menus</li>
        <li>curl - for downloading remote files</li>
        <li>jq - for handling JSON data</li>
        <li>Python 3 and virtual environment - required for translations</li>
        <li>Google Translate (googletrans) - for multi-language support</li>
      </ul>

      <h2 className="text-xl font-semibold mt-6 mb-2">Installation Progress</h2>
      <p className="mb-2">The installation process will look like this:</p>
      <div className="w-full mb-4">
        <Image src="https://macrimi.github.io/ProxMenux/install/install.png" alt="ProxMenux Installation" width={800} height={400} className="rounded shadow-lg" />
      </div>

      <h2 className="text-xl font-semibold mt-6 mb-2">How to Use</h2>
      <p className="mb-2">Once installed, launch <strong>ProxMenux</strong> by running:</p>
      <div className="w-full mb-4">
        <CopyableCode code="menu" />
      </div>

      <h2 className="text-xl font-semibold mt-8 mb-4">Troubleshooting</h2>
      <p className="mb-4">
        If you encounter any issues during installation or usage, please check the {" "}
        <a href="https://github.com/MacRimi/ProxMenux/issues" className="text-blue-600 hover:underline">
          GitHub Issues
        </a>{" "}
        page or open a new issue if your problem isn't already addressed.
      </p>
    </div>
  )
}
