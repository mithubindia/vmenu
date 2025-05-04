"use client"

import React, { useState } from "react"
import Link from "next/link"
import { Package, ArrowLeft, Copy, Check, Terminal } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from "@/components/ui/accordion"

export default function UpdateCommandsPage() {
  const [viewMode, setViewMode] = useState<"table" | "accordion">("table")

  // Group commands by category for better organization
  const commandGroups = [
    {
      title: "System Updates",
      commands: [
        { command: "apt update && apt upgrade -y", description: "Update and upgrade all system packages" },
        { command: "apt dist-upgrade -y", description: "Full system upgrade, including dependencies" },
        { command: "apt update", description: "Update package lists only" },
        { command: "apt upgrade", description: "Upgrade packages only (interactive)" },
        { command: "apt full-upgrade", description: "Upgrade packages with dependency handling (interactive)" },
      ],
    },
    {
      title: "Proxmox Updates",
      commands: [
        { command: "pveupdate", description: "Update Proxmox package lists" },
        { command: "pveupgrade", description: "Show available Proxmox upgrades" },
        { command: "pve-upgrade", description: "Perform Proxmox VE upgrade" },
        { command: "pveceph upgrade", description: "Upgrade Ceph packages (if Ceph is installed)" },
      ],
    },
    {
      title: "Package Management",
      commands: [
        { command: "apt autoremove --purge", description: "Remove unused packages and their config" },
        { command: "apt clean", description: "Clear out the local repository of retrieved package files" },
        { command: "apt autoclean", description: "Clear out only outdated package files" },
        { command: "apt install <package>", description: "Install a specific package" },
        { command: "apt remove <package>", description: "Remove a package" },
        { command: "apt purge <package>", description: "Remove a package and its configuration files" },
      ],
    },
    {
      title: "Package Information",
      commands: [
        { command: "apt list --installed", description: "List all installed packages" },
        { command: "apt search <keyword>", description: "Search for packages by keyword" },
        { command: "apt show <package>", description: "Show detailed information about a package" },
        { command: "dpkg -l", description: "List all installed packages (alternative)" },
        { command: "dpkg -l | grep <keyword>", description: "Search installed packages by keyword" },
        { command: "apt-cache policy <package>", description: "Show package versions and priorities" },
      ],
    },
    {
      title: "Repository Management",
      commands: [
        { command: "cat /etc/apt/sources.list", description: "Show main APT repository sources" },
        { command: "ls -la /etc/apt/sources.list.d/", description: "List additional repository source files" },
        {
          command: "cat /etc/apt/sources.list.d/pve-enterprise.list",
          description: "Show Proxmox Enterprise repo config",
        },
        { command: "apt-key list", description: "List repository signing keys" },
      ],
    },
  ]

  return (
    <div className="container mx-auto py-10 px-4 bg-white text-black">
      <div className="mb-6">
        <Link
          href="/docs/help-info"
          className="flex items-center text-blue-500 hover:text-blue-700 transition-colors mb-6"
        >
          <ArrowLeft className="mr-2 h-4 w-4" />
          Back to Help and Info
        </Link>

        <div className="flex items-center gap-3 mb-4">
          <Package className="h-8 w-8 mr-2 text-blue-500" />
          <h1 className="text-3xl font-bold text-black">Updates and Packages Commands</h1>
        </div>

        <p className="text-lg mb-6">
          This section provides commands for managing system updates and packages in Proxmox VE. Learn how to update
          your system, install and remove packages, search for software, and manage repositories.
        </p>

        <div className="flex gap-2 mb-6">
          <Button
            variant={viewMode === "table" ? "default" : "outline"}
            onClick={() => setViewMode("table")}
            className="bg-blue-500 hover:bg-blue-600 text-white"
          >
            Table View
          </Button>
          <Button
            variant={viewMode === "accordion" ? "default" : "outline"}
            onClick={() => setViewMode("accordion")}
            className="bg-blue-500 hover:bg-blue-600 text-white"
          >
            Accordion View
          </Button>
        </div>
      </div>

      {viewMode === "table" ? (
        <div className="space-y-8">
          {commandGroups.map((group, index) => (
            <div key={index} className="mb-8">
              <h2 className="text-xl font-semibold mb-4 text-black">{group.title}</h2>
              <div className="border-2 border-gray-200 rounded-md overflow-hidden">
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead className="w-1/3 bg-gray-100 text-black font-bold">Command</TableHead>
                      <TableHead className="w-1/2 bg-gray-100 text-black font-bold">Description</TableHead>
                      <TableHead className="w-1/6 bg-gray-100 text-black font-bold">Action</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {group.commands.map((cmd, cmdIndex) => (
                      <TableRow key={cmdIndex} className="border-t border-gray-200">
                        <TableCell className="font-mono text-black bg-white">{cmd.command}</TableCell>
                        <TableCell className="text-gray-700 bg-white">{cmd.description}</TableCell>
                        <TableCell className="bg-white">
                          <CopyButton text={cmd.command} />
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </div>
            </div>
          ))}
        </div>
      ) : (
        <div className="space-y-6">
          {commandGroups.map((group, index) => (
            <div key={index} className="mb-6">
              <h2 className="text-xl font-semibold mb-3 text-black">{group.title}</h2>
              <Accordion type="single" collapsible className="border-2 border-gray-200 rounded-md overflow-hidden">
                {group.commands.map((cmd, cmdIndex) => (
                  <AccordionItem
                    key={cmdIndex}
                    value={`item-${index}-${cmdIndex}`}
                    className="border-b border-gray-200"
                  >
                    <AccordionTrigger className="px-4 py-3 hover:bg-gray-50 text-black">
                      <div className="flex items-center">
                        <Terminal className="h-4 w-4 mr-2 text-blue-500" />
                        <span className="font-mono">{cmd.command}</span>
                      </div>
                    </AccordionTrigger>
                    <AccordionContent className="px-4 py-3 bg-gray-50">
                      <div className="space-y-3">
                        <div className="p-3 bg-white border border-gray-200 rounded-md">
                          <pre className="font-mono text-black whitespace-pre-wrap select-text">{cmd.command}</pre>
                        </div>
                        <div className="flex justify-between items-center">
                          <p className="text-gray-700">{cmd.description}</p>
                          <CopyButton text={cmd.command} />
                        </div>
                      </div>
                    </AccordionContent>
                  </AccordionItem>
                ))}
              </Accordion>
            </div>
          ))}
        </div>
      )}

      <div className="mt-10 p-4 bg-blue-50 border-l-4 border-blue-500 rounded-md">
        <h3 className="text-lg font-semibold mb-2 text-black">Update Best Practices</h3>
        <ul className="list-disc pl-5 space-y-2 text-gray-700">
          <li>
            Always run <code className="bg-gray-100 px-1 py-0.5 rounded text-black">apt update</code> before installing
            or upgrading packages
          </li>
          <li>Consider creating a VM snapshot or backup before performing major system upgrades</li>
          <li>
            Replace <code className="bg-gray-100 px-1 py-0.5 rounded text-black">&lt;package&gt;</code> with the actual
            package name
          </li>
          <li>
            Replace <code className="bg-gray-100 px-1 py-0.5 rounded text-black">&lt;keyword&gt;</code> with your search
            term
          </li>
          <li>
            Use <code className="bg-gray-100 px-1 py-0.5 rounded text-black">apt autoremove --purge</code> periodically
            to clean up unused packages and free disk space
          </li>
        </ul>
      </div>
    </div>
  )
}

interface CopyButtonProps {
  text: string
}

function CopyButton({ text }: CopyButtonProps) {
  const [copied, setCopied] = React.useState(false)

  const copyToClipboard = () => {
    navigator.clipboard.writeText(text)
    setCopied(true)
    setTimeout(() => setCopied(false), 2000)
  }

  return (
    <Button
      variant="outline"
      size="sm"
      onClick={copyToClipboard}
      className="flex items-center gap-1 h-8 bg-white text-blue-500 border-blue-200 hover:bg-blue-50 hover:text-blue-600"
    >
      {copied ? (
        <>
          <Check className="h-4 w-4" />
          <span>Copied</span>
        </>
      ) : (
        <>
          <Copy className="h-4 w-4" />
          <span>Copy</span>
        </>
      )}
    </Button>
  )
}
