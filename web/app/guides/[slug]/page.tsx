import fs from "fs"
import path from "path"
import { remark } from "remark"
import html from "remark-html"

async function getGuideContent(slug: string) {
  const guidePath = path.join(process.cwd(), "guides", `${slug}.md`)
  const fileContents = fs.readFileSync(guidePath, "utf8")

  const result = await remark().use(html).process(fileContents)
  return result.toString()
}

export async function generateStaticParams() {
  const guideFiles = fs.readdirSync(path.join(process.cwd(), "guides"))
  return guideFiles.map((file) => ({
    slug: file.replace(/\.md$/, ""),
  }))
}

export default async function GuidePage({ params }: { params: { slug: string } }) {
  const guideContent = await getGuideContent(params.slug)

  return (
    <div className="container mx-auto px-4 py-16 max-w-3xl">
      <div className="prose prose-lg dark:prose-invert" dangerouslySetInnerHTML={{ __html: guideContent }} />
    </div>
  )
}

