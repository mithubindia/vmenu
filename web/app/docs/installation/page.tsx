"use client"

import CopyableCode from "@/components/CopyableCode"

export default function InstallationPage() {
  const installationCode = `bash -c "$(wget -qLO - https://raw.githubusercontent.com/MacRimi/ProxMenux/main/install_proxmenux.sh)"`

  return (
    <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8 text-gray-900">
      <h1 className="text-2xl sm:text-3xl md:text-4xl font-bold mb-6">Installing ProxMenux</h1>

      <h2 className="text-lg sm:text-xl font-semibold mt-6 mb-2">Installation</h2>
      <p className="mb-2 text-sm">
        To install ProxMenux, simply run the following command in your Proxmox server terminal:
      </p>
      <div className="w-full overflow-hidden mb-4">
        <CopyableCode code={installationCode} className="w-full" />
      </div>

      <h2 className="text-lg sm:text-xl font-semibold mt-6 mb-2">How to Use</h2>
      <p className="mb-2 text-sm">
        Once installed, launch <strong>ProxMenux</strong> by running:
      </p>
      <div className="w-full overflow-hidden mb-4">
        <CopyableCode code="menu" className="w-full" />
      </div>

      <h2 className="text-xl sm:text-2xl font-semibold mt-8 mb-4">Troubleshooting</h2>
      <p className="mb-4 text-sm sm:text-base">
        If you encounter any issues during installation or usage, please check the{" "}
        <a href="https://github.com/MacRimi/ProxMenux/issues" className="text-blue-600 hover:underline">
          GitHub Issues
        </a>{" "}
        page or open a new issue if your problem isn't already addressed.
      </p>
    </div>
  )
}

