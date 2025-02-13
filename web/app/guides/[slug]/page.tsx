import fs from "fs"
import path from "path"
import { remark } from "remark"
import html from "remark-html"

// Function to retrieve the guide content based on the slug
async function getGuideContent(slug: string) {
  // Adjusted to look inside the correct 'guides' folder at the root level of the project
  const guidePath = path.join(process.cwd(), "..", "guides", slug, "index.md") // Corrected to look in the root directory
  const fileContents = fs.readFileSync(guidePath, "utf8")

  const result = await remark().use(html).process(fileContents)
  return result.toString()
}

// Function to generate static paths for all available guides
export async function generateStaticParams() {
  // Adjusted to look in the correct 'guides' folder at the root level of the project
  const guidesPath = path.join(process.cwd(), "..", "guides")
  const guideFolders = fs.readdirSync(guidesPath, { withFileTypes: true }) // Read only directories

  return guideFolders
    .filter((folder) => folder.isDirectory()) // Ensure it's a directory
    .map((folder) => ({
      slug: folder.name, // Use the folder name as slug
    }))
}

// Page component to render a guide based on its slug
export default async function GuidePage({ params }: { params: { slug: string } }) {
  const guideContent = await getGuideContent(params.slug)

  return (
    <div className="container mx-auto px-4 py-16 max-w-3xl">
      <div className="prose prose-lg dark:prose-invert" dangerouslySetInnerHTML={{ __html: guideContent }} />
    </div>
  )
}
