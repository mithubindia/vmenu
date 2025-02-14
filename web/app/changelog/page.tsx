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
    <div className="min-h-screen bg-white">
      <div className="container mx-auto px-4 py-16 max-w-4xl">
        <h1 className="text-4xl font-bold mb-8 text-gray-900">Changelog</h1>
        <div
          className="prose prose-gray max-w-none [&>h2]:text-2xl [&>h2]:font-bold [&>h2]:mt-8 [&>h2]:mb-4 [&>h3]:text-xl [&>h3]:font-semibold [&>h3]:mt-6 [&>h3]:mb-3 [&>p]:text-gray-700 [&>ul]:list-disc [&>ul]:pl-5 [&>ul]:text-gray-700 [&>a]:text-blue-600 [&>a:hover]:text-blue-800"
          dangerouslySetInnerHTML={{ __html: changelogContent }}
        />
      </div>
    </div>
  )
}

