import type { Metadata } from "next"
import { Steps } from "@/components/ui/steps"

export const metadata: Metadata = {
  title: "Change Language | ProxMenux Documentation",
  description: "Learn how to change the language settings in ProxMenux for Proxmox VE.",
}

export default function ChangeLanguage() {
  return (
    <div className="max-w-3xl mx-auto">
      <h1 className="text-3xl font-bold mb-6">Change Language in ProxMenux</h1>
      <p className="mb-4">
        ProxMenux supports multiple languages to make it accessible to users worldwide. This guide will walk you through
        the process of changing the language settings in ProxMenux.
      </p>

      <h2 className="text-2xl font-semibold mt-8 mb-4">Supported Languages</h2>
      <ul className="list-disc pl-6 space-y-2 mb-6">
        <li>English (Default)</li>
        <li>Spanish</li>
        <li>French</li>
        <li>German</li>
        <li>Italian</li>
        {/* Add more languages as they become available */}
      </ul>

      <h2 className="text-2xl font-semibold mt-8 mb-4">Steps to Change Language</h2>
      <Steps>
        <Steps.Step title="Access Settings">
          <p>From the main menu of ProxMenux, navigate to the "Settings" option.</p>
        </Steps.Step>
        <Steps.Step title="Select Language Option">
          <p>In the Settings menu, find and select the "Change Language" option.</p>
        </Steps.Step>
        <Steps.Step title="Choose New Language">
          <p>You will see a list of available languages. Select your desired language from the list.</p>
        </Steps.Step>
        <Steps.Step title="Confirm Selection">
          <p>
            Confirm your selection when prompted. ProxMenux will ask if you're sure you want to change the language.
          </p>
        </Steps.Step>
        <Steps.Step title="Restart ProxMenux">
          <p>
            After confirming, ProxMenux will apply the new language settings and may need to restart. Follow any
            on-screen instructions to complete the process.
          </p>
        </Steps.Step>
      </Steps>

      <h2 className="text-2xl font-semibold mt-8 mb-4">Troubleshooting</h2>
      <p className="mb-4">
        If you encounter any issues while changing the language or if the new language doesn't apply correctly, try the
        following:
      </p>
      <ul className="list-disc pl-6 space-y-2">
        <li>Ensure you have the latest version of ProxMenux installed</li>
        <li>Try restarting ProxMenux manually if it doesn't restart automatically</li>
        <li>Check the ProxMenux log files for any error messages related to language changes</li>
        <li>If problems persist, consider reinstalling ProxMenux or seeking help from the community forums</li>
      </ul>
    </div>
  )
}

