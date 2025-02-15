import fs from "fs"
import path from "path"
import { remark } from "remark"
import html from "remark-html"

async function getGuideContent(slug: string) {
  const guidePath = path.join(process.cwd(), "..", "guides", `${slug}.md`)
  const fileContents = fs.readFileSync(guidePath, "utf8")

  const result = await remark().use(html).process(fileContents)
  return result.toString()
}

export async function generateStaticParams() {
  const guideFiles = fs.readdirSync(path.join(process.cwd(), "..", "guides"))
  return guideFiles.map((file) => ({
    slug: file.replace(/\.md$/, ""),
  }))
}

export default async function GuidePage({ params }: { params: { slug: string } }) {
  const guideContent = await getGuideContent(params.slug)

 
  const wrapCodeBlocks = (content: string) => {
    return content.replace(
      /<pre><code>([\s\S]*?)<\/code><\/pre>/g,
      (match, code) => `<CopyableCode code="${encodeURIComponent(code.trim())}" />`,
    )
  }

  const wrappedContent = wrapCodeBlocks(guideContent)

  return (
    <div className="min-h-screen bg-white text-gray-900">
      <div className="container mx-auto px-4 py-16 max-w-3xl">
        <div
          className="prose prose-lg max-w-none prose-pre:bg-gray-100 prose-pre:text-gray-900 prose-headings:text-gray-900 prose-p:text-gray-800"
          dangerouslySetInnerHTML={{ __html: wrappedContent }}
        />
      </div>
    </div>
  )
}

