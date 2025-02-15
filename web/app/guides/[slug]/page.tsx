"use client"

import { useState, useEffect } from "react"
import fs from "fs"
import path from "path"
import { remark } from "remark"
import html from "remark-html"
import CopyableCode from "@/components/CopyableCode"

const guidesDirectory = path.join(process.cwd(), "..", "guides")

async function getGuideContent(slug: string) {
  const fullPath = path.join(guidesDirectory, `${slug}.md`)
  try {
    const fileContents = fs.readFileSync(fullPath, "utf8")
    const result = await remark().use(html).process(fileContents)
    return result.toString()
  } catch (error) {
    console.error(`Error reading guide file: ${fullPath}`, error)
    return "<p>Guide content not found.</p>"
  }
}

export async function generateStaticParams() {
  try {
    if (fs.existsSync(guidesDirectory)) {
      const guideFiles = fs.readdirSync(guidesDirectory)
      return guideFiles.map((file) => ({
        slug: file.replace(/\.md$/, ""),
      }))
    } else {
      console.warn("Guides directory not found. No static params generated.")
      return []
    }
  } catch (error) {
    console.error("Error generating static params for guides:", error)
    return []
  }
}

function processContent(content: string) {
  const codeBlockRegex = /<pre><code>([\s\S]*?)<\/code><\/pre>/g
  return content.replace(codeBlockRegex, (match, code) => {
    return `<CopyableCodePlaceholder code="${encodeURIComponent(code)}" />`
  })
}

export default function GuidePage({ params }: { params: { slug: string } }) {
  const [guideContent, setGuideContent] = useState<string>("")

  useEffect(() => {
    async function fetchContent() {
      const content = await getGuideContent(params.slug)
      setGuideContent(processContent(content))
    }
    fetchContent()
  }, [params.slug])

  useEffect(() => {
    const placeholders = document.querySelectorAll("CopyableCodePlaceholder")
    placeholders.forEach((placeholder, index) => {
      // Added index for key
      const code = decodeURIComponent(placeholder.getAttribute("code") || "")
      const codeElement = <CopyableCode key={index} code={code} /> // Added key prop
      placeholder.replaceWith(codeElement)
    })
  }, []) // Removed guideContent from dependencies

  return (
    <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-8 text-gray-900">
      <div
        className="prose prose-gray max-w-none
          [&>h1]:text-3xl [&>h1]:sm:text-4xl [&>h1]:font-bold [&>h1]:mb-6
          [&>h2]:text-2xl [&>h2]:font-semibold [&>h2]:mt-8 [&>h2]:mb-4
          [&>h3]:text-xl [&>h3]:font-medium [&>h3]:mt-6 [&>h3]:mb-3
          [&>p]:mb-4 [&>p]:text-gray-600
          [&>ul]:list-disc [&>ul]:pl-5 [&>ul]:mb-4
          [&>ul>li]:text-gray-600 [&>ul>li]:mb-2
          [&>ol]:list-decimal [&>ol]:pl-5 [&>ol]:mb-4
          [&>ol>li]:text-gray-600 [&>ol>li]:mb-2
          [&>a]:text-blue-600 [&>a:hover]:underline"
        dangerouslySetInnerHTML={{ __html: guideContent }}
      />
    </div>
  )
}

