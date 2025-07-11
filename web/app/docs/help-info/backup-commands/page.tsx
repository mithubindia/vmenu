"use client"

import React, { useState } from "react"
import Link from "next/link"
import { Archive, ArrowLeft, Copy, Check, Terminal } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from "@/components/ui/accordion"

export default function BackupRestorePage() {
  const [viewMode, setViewMode] = useState<"table" | "accordion">("table")

  // Group commands by category for better organization
  const commandGroups = [
    {
      title: "VM Backup",
      commands: [
        { command: "vzdump <vmid>", description: "Create a backup of a specific VM/CT" },
        { command: "vzdump <vmid> --storage <storage>", description: "Backup VM to specific storage" },
        { command: "vzdump <vmid> --mode snapshot", description: "Create snapshot backup (for VMs)" },
        { command: "vzdump <vmid> --mode suspend", description: "Suspend VM during backup" },
        { command: "vzdump <vmid> --mode stop", description: "Stop VM during backup" },
        { command: "vzdump --all", description: "Backup all VMs and containers" },
        { command: "vzdump --exclude <vmid1>,<vmid2>", description: "Backup all except specified VMs" },
      ],
    },
    {
      title: "Backup Options",
      commands: [
        { command: "vzdump <vmid> --compress zstd", description: "Use zstd compression for backup" },
        { command: "vzdump <vmid> --pigz <threads>", description: "Use pigz with multiple threads" },
        { command: "vzdump <vmid> --notes <text>", description: "Add notes to backup" },
        { command: "vzdump <vmid> --mailto <email>", description: "Send notification email" },
        { command: "vzdump <vmid> --maxfiles <n>", description: "Keep only n backups per VM" },
        { command: "vzdump <vmid> --stdexcludes 0", description: "Don't exclude temporary files" },
        { command: "vzdump <vmid> --quiet 1", description: "Suppress output messages" },
      ],
    },
    {
      title: "Restore Backups",
      commands: [
        { command: "qmrestore <backup-file> <vmid>", description: "Restore VM from backup" },
        { command: "qmrestore <backup-file> <vmid> --storage <storage>", description: "Restore to specific storage" },
        { command: "qmrestore <backup-file> <vmid> --unique", description: "Create a VM with unique ID" },
        { command: "pct restore <vmid> <backup-file>", description: "Restore container from backup" },
        {
          command: "pct restore <vmid> <backup-file> --storage <storage>",
          description: "Restore container to specific storage",
        },
        { command: "pct restore <vmid> <backup-file> --rootfs <storage>", description: "Restore to specific rootfs" },
        { command: "pct restore <vmid> <backup-file> --unprivileged 1", description: "Restore as unprivileged CT" },
      ],
    },
    {
      title: "Backup Management",
      commands: [
        { command: "ls -la /var/lib/vz/dump/", description: "List backups in default location" },
        { command: 'find /var/lib/vz/dump/ -name "*.vma*"', description: "Find VM backups" },
        { command: 'find /var/lib/vz/dump/ -name "*.tar*"', description: "Find container backups" },
        { command: "pvesm list <storage>", description: "List backups in specific storage" },
        { command: "rm /var/lib/vz/dump/<backup-file>", description: "Delete a backup file" },
        { command: "cat /etc/vzdump.conf", description: "Show backup configuration" },
      ],
    },
    {
      title: "Scheduled Backups",
      commands: [
        { command: "cat /etc/cron.d/vzdump", description: "Show backup schedule" },
        { command: "nano /etc/vzdump.conf", description: "Edit backup configuration" },
        { command: "systemctl list-timers", description: "List all scheduled tasks" },
        { command: "systemctl status cron", description: "Check cron service status" },
        { command: "grep vzdump /var/log/syslog", description: "Check backup logs in syslog" },
        { command: "tail -f /var/log/vzdump.log", description: "Monitor backup log in real-time" },
      ],
    },
    {
      title: "Advanced Operations",
      commands: [
        { command: "qmrestore <backup> <vmid> --force", description: "Force restore, overwriting existing VM" },
        { command: "vzdump <vmid> --dumpdir <directory>", description: "Specify custom backup directory" },
        { command: "vzdump <vmid> --script <script>", description: "Run hook script during backup" },
        { command: "vzdump <vmid> --exclude-path <path>", description: "Exclude specific paths from backup" },
        { command: "vzdump <vmid> --ionice <priority>", description: "Set I/O priority for backup process" },
        { command: "vzdump <vmid> --lockwait <minutes>", description: "Wait for lock" },
        { command: "qm importdisk <vmid> <backup> <storage>", description: "Import disk from backup" },
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
          <Archive className="h-8 w-8 mr-2 text-blue-500" />
          <h1 className="text-3xl font-bold text-black">Backup and Restore Commands</h1>
        </div>

        <p className="text-lg mb-6">
          This section provides commands for backing up and restoring virtual machines and containers in Virtuliser VE.
          Learn how to create backups, restore from backups, manage backup storage, and schedule automated backups.
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
        <h3 className="text-lg font-semibold mb-2 text-black">Backup Best Practices</h3>
        <ul className="list-disc pl-5 space-y-2 text-gray-700">
          <li>
            Replace <code className="bg-gray-100 px-1 py-0.5 rounded text-black">&lt;vmid&gt;</code> with your VM or
            container ID
          </li>
          <li>
            Replace <code className="bg-gray-100 px-1 py-0.5 rounded text-black">&lt;storage&gt;</code> with your
            storage name
          </li>
          <li>
            Replace <code className="bg-gray-100 px-1 py-0.5 rounded text-black">&lt;backup-file&gt;</code> with the
            path to your backup file
          </li>
          <li>Schedule regular backups during off-peak hours to minimize impact on production workloads</li>
          <li>Store backups on a separate storage device or location for better disaster recovery protection</li>
          <li>Test your backups regularly by performing test restores to ensure they are working correctly</li>
          <li>
            Use <code className="bg-gray-100 px-1 py-0.5 rounded text-black">--maxfiles</code> to implement backup
            rotation and prevent storage from filling up
          </li>
          <li>
            Consider using <code className="bg-gray-100 px-1 py-0.5 rounded text-black">--compress zstd</code> for
            better compression ratio and performance
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
