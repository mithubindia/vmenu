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
          className="prose prose-gray max-w-none
            [&>h1]:text-3xl [&>h1]:font-bold [&>h1]:text-gray-900 [&>h1]:mb-4
            [&>h2]:text-2xl [&>h2]:font-semibold [&>h2]:text-gray-800 [&>h2]:mb-3
            [&>h3]:text-xl [&>h3]:font-medium [&>h3]:text-gray-700 [&>h3]:mb-2
            [&>p]:text-base [&>p]:text-gray-600 [&>p]:mb-4
            [&>ul]:list-disc [&>ul]:pl-5 [&>ul]:mb-4
            [&>ul>li]:text-gray-600 [&>ul>li]:mb-1
            [&>a]:text-blue-600 [&>a:hover]:text-blue-800
            [&>hr]:my-8 [&>hr]:border-t [&>hr]:border-gray-300"
          dangerouslySetInnerHTML={{ __html: changelogContent }}
        />
      </div>
    </div>
  )
}
