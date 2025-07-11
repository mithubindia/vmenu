"use client"

import React, { useState } from "react"
import Link from "next/link"
import { Database, ArrowLeft, Copy, Check, Terminal } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from "@/components/ui/accordion"

export default function ZFSManagementPage() {
  const [viewMode, setViewMode] = useState<"table" | "accordion">("table")

  // Group commands by category for better organization
  const commandGroups = [
    {
      title: "Pool Information",
      commands: [
        { command: "zpool list", description: "List all ZFS pools" },
        { command: "zpool status", description: "Show detailed pool status and health" },
        { command: "zpool status -v", description: "Show verbose pool status with errors" },
        { command: "zpool history", description: "Show command history for all pools" },
        { command: "zpool history <pool>", description: "Show command history for specific pool" },
        { command: "zpool get all <pool>", description: "Show all properties of a pool" },
      ],
    },
    {
      title: "Dataset Management",
      commands: [
        { command: "zfs list", description: "List all ZFS datasets" },
        { command: "zfs list -r <pool>", description: "List all datasets in a pool recursively" },
        { command: "zfs create <pool>/<dataset>", description: "Create a new dataset" },
        { command: "zfs destroy <pool>/<dataset>", description: "Destroy a dataset" },
        { command: "zfs rename <pool>/<dataset> <pool>/<new-name>", description: "Rename a dataset" },
        { command: "zfs get all <pool>/<dataset>", description: "Show all properties of a dataset" },
        { command: "zfs set compression=on <pool>/<dataset>", description: "Enable compression on a dataset" },
      ],
    },
    {
      title: "Snapshot Management",
      commands: [
        { command: "zfs list -t snapshot", description: "List all snapshots" },
        { command: "zfs list -t snapshot -r <pool>", description: "List all snapshots in a pool" },
        { command: "zfs snapshot <pool>/<dataset>@<snapshot-name>", description: "Create a snapshot" },
        { command: "zfs destroy <pool>/<dataset>@<snapshot-name>", description: "Delete a snapshot" },
        { command: "zfs rollback <pool>/<dataset>@<snapshot-name>", description: "Rollback to a snapshot" },
        { command: "zfs hold <tag> <pool>/<dataset>@<snapshot-name>", description: "Place a hold on a snapshot" },
        { command: "zfs release <tag> <pool>/<dataset>@<snapshot-name>", description: "Release a hold on a snapshot" },
      ],
    },
    {
      title: "Clone and Send/Receive",
      commands: [
        {
          command: "zfs clone <pool>/<dataset>@<snapshot> <pool>/<clone-name>",
          description: "Create a clone from a snapshot",
        },
        { command: "zfs send <pool>/<dataset>@<snapshot> > backup.zfs", description: "Send a snapshot to a file" },
        { command: "zfs receive <pool>/<dataset> < backup.zfs", description: "Receive a snapshot from a file" },
        {
          command: "zfs send -i <pool>/<dataset>@<snap1> <pool>/<dataset>@<snap2> > incr.zfs",
          description: "Send incremental snapshot",
        },
        {
          command: "zfs send -R <pool>/<dataset>@<snapshot> > full-recursive.zfs",
          description: "Send recursive snapshot",
        },
      ],
    },
    {
      title: "Maintenance and Repair",
      commands: [
        { command: "zpool scrub <pool>", description: "Start a scrub operation on a pool" },
        { command: "zpool scrub -s <pool>", description: "Stop a running scrub" },
        { command: "zpool clear <pool>", description: "Clear error counts in a pool" },
        { command: "zpool clear <pool> <device>", description: "Clear errors on a specific device" },
        { command: "zpool replace <pool> <old-device> <new-device>", description: "Replace a failed device" },
        { command: "zpool offline <pool> <device>", description: "Take a device offline" },
        { command: "zpool online <pool> <device>", description: "Bring a device online" },
      ],
    },
    {
      title: "Performance and Monitoring",
      commands: [
        { command: "zpool iostat", description: "Show I/O statistics for pools" },
        { command: "zpool iostat -v", description: "Show detailed I/O statistics" },
        { command: "zpool iostat 5", description: "Show I/O statistics every 5 seconds" },
        { command: "arc_summary", description: "Show ARC statistics (if installed)" },
        { command: "zfs get compressratio <pool>/<dataset>", description: "Show compression ratio" },
        { command: "zfs get used,available,referenced <pool>/<dataset>", description: "Show space usage" },
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
          <Database className="h-8 w-8 mr-2 text-blue-500" />
          <h1 className="text-3xl font-bold text-black">ZFS Management Commands</h1>
        </div>

        <p className="text-lg mb-6">
          This section provides commands for managing ZFS file systems in Virtuliservmenu VE. Learn how to create and manage
          pools, datasets, snapshots, and perform maintenance operations on your ZFS storage.
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
        <h3 className="text-lg font-semibold mb-2 text-black">ZFS Best Practices</h3>
        <ul className="list-disc pl-5 space-y-2 text-gray-700">
          <li>
            Replace <code className="bg-gray-100 px-1 py-0.5 rounded text-black">&lt;pool&gt;</code> with your ZFS pool
            name
          </li>
          <li>
            Replace <code className="bg-gray-100 px-1 py-0.5 rounded text-black">&lt;dataset&gt;</code> with your
            dataset name
          </li>
          <li>
            Replace <code className="bg-gray-100 px-1 py-0.5 rounded text-black">&lt;snapshot-name&gt;</code> with a
            descriptive name, often including a timestamp (e.g., daily-2023-05-01)
          </li>
          <li>Run regular scrubs to maintain data integrity (weekly or monthly)</li>
          <li>
            Keep at least 10-15% of pool space free for optimal performance (ZFS performance degrades significantly when
            pools are over 80% full)
          </li>
          <li>
            Use meaningful snapshot names and consider implementing an automated snapshot rotation policy for important
            datasets
          </li>
          <li>
            When replacing devices, always use{" "}
            <code className="bg-gray-100 px-1 py-0.5 rounded text-black">zpool replace</code> rather than removing and
            adding to preserve data redundancy
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
