import fs from "fs"
import path from "path"
import { remark } from "remark"
import html from "remark-html"

async function getGuideContent(slug: string) {
  const guidePath = path.join(process.cwd(), "..", "guides", `${slug}.md`)
  const fileContents = fs.readFileSync(guidePath, "utf8")

  const result = await remark()
    .use(html, { sanitize: false }) // Permitir HTML sin sanitizar para preservar los estilos
    .process(fileContents)
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

  // Función para envolver los bloques de código con CopyableCode
  const wrapCodeBlocks = (content: string) => {
    return content.replace(
      /<pre><code(?:\s+class="language-(\w+)")?>([\s\S]*?)<\/code><\/pre>/g,
      (_, language, code) => `<CopyableCode code="${encodeURIComponent(code.trim())}" language="${language || ""}" />`,
    )
  }

  const wrappedContent = wrapCodeBlocks(guideContent)

  return (
    <div className="min-h-screen bg-white text-gray-900">
      <div className="container mx-auto px-4 py-16 max-w-3xl">
        <div className="prose max-w-none" dangerouslySetInnerHTML={{ __html: wrappedContent }} />
      </div>
    </div>
  )
}

