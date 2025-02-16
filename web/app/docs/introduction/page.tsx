import Link from "next/link"

export default function IntroductionPage() {
  return (
    <div className="max-w-3xl mx-auto">
      <h1 className="text-3xl font-bold mb-6">Introduction to ProxMenux</h1>
      <p className="mb-4">
        ProxMenux is a tool designed to make Proxmox VE more accessible to all users, regardless of experience.
        <br />
        <br />
        Through a menu-based interface, it simplifies the execution of complex commands for server configuration,
        maintenance, and application installations without requiring manual input.
        <br />
        <br />
        ProxMenux not only streamlines Proxmox VE management but also interacts with hardware and drivers, simplifying
        tasks such as storage management, disk handling, and image imports to facilitate system administration and
        maintenance.
      </p>
      <h2 className="text-2xl font-semibold mt-8 mb-4">Key Features</h2>
      <ul className="list-disc pl-6 space-y-2">
        <li>Menu-based interface for easy script execution.</li>
        <li>Organized categories for quick access to available functions.</li>
        <li>Scripts hosted on GitHub, always accessible and up to date.</li>
        <li>Automatic text translation using Google Translate.</li>
        <li>Simplified Proxmox VE management, reducing the complexity of common tasks.</li>
      </ul>
      <p className="mt-6">
        The following sections of this documentation provide instructions on how to install ProxMenux and detailed
        explanations of each available script. 
        <br />
        <br />
        For additional Proxmox-related information, including guides, official
        documentation, forums, and discussions, visit the{" "}
        <Link href="/guides" className="text-blue-500 hover:underline">
          Guides
        </Link>{" "}
        section.
      </p>
    </div>
  )
}
