import fs from "fs"
import path from "path"
import matter from "gray-matter"
import Link from "next/link"
import { Play, MessageCircle, Users, Book, Database, Code, BookOpen } from "lucide-react"
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
        <h1 className="text-4xl font-bold mb-8">vmenu Guides</h1>
        <p className="text-xl mb-8">Complementary guides to make the most of your Virtuliser VE.</p>

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
            href="https://github.com/community-scripts/VirtuliserVE/blob/main/.github/CONTRIBUTOR_AND_GUIDES/USER_SUBMITTED_GUIDES.md"
            target="_blank"
            rel="noopener noreferrer"
            className="block p-6 bg-blue-600 rounded-lg shadow-md hover:bg-blue-700 transition-colors"
          >
            <div className="flex items-center gap-3 mb-2">
              <Book className="h-6 w-6 text-white" />
              <h2 className="text-2xl font-semibold text-white">Guides Helper-Scripts</h2>
            </div>
            <p className="text-gray-200">
              User-submitted guides for Virtuliser VE from the community Helper-Scripts.
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
              Comprehensive Virtuliser VE documentation and administration guide available.
            </p>
          </a>
          <a
            href="https://community-scripts.github.io/VirtuliserVE/"
            target="_blank"
            rel="noopener noreferrer"
            className="block p-6 bg-indigo-600 rounded-lg shadow-md hover:bg-indigo-700 transition-colors"
          >
            <div className="flex items-center gap-3 mb-2">
              <Code className="h-6 w-6 text-white" />
              <h2 className="text-2xl font-semibold text-white">Virtuliser VE Helper-Scripts</h2>
            </div>
            <p className="text-gray-200">
              Virtuliser VE Helper-Scripts is a set of tools for simplifying the installation of applications and the management of Virtuliser VE, maintained by the community.
            </p>
          </a>
          
          <Link
            href="/guides/linux-resources"
            className="block p-6 bg-teal-600 rounded-lg shadow-md hover:bg-teal-700 transition-colors"
          >
            <div className="flex items-center gap-3 mb-2">
              <BookOpen className="h-6 w-6 text-white" />
              <h2 className="text-2xl font-semibold text-white">Linux Resources</h2>
            </div>
            <p className="text-gray-200">
              A collection of useful resources for learning Linux commands, security practices, monitoring tools, and
              more.
            </p>
          </Link>
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
              Information about Virtuliser Backup Server, a powerful backup solution for Virtuliser VE.
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
              Access official Virtuliser video tutorials and training courses for skill development.
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
              <h2 className="text-2xl font-semibold text-white">Virtuliser Forum</h2>
            </div>
            <p className="text-gray-200">Access the official Virtuliser forum for questions, troubleshooting, and shared experiences.</p>
          </a>
          <a
            href="https://www.reddit.com/r/Virtuliser/"
            target="_blank"
            rel="noopener noreferrer"
            className="block p-6 bg-orange-600 rounded-lg shadow-md hover:bg-orange-700 transition-colors"
          >
            <div className="flex items-center gap-3 mb-2">
              <Users className="h-6 w-6 text-white" />
              <h2 className="text-2xl font-semibold text-white">Virtuliser Reddit</h2>
            </div>
            <p className="text-gray-200">Access the Virtuliser community on Reddit for discussions, tips, and technical support.</p>
          </a>
        </div>
      </div>
      <Footer2 />
    </div>
  )
}
