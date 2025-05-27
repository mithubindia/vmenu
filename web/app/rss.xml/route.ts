import { NextResponse } from "next/server"
import fs from "fs"
import path from "path"

interface ChangelogEntry {
  version: string
  date: string
  content: string
  url: string
}

async function parseChangelog(): Promise<ChangelogEntry[]> {
  try {
    const changelogPath = path.join(process.cwd(), "..", "CHANGELOG.md")

    if (!fs.existsSync(changelogPath)) {
      return []
    }

    const fileContents = fs.readFileSync(changelogPath, "utf8")
    const entries: ChangelogEntry[] = []

    const sections = fileContents.split(/^## /gm).filter((section) => section.trim())

    for (const section of sections) {
      const lines = section.split("\n")
      const headerLine = lines[0]

      const versionMatch = headerLine.match(/\[([^\]]+)\]/)
      const dateMatch = headerLine.match(/(\d{4}-\d{2}-\d{2})/)

      if (versionMatch) {
        const version = versionMatch[1]
        const date = dateMatch ? dateMatch[1] : new Date().toISOString().split("T")[0]
        const content = lines.slice(1).join("\n").trim()

        entries.push({
          version,
          date,
          content,
          url: `${process.env.NEXT_PUBLIC_SITE_URL || "https://macrimi.github.io/ProxMenux"}/changelog#${version}`,
        })
      }
    }

    return entries.slice(0, 10)
  } catch (error) {
    console.error("Error parsing changelog:", error)
    return []
  }
}

export async function GET() {
  const entries = await parseChangelog()
  const siteUrl = process.env.NEXT_PUBLIC_SITE_URL || "https://macrimi.github.io/ProxMenux"

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
      <title>ProxMenux ${entry.version}</title>
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
