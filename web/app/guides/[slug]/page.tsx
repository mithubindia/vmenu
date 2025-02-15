import fs from "fs"
import path from "path"
import { remark } from "remark"
import html from "remark-html"
import GuideContent from "./GuideContent"

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

export default async function GuidePage({ params }: { params: { slug: string } }) {
  const guideContent = await getGuideContent(params.slug)

  return (
    <div className="min-h-screen bg-white">
      <GuideContent content={guideContent} />
    </div>
  )
}

