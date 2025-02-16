import type React from "react"
import fs from "fs"
import path from "path"
import matter from "gray-matter"
import Link from "next/link"
import Footer from "@/components/footer2"

const guidesDirectory = path.join(process.cwd(), "..", "guides")

interface Guide {
  title: string
  description: string
  slug: string
}

function getGuides(): Guide[] {
  let guides: Guide[] = []

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
      <Footer2 />
    </div>
  )
}
