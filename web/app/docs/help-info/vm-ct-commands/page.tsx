"use client"

import React, { useState } from "react"
import Link from "next/link"
import { Cpu, ArrowLeft, Copy, Check, Terminal } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from "@/components/ui/accordion"

export default function VMCTCommandsPage() {
  const [viewMode, setViewMode] = useState<"table" | "accordion">("table")

  // Group commands by category for better organization
  const commandGroups = [
    {
      title: "Listing and Information",
      commands: [
        { command: "qm list", description: "List all virtual machines" },
        { command: "pct list", description: "List all LXC containers" },
        { command: "qm config <vmid>", description: "Show VM configuration. Use the correct <vmid>" },
        { command: "pct config <ctid>", description: "Show container configuration. Use the correct <ctid>" },
      ],
    },
    {
      title: "VM Management",
      commands: [
        { command: "qm start <vmid>", description: "Start a virtual machine. Use the correct <vmid>" },
        { command: "qm stop <vmid>", description: "Force stop a virtual machine. Use the correct <vmid>" },
        { command: "qm shutdown <vmid>", description: "Gracefully shutdown a virtual machine" },
        { command: "qm reset <vmid>", description: "Reset a virtual machine (hard reboot)" },
        { command: "qm suspend <vmid>", description: "Suspend a virtual machine" },
        { command: "qm resume <vmid>", description: "Resume a suspended virtual machine" },
        { command: "qm destroy <vmid>", description: "Delete a VM (irreversible). Use the correct <vmid>" },
      ],
    },
    {
      title: "Container Management",
      commands: [
        { command: "pct start <ctid>", description: "Start a container. Use the correct <ctid>" },
        { command: "pct stop <ctid>", description: "Force stop a container. Use the correct <ctid>" },
        { command: "pct shutdown <ctid>", description: "Gracefully shutdown a container" },
        { command: "pct restart <ctid>", description: "Restart a container" },
        { command: "pct destroy <ctid>", description: "Delete a CT (irreversible). Use the correct <ctid>" },
      ],
    },
    {
      title: "Container Operations",
      commands: [
        {
          command: "pct exec <ctid> -- getent passwd | column -t -s :",
          description: "Show CT users in table format",
        },
        {
          command: "pct exec <ctid> -- ps aux --sort=-%mem | head",
          description: "Top memory processes in CT",
        },
        {
          command: "pct enter <ctid>",
          description: "Enter container shell",
        },
        {
          command: "pct push <ctid> <source> <dest>",
          description: "Copy file from host to container",
        },
        {
          command: "pct pull <ctid> <source> <dest>",
          description: "Copy file from container to host",
        },
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
          <Cpu className="h-8 w-8 mr-2 text-blue-500" />
          <h1 className="text-3xl font-bold text-black">VM and CT Management Commands</h1>
        </div>

        <p className="text-lg mb-6">
          This section provides commands for managing virtual machines (VMs) and containers (CTs) in Virtuliservmenu VE. Learn
          how to list, start, stop, configure, and perform other operations on your virtualized environments.
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
        <h3 className="text-lg font-semibold mb-2 text-black">Usage Notes</h3>
        <ul className="list-disc pl-5 space-y-2 text-gray-700">
          <li>
            Replace <code className="bg-gray-100 px-1 py-0.5 rounded text-black">&lt;vmid&gt;</code> with the ID of your
            virtual machine
          </li>
          <li>
            Replace <code className="bg-gray-100 px-1 py-0.5 rounded text-black">&lt;ctid&gt;</code> with the ID of your
            container
          </li>
          <li>
            Use <code className="bg-gray-100 px-1 py-0.5 rounded text-black">qm list</code> or{" "}
            <code className="bg-gray-100 px-1 py-0.5 rounded text-black">pct list</code> to find the IDs of your VMs and
            containers
          </li>
          <li>Be careful with destroy commands as they permanently delete the VM or container</li>
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
