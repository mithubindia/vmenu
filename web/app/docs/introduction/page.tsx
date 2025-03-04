import Image from "next/image"
import Link from "next/link"

export default function IntroductionPage() {
  return (
    <div className="w-full max-w-4xl mx-auto px-4 py-8 text-gray-900">
      {/* Logo + Title Section */}
      <div className="flex items-center mb-6">
        <Image 
          src="https://macrimi.github.io/ProxMenux/logo.png" 
          alt="ProxMenux Logo" 
          width={80} 
          height={80} 
          className="mr-4"
        />
        <p className="text-lg text-gray-800">
          ProxMenux is a management tool for Proxmox VE, designed to be accessible to all users, 
          regardless of their experience or technical knowledge.
        </p>
      </div>

      <p className="mb-4">
        With an interactive menu-driven interface, ProxMenux simplifies command execution for managing:
      </p>
      <ul className="list-disc list-inside mb-4 ml-4">
        <li>The Proxmox server</li>
        <li>Virtual machines (VMs)</li>
        <li>Containers (LXC)</li>
      </ul>

      <h2 className="text-2xl font-semibold mt-8 mb-4">Core Features</h2>
      <p className="mb-4">
        ProxMenux enables streamlined management of:
      </p>
      <ul className="list-disc list-inside mb-6 ml-4">
        <li>System resources</li>
        <li>Network and storage configurations</li>
        <li>VM and LXC container administration</li>
        <li>Hardware integration and optimizations</li>
        <li>Automated server maintenance</li>
      </ul>

      <h2 className="text-2xl font-semibold mt-8 mb-4">Key Advantages</h2>
      <ul className="list-disc list-inside mb-6 ml-4">
        <li>Intuitive menu-driven interface</li>
        <li>Efficient system and resource management</li>
        <li>Reduced complexity for common tasks</li>
        <li>Regular updates with expanding features</li>
      </ul>

      <p className="mt-6">
        The following sections provide detailed instructions on installing and using ProxMenux, along with comprehensive documentation on its available functionalities.
      </p>

      {/* Guides Link */}
      <p className="mt-6">
        For additional Proxmox-related information, including official documentation, forums, and discussions, visit the{" "}
        <Link href="/guides" className="text-blue-500 hover:underline">
          Guides
        </Link>{" "} 
        section.
      </p>
    </div>
  )
}
