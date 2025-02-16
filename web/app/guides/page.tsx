import fs from "fs"
import path from "path"
import matter from "gray-matter"
import Link from "next/link"
import { Play, MessageCircle, Users, Book, Database, Code } from "lucide-react"
import Footer2 from "@/components/footer2"

const guidesDirectory = path.join(process.cwd(), "..", "guides")

interface Guide {
  title: string
  description: string
  slug: string
}

function getGuides(): Guide[] {
  const guides: Guide[] = []

  function findGuides(dir: string, basePath = "") {
    fs.readdirSync(dir, { withFileTypes: true }).forEach((entry) => {
      const fullPath = path.join(dir, entry.name)
      const relativePath = path.join(basePath, entry.name)

      if (entry.isDirectory()) {
        findGuides(fullPath, relativePath)
      } else if (entry.isFile() && entry.name.endsWith(".md")) {
        const slug = relativePath.replace(/\.md$/, "")

        const fileContents = fs.readFileSync(fullPath, "utf8")
        const { data } = matter(fileContents)

        guides.push({
          title: data.title || slug.replace(/_/g, " "),
          description: data.description || "No description available.",
          slug,
        })
      }
    })
  }

  findGuides(guidesDirectory)
  return guides
}

export default function GuidesPage() {
  const guides = getGuides()

  return (
    <div className="min-h-screen bg-gradient-to-b from-gray-900 to-gray-800 text-white pt-16 flex flex-col">
      <div className="flex-grow container mx-auto px-4 py-16">
        <h1 className="text-4xl font-bold mb-8">ProxMenux Guides</h1>
        <p className="text-xl mb-8">Complementary guides to make the most of your Proxmox VE.</p>

        {/* Dynamic Guides */}
        <div className="grid md:grid-cols-2 gap-6 mb-12">
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

        {/* Additional Resources */}
        <h2 className="text-3xl font-bold mb-6">Additional Resources</h2>
        <div className="grid md:grid-cols-2 gap-6 mb-12">
          <a
            href="https://github.com/community-scripts/ProxmoxVE/blob/main/USER_SUBMITTED_GUIDES.md"
            target="_blank"
            rel="noopener noreferrer"
            className="block p-6 bg-blue-600 rounded-lg shadow-md hover:bg-blue-700 transition-colors"
          >
            <div className="flex items-center gap-3 mb-2">
              <Code className="h-6 w-6 text-white" />
              <h2 className="text-2xl font-semibold text-white">Community Helper-Scripts</h2>
            </div>
            <p className="text-gray-200">
              User-submitted guides and scripts for Proxmox VE from the community.
            </p>
          </a>
          <a
            href="https://pve.proxmox.com/pve-docs/index.html"
            target="_blank"
            rel="noopener noreferrer"
            className="block p-6 bg-green-600 rounded-lg shadow-md hover:bg-green-700 transition-colors"
          >
            <div className="flex items-center gap-3 mb-2">
              <Book className="h-6 w-6 text-white" />
              <h2 className="text-2xl font-semibold text-white">Official Documentation</h2>
            </div>
            <p className="text-gray-200">
              Comprehensive Proxmox VE documentation and administration guide available.
            </p>
          </a>
        </div>

        {/* PBS Documentation */}
        <h2 className="text-3xl font-bold mb-6">Backup Server Documentation</h2>
        <div className="mb-12">
          <a
            href="https://pbs.proxmox.com/docs/index.html"
            target="_blank"
            rel="noopener noreferrer"
            className="block p-6 bg-yellow-600 rounded-lg shadow-md hover:bg-yellow-700 transition-colors"
          >
            <div className="flex items-center gap-3 mb-2">
              <Database className="h-6 w-6 text-white" />
              <h2 className="text-2xl font-semibold text-white">Backup Server Docs</h2>
            </div>
            <p className="text-gray-200">
              Information about Proxmox Backup Server, a powerful backup solution for Proxmox VE.
            </p>
          </a>
        </div>

        {/* Video Tutorials */}
        <h2 className="text-3xl font-bold mb-6">Video Tutorials</h2>
        <div className="mb-12">
          <a
            href="https://www.proxmox.com/en/services/training-courses/videos?utm_source"
            target="_blank"
            rel="noopener noreferrer"
            className="block p-6 bg-red-600 rounded-lg shadow-md hover:bg-red-700 transition-colors"
          >
            <div className="flex items-center gap-3 mb-2">
              <Play className="h-6 w-6 text-white" />
              <h2 className="text-2xl font-semibold text-white">Official Video Training</h2>
            </div>
            <p className="text-gray-200">
              Access official Proxmox video tutorials and training courses for skill development.
            </p>
          </a>
        </div>

        {/* Community Discussion */}
        <h2 className="text-3xl font-bold mb-6">Community Discussion</h2>
        <div className="grid md:grid-cols-2 gap-6">
          <a
            href="https://forum.proxmox.com/"
            target="_blank"
            rel="noopener noreferrer"
            className="block p-6 bg-purple-600 rounded-lg shadow-md hover:bg-purple-700 transition-colors"
          >
            <div className="flex items-center gap-3 mb-2">
              <MessageCircle className="h-6 w-6 text-white" />
              <h2 className="text-2xl font-semibold text-white">Proxmox Forum</h2>
            </div>
            <p className="text-gray-200">Access the official Proxmox forum for questions, troubleshooting, and shared experiences.</p>
          </a>
          <a
            href="https://www.reddit.com/r/Proxmox/"
            target="_blank"
            rel="noopener noreferrer"
            className="block p-6 bg-orange-600 rounded-lg shadow-md hover:bg-orange-700 transition-colors"
          >
            <div className="flex items-center gap-3 mb-2">
              <Users className="h-6 w-6 text-white" />
              <h2 className="text-2xl font-semibold text-white">Proxmox Reddit</h2>
            </div>
            <p className="text-gray-200">Access the Proxmox community on Reddit for discussions, tips, and technical support.</p>
          </a>
        </div>
      </div>
      <Footer2 />
    </div>
  )
}
