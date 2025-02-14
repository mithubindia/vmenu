import fs from "fs"
import path from "path"

async function getChangelog() {
  const changelogPath = path.join(process.cwd(), "..", "CHANGELOG.md")
  try {
    const fileContents = fs.readFileSync(changelogPath, "utf8")
    return fileContents // Ahora el archivo ya es HTML, no necesita conversión
  } catch (error) {
    console.error("Error reading changelog file:", error)
    return "<p>Changelog content not found.</p>"
  }
}

export default async function ChangelogPage() {
  const changelogContent = await getChangelog()

  return (
    <div className="bg-white text-gray-900 min-h-screen">
      <div className="container mx-auto px-4 py-16 max-w-4xl">
        <h1 className="text-4xl font-bold mb-8">Changelog</h1>
        <div
          className="prose prose-lg max-w-none bg-gray-100 p-4 border border-gray-300 rounded-md"
          dangerouslySetInnerHTML={{ __html: changelogContent }} // Renderiza directamente el HTML
        />
      </div>
    </div>
  )
}
