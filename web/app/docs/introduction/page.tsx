export default function IntroductionPage() {
  return (
    <div className="max-w-3xl mx-auto">
      <h1 className="text-3xl font-bold mb-6">Introduction to ProxMenux</h1>
      <p className="mb-4">
        ProxMenux is a tool designed to simplify and streamline the management of Proxmox VE through a menu-based interface. It allows users to execute shell scripts in an organized way, eliminating the need to manually enter complex commands.

        It is designed for both experienced Proxmox VE administrators and less experienced users, providing a more accessible and efficient way to manage their infrastructure.
  
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
        The following sections of this documentation provide instructions on how to install ProxMenux and detailed explanations of each available script.
      </p>
    </div>
  )
}

