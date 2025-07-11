"use client"

import React, { useState } from "react"
import Link from "next/link"
import { HardDrive, ArrowLeft, Copy, Check, Terminal } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from "@/components/ui/accordion"

export default function StorageCommandsPage() {
  const [viewMode, setViewMode] = useState<"table" | "accordion">("table")

  // Group commands by category for better organization
  const commandGroups = [
    {
      title: "Disk Information",
      commands: [
        { command: "lsblk", description: "List block devices and partitions" },
        { command: "fdisk -l", description: "List disks with detailed info" },
        { command: "blkid", description: "Show UUID and filesystem type of block devices" },
        { command: "ls -lh /dev/disk/by-id/", description: "List disk persistent identifiers" },
        { command: "parted -l", description: "Detailed partition layout with GPT info" },
      ],
    },
    {
      title: "Storage Usage",
      commands: [
        { command: "df -h", description: "Show disk usage by mount point" },
        { command: "du -sh /path", description: "Show size of a directory" },
        { command: "mount | grep ^/dev", description: "Show mounted storage devices" },
        { command: "cat /proc/mounts", description: "Show all active mounts from the kernel" },
      ],
    },
    {
      title: "LVM Management",
      commands: [
        { command: "pvdisplay", description: "Display physical volumes (LVM)" },
        { command: "vgdisplay", description: "Display volume groups (LVM)" },
        { command: "lvdisplay", description: "Display logical volumes (LVM)" },
        { command: "pvs", description: "Concise output of physical volumes" },
        { command: "vgs", description: "Concise output of volume groups" },
        { command: "lvs", description: "Concise output of logical volumes" },
      ],
    },
    {
      title: "Virtuliservmenu Storage",
      commands: [
        { command: "cat /etc/pve/storage.cfg", description: "Show Virtuliservmenu storage configuration" },
        { command: "pvesm status", description: "Show status of all storage pools" },
        { command: "pvesm list", description: "List all available storage" },
        { command: "pvesm list <storage>", description: "List content of specific storage" },
        { command: "pvesm scan <storage>", description: "Scan storage for new content" },
      ],
    },
    {
      title: "Disk Actions",
      commands: [
        { command: "qm importdisk <vmid> <image_path> <storage>", description: "Attach disk image to VM" },
        { command: "qm set <vmid> -<bus><index> <disk_path>", description: "Assign physical disk to VM (passthrough mode)" },
        { command: "qemu-img convert -O <format> <input> <output>", description: "Convert disk image format)" },
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
          <HardDrive className="h-8 w-8 mr-2 text-blue-500" />
          <h1 className="text-3xl font-bold text-black">Storage and Disks Commands</h1>
        </div>

        <p className="text-lg mb-6">
          This section provides commands for managing and monitoring storage devices and disk partitions in Virtuliservmenu VE.
          Learn how to list disks, check storage usage, manage LVM volumes, and configure Virtuliservmenu storage.
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
        <h3 className="text-lg font-semibold mb-2 text-black">Usage Tips</h3>
        <ul className="list-disc pl-5 space-y-2 text-gray-700">
          <li>
            Use <code className="bg-gray-100 px-1 py-0.5 rounded text-black">lsblk</code> for a quick overview of all
            block devices
          </li>
          <li>
            For detailed partition information,{" "}
            <code className="bg-gray-100 px-1 py-0.5 rounded text-black">fdisk -l</code> provides comprehensive output
          </li>
          <li>
            Replace <code className="bg-gray-100 px-1 py-0.5 rounded text-black">&lt;storage&gt;</code> with your
            storage name when using pvesm commands
          </li>
          <li>
            LVM commands (pvs, vgs, lvs) provide more concise output than their display counterparts (pvdisplay,
            vgdisplay, lvdisplay)
          </li>
          <li>
            When using <code className="bg-gray-100 px-1 py-0.5 rounded text-black">du -sh /path</code>, replace{" "}
            <code className="bg-gray-100 px-1 py-0.5 rounded text-black">/path</code> with the directory you want to
            check
          </li>
          <li>
            Replace placeholders like <code className="bg-gray-100 px-1 py-0.5 rounded text-black">&lt;vmid&gt;</code>,{" "}
            <code className="bg-gray-100 px-1 py-0.5 rounded text-black">&lt;bus&gt;&lt;index&gt;</code>,{" "}
            <code className="bg-gray-100 px-1 py-0.5 rounded text-black">&lt;disk&gt;</code>,{" "}
            <code className="bg-gray-100 px-1 py-0.5 rounded text-black">&lt;format&gt;</code>,{" "}
            <code className="bg-gray-100 px-1 py-0.5 rounded text-black">&lt;input&gt;</code> and{" "}
            <code className="bg-gray-100 px-1 py-0.5 rounded text-black">&lt;output&gt;</code> with the actual values you
            intend to use.
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
