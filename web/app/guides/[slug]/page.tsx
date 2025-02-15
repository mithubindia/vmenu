import fs from "fs"
import path from "path"
import { remark } from "remark"
import html from "remark-html"
import dynamic from "next/dynamic"

const CopyableCode = dynamic(() => import("@/components/CopyableCode"), { ssr: false })

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

function wrapCodeBlocksWithCopyable(content: string) {
  // Reemplazar los bloques de código de Markdown con CopyableCode
  const codeBlockRegex = /<pre><code>([\s\S]*?)<\/code><\/pre>/g

  return content.replace(codeBlockRegex, (match, code) => {
    return `
      <div class="bg-gray-100 border border-gray-300 rounded-md p-4 overflow-auto">
        <CopyableCode code={\`${code.replace(/`/g, "\\`")}\`} />
      </div>
    `
  })
}

export default async function GuidePage({ params }: { params: { slug: string } }) {
  let guideContent = await getGuideContent(params.slug)
  guideContent = wrapCodeBlocksWithCopyable(guideContent)

  return (
    <div className="min-h-screen bg-white">
      <div className="container mx-auto px-4 py-16 max-w-3xl">
        <div
          className="prose prose-gray max-w-none"
          dangerouslySetInnerHTML={{ __html: guideContent }}
        />
      </div>
    </div>
  )
}
