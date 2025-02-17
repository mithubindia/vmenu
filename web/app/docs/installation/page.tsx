"use client"

import CopyableCode from "@/components/CopyableCode"

export default function InstallationPage() {
  const installationCode = `bash -c "$(wget -qLO - https://raw.githubusercontent.com/MacRimi/ProxMenux/main/install_proxmenux.sh)"`

  return (
    <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-8 text-gray-900">
      <h1 className="text-3xl sm:text-4xl font-bold mb-6">Installing ProxMenux</h1>

      <h2 className="text-2xl font-semibold mt-8 mb-4">Installation</h2>
      <p className="mb-4">To install ProxMenux, simply run the following command in your Proxmox server terminal:</p>
      
      <div className="overflow-x-auto max-w-full">
        <CopyableCode code={installationCode} />
      </div>

      <h2 className="text-2xl font-semibold mt-8 mb-4">How to Use</h2>
      <p className="mb-4">
        Once installed, launch <strong>ProxMenux</strong> by running:
      </p>
      
      <div className="overflow-x-auto max-w-full">
        <CopyableCode code="menu" />
      </div>

      <h2 className="text-2xl font-semibold mt-8 mb-4">Troubleshooting</h2>
      <p className="mb-4">
        If you encounter any issues during installation or usage, please check the{" "}
        <a href="https://github.com/MacRimi/ProxMenux/issues" className="text-blue-600 hover:underline">
          GitHub Issues
        </a>{" "}
        page or open a new issue if your problem isn't already addressed.
      </p>
    </div>
  )
}
