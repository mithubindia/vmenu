"use client"

import { Book, GitBranch, FileText, Github } from "lucide-react"
import Link from "next/link"

const resources = [
  {
    icon: <Book className="h-6 w-6" />,
    title: "Documentation",
    description: "System description and user guides",
    link: "/docs/introduction",
  },
  {
    icon: <FileText className="h-6 w-6" />,
    title: "Changelog",
    description: "Information on the latest updates",
    link: "/changelog",
  },
  {
    icon: <GitBranch className="h-6 w-6" />,
    title: "Guides",
    description: "Step-by-step tutorials and guides for common tasks",
    link: "/guides",
  },
  {
    icon: <Github className="h-6 w-6" />,
    title: "GitHub Repository",
    description: "Explore the source code.",
    link: "https://github.com/MacRimi/vmenu",
  },
]

export default function Resources() {
  return (
    <section className="py-20 bg-gray-900">
      <div className="container mx-auto px-4">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
          {resources.map((resource, index) => (
            <Link key={index} href={resource.link} className="block h-full">
              <div className="bg-gray-800 p-6 rounded-lg shadow-lg hover:bg-gray-700 transition-colors duration-200 h-full flex flex-col justify-between">
                <div className="flex items-center mb-4">
                  {resource.icon}
                  <h3 className="text-xl font-semibold ml-2">{resource.title}</h3>
                </div>
                <p className="text-gray-400 min-h-[48px]">{resource.description}</p>
              </div>
            </Link>
          ))}
        </div>
      </div>
    </section>
  )
}
