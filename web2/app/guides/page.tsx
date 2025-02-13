import Link from "next/link"

// Interface defining the structure of a guide
interface Guide {
  title: string
  description: string
  slug: string
}

// Guide list (manually added, can be automated later)
const guides: Guide[] = [
  {
    title: "Setting up NVIDIA Drivers on Proxmox VE with GPU Passthrough",
    description:
      "Learn how to install and configure NVIDIA drivers on your Proxmox VE host and enable GPU passthrough to your virtual machines.",
    slug: "nvidia_proxmox",
  },
  {
    title: "Example Additional Guide",
    description: "This is a sample guide to show how multiple guides are handled.",
    slug: "example_guide",
  },
  // Add more guides as needed
]

// Main component that renders the list of available guides
export default function GuidesPage() {
  return (
    <div className="container mx-auto px-4 py-16">
      <h1 className="text-4xl font-bold mb-8">ProxMenux Guides</h1>
      <p className="text-xl mb-8">Complementary guides to make the most of your Proxmox VE.</p>
      <div className="grid md:grid-cols-2 gap-6">
        {guides.map((guide) => (
          <Link
            key={guide.slug}
            href={`/guides/${guide.slug}`}
            className="block p-6 bg-white rounded-lg shadow-md hover:shadow-lg transition-shadow"
          >
            <h2 className="text-2xl font-semibold mb-2 text-gray-900">{guide.title}</h2>
            <p className="text-gray-600">{guide.description}</p>
          </Link>
        ))}
      </div>
    </div>
  )
}
