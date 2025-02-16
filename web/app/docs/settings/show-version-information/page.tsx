import type { Metadata } from "next"
import { Steps } from "@/components/ui/steps"

export const metadata: Metadata = {
  title: "Show Version Information | ProxMenux Documentation",
  description: "Learn how to view version information for ProxMenux in Proxmox VE.",
}

export default function ShowVersionInformation() {
  return (
    <div className="max-w-3xl mx-auto">
      <h1 className="text-3xl font-bold mb-6">Show Version Information in ProxMenux</h1>
      <p className="mb-4">
        Knowing the version of ProxMenux you're using is important for troubleshooting, getting support, and ensuring
        you have the latest features. This guide explains how to view version information in ProxMenux.
      </p>

      <h2 className="text-2xl font-semibold mt-8 mb-4">Steps to Show Version Information</h2>
      <Steps>
        <Steps.Step title="Access Settings">
          <p>From the main menu of ProxMenux, navigate to the "Settings" option.</p>
        </Steps.Step>
        <Steps.Step title="Select Version Information">
          <p>In the Settings menu, find and select the "Show Version Information" option.</p>
        </Steps.Step>
        <Steps.Step title="View Version Details">
          <p>ProxMenux will display a screen with detailed version information, including:</p>
          <ul className="list-disc pl-6 space-y-2 mt-2">
            <li>ProxMenux version number</li>
            <li>Release date</li>
            <li>Compatibility information</li>
            <li>Last update check date</li>
            <li>Installed modules or plugins (if applicable)</li>
          </ul>
        </Steps.Step>
      </Steps>

      <h2 className="text-2xl font-semibold mt-8 mb-4">Understanding Version Numbers</h2>
      <p className="mb-4">
        ProxMenux follows semantic versioning. The version number is typically in the format X.Y.Z, where:
      </p>
      <ul className="list-disc pl-6 space-y-2 mb-4">
        <li>X is the major version number (significant changes)</li>
        <li>Y is the minor version number (new features, backwards-compatible)</li>
        <li>Z is the patch version number (bug fixes and minor improvements)</li>
      </ul>
      <p className="mb-4">
        For example, version 1.2.3 would indicate the first major release, with two feature updates and three patch
        releases.
      </p>

      <h2 className="text-2xl font-semibold mt-8 mb-4">Checking for Updates</h2>
      <p className="mb-4">
        After viewing your current version, you may want to check if there's a newer version available. Here's how:
      </p>
      <ol className="list-decimal pl-6 space-y-2">
        <li>Look for an "Check for Updates" option in the Settings menu</li>
        <li>If available, select this option to manually check for updates</li>
        <li>ProxMenux will compare your version with the latest available version</li>
        <li>If an update is available, follow the prompts to download and install it</li>
      </ol>

      <p className="mt-4">
        Remember to always back up your Proxmox VE configuration before updating ProxMenux to ensure you can revert
        changes if needed.
      </p>
    </div>
  )
}

