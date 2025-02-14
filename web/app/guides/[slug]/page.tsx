import fs from "fs"
import path from "path"
import { remark } from "remark"
import html from "remark-html"

const guidesDirectory =
  process.env.NODE_ENV === "production"
    ? path.join(process.cwd(), "..", "..", "guides")
    : path.join(process.cwd(), "..", "guides")

async function getGuideContent(slug: string) {
  const fullPath = path.join(guidesDirectory, `${slug}.md`)
  const fileContents = fs.readFileSync(fullPath, "utf8")

  const result = await remark().use(html).process(fileContents)
  return result.toString()
}

export async function generateStaticParams() {
  try {
    const guideFiles = fs.readdirSync(guidesDirectory)
    return guideFiles.map((file) => ({
      slug: file.replace(/\.md$/, ""),
    }))
  } catch (error) {
    console.error("Error reading guides directory:", error)
    return []
  }
}

export default async function GuidePage({ params }: { params: { slug: string } }) {
  try {
    const guideContent = await getGuideContent(params.slug)
    return (
      <div className="container mx-auto px-4 py-16 max-w-3xl">
        <div className="prose prose-lg" dangerouslySetInnerHTML={{ __html: guideContent }} />
      </div>
    )
  } catch (error) {
    console.error("Error rendering guide:", error)
    return <div>Error: Unable to load guide content.</div>
  }
}


