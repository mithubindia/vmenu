import type { Metadata } from "next"


export const metadata: Metadata = {
  title: "Show Version Information | vmenu Documentation",
  description: "Displays vmenu version details and installed components.",
}

export default function ShowVersionInformation() {
  return (
    <div className="max-w-3xl mx-auto">
      <h1 className="text-3xl font-bold mb-6">Show Version Information</h1>
      
      <p className="mb-4">
        The <strong>Show Version Information</strong> function provides details about the current vmenu installation, including
        the version number, installed components, and configuration files. This helps users verify their setup.
      </p>
      
    </div>
  )
}
