import fs from "fs"
import path from "path"
import { remark } from "remark"
import html from "remark-html"
import dynamic from "next/dynamic"

const CopyableCode = dynamic(() => import("@/components/CopyableCode"), { ssr: false })

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


function wrapCodeBlocksWithCopyable(content: string) {
  return content.replace(
    /<pre><code class="language-(.*?)">([\s\S]*?)<\/code><\/pre>/g,
    (match, lang, code) =>
      `<div class="copyable-code-container"><CopyableCode code="${encodeURIComponent(
        code.trim()
      )}" /></div>`
  )
}

export default async function GuidePage({ params }: { params: { slug: string } }) {
  let guideContent = await getGuideContent(params.slug)
  guideContent = wrapCodeBlocksWithCopyable(guideContent)

  return (
    <div className="min-h-screen bg-white text-gray-900">
      <div className="container mx-auto px-4 py-16 max-w-3xl">
        <div className="prose max-w-none" dangerouslySetInnerHTML={{ __html: guideContent }} />
      </div>
    </div>
  )
}
