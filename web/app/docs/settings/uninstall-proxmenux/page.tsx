import type { Metadata } from "next"

export const metadata: Metadata = {
  title: "Uninstall vmenu | vmenu Documentation",
  description: "Guide to uninstalling vmenu from your Virtuliser VE system.",
}

export default function Uninstallvmenu() {
  return (
    <div className="max-w-3xl mx-auto">
      <h1 className="text-3xl font-bold mb-6">Uninstall vmenu</h1>
      
      <p className="mb-4">
        The <strong>Uninstall vmenu</strong> function, remove vmenu and its related components from their Virtuliser VE system.
        The script provides an interactive option to remove dependencies as well, ensuring a clean uninstallation process.
      </p>

      <h2 className="text-2xl font-semibold mt-8 mb-4">How It Works</h2>
      <p className="mb-4">
        When executed, the script performs the following actions:
      </p>
      <ul className="list-disc pl-6 space-y-2 mb-6">
        <li>Prompts the user for confirmation before proceeding with the uninstallation.</li>
        <li>Provides an option to remove dependencies such as Python virtual environment and package manager.</li>
        <li>Deletes the vmenu installation directory and its configuration files.</li>
        <li>Removes cached data and stored settings.</li>
        <li>Ensures the removal of installed components and performs cleanup.</li>
      </ul>

      <h2 className="text-2xl font-semibold mt-8 mb-4">Important Considerations</h2>
      <ul className="list-disc pl-6 space-y-2 mb-6">
        <li>Removing dependencies is optional. If selected, system-wide packages used by other applications might also be removed.</li>
        <li>Once uninstalled, vmenu cannot be restored unless reinstalled manually.</li>
      </ul>

    </div>
  )
}
