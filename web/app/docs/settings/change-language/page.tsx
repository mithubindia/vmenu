import type { Metadata } from "next"

export const metadata: Metadata = {
  title: "Change Language | vmenu Documentation",
  description: "Guide to changing the language settings in vmenu for Virtuliser VE.",
}

export default function ChangeLanguage() {
  return (
    <div className="max-w-3xl mx-auto">
      <h1 className="text-3xl font-bold mb-6">Change Language in vmenu</h1>
      
      <p className="mb-4">
        vmenu supports multiple languages to improve accessibility for users worldwide. The recommended language is <strong>English</strong>. 
        Translations are generated automatically using a predefined translation package and Google Translate. Automatic translations may contain errors, 
        so English is the preferred language for accuracy.
      </p>

      <h2 className="text-2xl font-semibold mt-8 mb-4">Available Languages</h2>
      <ul className="list-disc pl-6 space-y-2 mb-6">
        <li>English (Recommended)</li>
        <li>Spanish</li>
        <li>French</li>
        <li>German</li>
        <li>Italian</li>
        <li>Portuguese</li>
      </ul>

      <h2 className="text-2xl font-semibold mt-8 mb-4">How It Works</h2>
      <p className="mb-4">
        The language configuration is stored in the vmenu settings file. When a new language is selected, the configuration file is updated, and the menu reloads with the new language.
      </p>

      <h2 className="text-2xl font-semibold mt-8 mb-4">Key Functions</h2>
      <ul className="list-disc pl-6 space-y-2 mb-6">
        <li>Displays a menu with available languages.</li>
        <li>Updates the vmenu configuration with the selected language.</li>
        <li>Reloads the menu to apply the new language setting.</li>
      </ul>
    </div>
  )
}
