import fs from "fs"
import path from "path"
import { remark } from "remark"
import html from "remark-html"

async function getChangelog() {
  const changelogPath = path.join(process.cwd(), "CHANGELOG.md")
  const fileContents = fs.readFileSync(changelogPath, "utf8")

  const result = await remark().use(html).process(fileContents)
  return result.toString()
}

export default async function ChangelogPage() {
  const changelogContent = await getChangelog()

  return (
    <div className="container mx-auto px-4 py-16 max-w-4xl">
      <h1 className="text-4xl font-bold mb-8">Changelog</h1>
      <div className="prose prose-lg dark:prose-invert" dangerouslySetInnerHTML={{ __html: changelogContent }} />
    </div>
  )
}

