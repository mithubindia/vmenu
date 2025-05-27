import { NextResponse } from "next/server"
import fs from "fs"
import path from "path"

interface ChangelogEntry {
  version: string
  date: string
  content: string
  url: string
  title: string
}

async function parseChangelog(): Promise<ChangelogEntry[]> {
  try {
    const changelogPath = path.join(process.cwd(), "..", "CHANGELOG.md")

    if (!fs.existsSync(changelogPath)) {
      return []
    }

    const fileContents = fs.readFileSync(changelogPath, "utf8")
    const entries: ChangelogEntry[] = []

    // Split by any heading (## or ###) to catch all changes, not just versions
    const sections = fileContents.split(/^(##\s+.*$)/gm).filter((section) => section.trim())

    for (let i = 0; i < sections.length - 1; i += 2) {
      const headerLine = sections[i]
      const content = sections[i + 1] || ""

      // Check if it's a version header (## [version] - date)
      const versionMatch = headerLine.match(/##\s+\[([^\]]+)\]\s*-\s*(\d{4}-\d{2}-\d{2})/)

      if (versionMatch) {
        const version = versionMatch[1]
        const date = versionMatch[2]

        entries.push({
          version,
          date,
          content: content.trim(),
          url: `https://macrimi.github.io/ProxMenux/changelog#${version}`,
          title: `ProxMenux ${version}`,
        })
      } else {
        // Check for date-only headers (## 2025-05-13)
        const dateMatch = headerLine.match(/##\s+(\d{4}-\d{2}-\d{2})/)
        if (dateMatch) {
          const date = dateMatch[1]

          entries.push({
            version: date,
            date,
            content: content.trim(),
            url: `https://macrimi.github.io/ProxMenux/changelog#${date}`,
            title: `ProxMenux Update ${date}`,
          })
        }
      }
    }

    return entries.slice(0, 15) // Latest 15 entries
  } catch (error) {
    console.error("Error parsing changelog:", error)
    return []
  }
}

export async function GET() {
  const entries = await parseChangelog()
  const siteUrl = "https://macrimi.github.io/ProxMenux"

  const rssXml = `<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
  <channel>
    <title>ProxMenux Changelog</title>
    <description>Latest updates and changes in ProxMenux</description>
    <link>${siteUrl}/changelog</link>
    <atom:link href="${siteUrl}/rss.xml" rel="self" type="application/rss+xml"/>
    <language>en-US</language>
    <lastBuildDate>${new Date().toUTCString()}</lastBuildDate>
    <generator>ProxMenux RSS Generator</generator>
    <ttl>60</ttl>
    
    ${entries
      .map(
        (entry) => `
    <item>
      <title>${entry.title}</title>
      <description><![CDATA[${entry.content.substring(0, 500)}${entry.content.length > 500 ? "..." : ""}]]></description>
      <link>${entry.url}</link>
      <guid isPermaLink="true">${entry.url}</guid>
      <pubDate>${new Date(entry.date).toUTCString()}</pubDate>
      <category>Changelog</category>
    </item>`,
      )
      .join("")}
  </channel>
</rss>`

  return new NextResponse(rssXml, {
    headers: {
      "Content-Type": "application/rss+xml; charset=utf-8",
      "Cache-Control": "public, max-age=3600, s-maxage=3600",
    },
  })
}
