import fs from "fs"
import path from "path"
import { remark } from "remark"
import html from "remark-html"

function markdownToHtml(markdown: string): string {
  return markdown
    .replace(/^### (.*$)/gim, "<h3>$1</h3>") 
    .replace(/^## (.*$)/gim, "<h2>$1</h2>") 
    .replace(/^# (.*$)/gim, "<h1>$1</h1>") 
    .replace(/\*\*(.*?)\*\*/gim, "<b>$1</b>") 
    .replace(/\*(.*?)\*/gim, "<i>$1</i>") 
    .replace(/`(.*?)`/gim, "<code>$1</code>") 
    .replace(/^- (.*$)/gim, "<ul><li>$1</li></ul>") 
    .replace(/\n/g, "<br />"); 
}

async function getChangelog() {
  const changelogPath = path.join(process.cwd(), "..", "CHANGELOG.md")
  try {
    const fileContents = fs.readFileSync(changelogPath, "utf8")

    // Convertimos Markdown a HTML manualmente
    const formattedContent = markdownToHtml(fileContents)

    // Usamos remark-html como último paso
    const result = await remark().use(html).process(formattedContent)

    return result.toString()
  } catch (error) {
    console.error("Error reading changelog file:", error)
    return "<p>Changelog content not found.</p>"
  }
}

export default async function ChangelogPage() {
  const changelogContent = await getChangelog()

  return (
    <div className="bg-white text-gray-900">
      <div className="container mx-auto px-4 py-16 max-w-4xl">
        <h1 className="text-4xl font-bold mb-8">Changelog</h1>
        <div className="prose prose-lg max-w-none" dangerouslySetInnerHTML={{ __html: changelogContent }} />
      </div>
    </div>
  )
}
