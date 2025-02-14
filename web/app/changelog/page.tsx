import fs from "fs"
import path from "path"

async function getChangelog() {
  const changelogPath = path.join(process.cwd(), "..", "CHANGELOG.md")
  try {
    return fs.readFileSync(changelogPath, "utf8")
  } catch (error) {
    console.error("Error reading changelog file:", error)
    return "<p>Changelog content not found.</p>"
  }
}

export default async function ChangelogPage() {
  const changelogContent = await getChangelog()

  return (
    <div className="min-h-screen bg-white text-black">
      <div className="container mx-auto px-4 py-16 max-w-4xl">
        <h1 className="text-4xl font-bold mb-8 text-black">Changelog</h1>
        <div className="prose prose-black max-w-none" dangerouslySetInnerHTML={{ __html: changelogContent }} />
      </div>
    </div>
  )
}

