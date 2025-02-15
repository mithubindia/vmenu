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
  const codeBlockRegex = /<pre><code>([\s\S]*?)<\/code><\/pre>/g
  return content.replace(codeBlockRegex, (match, code) => {
    return `<CopyableCode code={\`${code.replace(/`/g, "\\`")}\`} />`
  })
}

export default async function GuidePage({ params }: { params: { slug: string } }) {
  let guideContent = await getGuideContent(params.slug)
  guideContent = wrapCodeBlocksWithCopyable(guideContent)

  return (
    <div className="min-h-screen bg-white">
      <div className="container mx-auto px-4 py-16 max-w-3xl">
        <div
          className="prose prose-gray max-w-none
            [&>h1]:text-3xl [&>h1]:font-bold [&>h1]:text-gray-900 [&>h1]:mb-6
            [&>h2]:text-2xl [&>h2]:font-semibold [&>h2]:text-gray-900 [&>h2]:mt-8 [&>h2]:mb-4
            [&>h3]:text-xl [&>h3]:font-semibold [&>h3]:text-gray-900 [&>h3]:mt-6 [&>h3]:mb-3
            [&>p]:text-gray-700 [&>p]:mb-4
            [&>ul]:list-disc [&>ul]:pl-5 [&>ul]:mb-4
            [&>ul>li]:text-gray-700 [&>ul>li]:mb-2
            [&>ol]:list-decimal [&>ol]:pl-5 [&>ol]:mb-4
            [&>ol>li]:text-gray-700 [&>ol>li]:mb-2
            [&>a]:text-blue-600 [&>a:hover]:underline
            [&>strong]:font-bold [&>strong]:text-gray-900"
          dangerouslySetInnerHTML={{ __html: guideContent }}
        />
      </div>
    </div>
  )
}

