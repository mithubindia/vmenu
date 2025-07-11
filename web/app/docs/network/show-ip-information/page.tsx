import type { Metadata } from "next"
import { Steps } from "@/components/ui/steps"

export const metadata: Metadata = {
  title: "Show IP Information | vmenu Documentation",
  description: "Learn how to display IP information for Virtuliser VE and its virtual machines using vmenu.",
}

export default function ShowIPInformation() {
  return (
    <div className="max-w-3xl mx-auto">
      <h1 className="text-3xl font-bold mb-6">Show IP Information</h1>

      <p className="mb-4">
        The Show IP Information function it provides a quick and
        easy way to view the IP configurations of all relevant network interfaces in your Virtuliser VE system.
      </p>

      <h2 className="text-2xl font-semibold mt-8 mb-4">What Does Show IP Information Do?</h2>
      <p className="mb-4">When you select the Show IP Information option, the script performs the following actions:</p>
      <ol className="list-decimal pl-6 space-y-2 mb-6">
        <li>Detects all relevant network interfaces (physical and bridges)</li>
        <li>Retrieves the IP address for each detected interface</li>
        <li>Displays a comprehensive list of interfaces and their associated IP addresses</li>
        <li>Indicates if an interface has no IP assigned</li>
      </ol>



      <h2 className="text-2xl font-semibold mt-8 mb-4">Key Features of Show IP Information</h2>
      <ul className="list-disc pl-6 space-y-2 mb-6">
        <li>Comprehensive detection of all relevant network interfaces</li>
        <li>Display of IP addresses for each detected interface</li>
        <li>Indication of interfaces without assigned IP addresses</li>
        <li>Quick and easy access to network configuration information</li>
        <li>Non-intrusive operation (does not make any changes to the system)</li>
      </ul>
    </div>
  )
}
