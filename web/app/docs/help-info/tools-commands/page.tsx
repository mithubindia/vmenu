"use client"

import React, { useState } from "react"
import Link from "next/link"
import { PenToolIcon as Tool, ArrowLeft, Copy, Check, Terminal } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from "@/components/ui/accordion"

export default function SystemCLIToolsPage() {
  const [viewMode, setViewMode] = useState<"table" | "accordion">("table")

  // Group commands by category for better organization
  const commandGroups = [
    {
      title: "System Monitoring",
      commands: [
        { command: "htop", description: "Interactive process viewer with CPU/memory usage" },
        { command: "top", description: "Display Linux processes in real-time" },
        { command: "atop", description: "Advanced system & process monitor" },
        { command: "glances", description: "System monitoring tool with web interface" },
        { command: "nmon", description: "Performance monitoring tool" },
        { command: "iotop", description: "Monitor disk I/O usage by processes" },
        { command: "vmstat 1", description: "Report virtual memory statistics every second" },
      ],
    },
    {
      title: "Network Tools",
      commands: [
        { command: "iftop", description: "Display bandwidth usage on an interface" },
        { command: "nmap <host>", description: "Network exploration and security scanning" },
        { command: "tcpdump -i <interface>", description: "Dump network traffic" },
        { command: "netstat -tuln", description: "Display network connections" },
        { command: "ss -tuln", description: "Another utility to investigate sockets" },
        { command: "mtr <host>", description: "Network diagnostic tool combining ping and traceroute" },
        { command: "iperf3 -s", description: "Run iperf server for bandwidth testing" },
      ],
    },
    {
      title: "File and Text Tools",
      commands: [
        { command: "find / -name <filename>", description: "Find files by name" },
        { command: "grep -r 'pattern' /path", description: "Search for pattern in files" },
        { command: "sed -i 's/old/new/g' file", description: "Replace text in files" },
        { command: "awk '{print $1}' file", description: "Text processing tool" },
        { command: "tail -f /var/log/syslog", description: "Follow log file in real-time" },
        { command: "less /var/log/messages", description: "View file with pagination" },
        { command: "journalctl -f", description: "Follow systemd journal logs" },
      ],
    },
    {
      title: "Performance Analysis",
      commands: [
        { command: "iostat -x 1", description: "Report CPU and I/O statistics" },
        { command: "mpstat -P ALL 1", description: "Report CPU utilization" },
        { command: "perf top", description: "System profiling tool" },
        { command: "strace <command>", description: "Trace system calls and signals" },
        { command: "lsof", description: "List open files" },
        { command: "pstree", description: "Display process tree" },
        { command: "slabtop", description: "Display kernel slab cache information" },
      ],
    },
    {
      title: "Security Tools",
      commands: [
        { command: "fail2ban-client status", description: "Show fail2ban status" },
        { command: "chage -l <username>", description: "Show password expiry information" },
        { command: "lastlog", description: "Show last login of all users" },
        { command: "last", description: "Show listing of last logged in users" },
        { command: "w", description: "Show who is logged on and what they are doing" },
        { command: "lynis audit system", description: "Security auditing tool" },
        { command: "openssl s_client -connect host:port", description: "Test SSL/TLS connections" },
      ],
    },
    {
      title: "Remote Administration",
      commands: [
        { command: "ssh <user>@<host>", description: "Secure shell connection" },
        { command: "scp <file> <user>@<host>:<path>", description: "Secure copy files" },
        { command: "rsync -avz <src> <dest>", description: "Synchronize files/folders" },
        { command: "screen", description: "Terminal multiplexer" },
        { command: "tmux", description: "Terminal multiplexer alternative" },
        { command: "ssh-keygen -t rsa -b 4096", description: "Generate SSH key pair" },
        { command: "ssh-copy-id <user>@<host>", description: "Copy SSH key to server" },
      ],
    },
    {
      title: "System Configuration",
      commands: [
        { command: "systemctl status <service>", description: "Check service status" },
        { command: "journalctl -u <service>", description: "View service logs" },
        { command: "timedatectl", description: "Control system time and date" },
        { command: "hostnamectl", description: "Control system hostname" },
        { command: "localectl", description: "Control system locale and keyboard" },
        { command: "update-alternatives --config <name>", description: "Configure system alternatives" },
        { command: "dpkg-reconfigure <package>", description: "Reconfigure an installed package" },
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
          <Tool className="h-8 w-8 mr-2 text-blue-500" />
          <h1 className="text-3xl font-bold text-black">System CLI Tools</h1>
        </div>

        <div className="space-y-4 mb-6">
          <p className="text-lg">
            This section provides a collection of useful command-line tools for system administration in Virtuliservmenu VE.
            These tools help you monitor system performance, troubleshoot issues, manage files, analyze network traffic,
            and perform various administrative tasks.
          </p>

          <div className="p-4 bg-blue-50 border-l-4 border-blue-500 rounded-md">
            <p className="text-gray-700">
              Many of these tools may have been installed during the post-installation process. For information about
              the post-installation setup and basic settings, please refer to the{" "}
              <a
                href="https://macrimi.github.io/vmenu/docs/post-install/basic-settings"
                target="_blank"
                rel="noopener noreferrer"
                className="text-blue-600 hover:text-blue-800 underline"
              >
                Post-Installation Documentation
              </a>
              .
            </p>
          </div>
        </div>

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
        <h3 className="text-lg font-semibold mb-2 text-black">CLI Tool Tips</h3>
        <ul className="list-disc pl-5 space-y-2 text-gray-700">
          <li>
            Replace <code className="bg-gray-100 px-1 py-0.5 rounded text-black">&lt;host&gt;</code> with a hostname or
            IP address
          </li>
          <li>
            Replace <code className="bg-gray-100 px-1 py-0.5 rounded text-black">&lt;interface&gt;</code> with your
            network interface (e.g., eth0)
          </li>
          <li>
            Replace <code className="bg-gray-100 px-1 py-0.5 rounded text-black">&lt;filename&gt;</code>,{" "}
            <code className="bg-gray-100 px-1 py-0.5 rounded text-black">&lt;service&gt;</code>, etc. with appropriate
            values
          </li>
          <li>
            Many tools have additional options. Use{" "}
            <code className="bg-gray-100 px-1 py-0.5 rounded text-black">man &lt;command&gt;</code> or{" "}
            <code className="bg-gray-100 px-1 py-0.5 rounded text-black">&lt;command&gt; --help</code> to see all
            available options
          </li>
          <li>
            <strong>Installation:</strong> If a tool is not available, you can install it using{" "}
            <code className="bg-gray-100 px-1 py-0.5 rounded text-black">apt install &lt;package&gt;</code>. Most of
            these tools may have been installed during the post-installation process.
          </li>
          <li>
            For tools that continuously update (like top, htop), press <kbd>q</kbd> to quit
          </li>
          <li>
            For screen and tmux sessions, use <kbd>Ctrl</kbd>+<kbd>a</kbd> or <kbd>Ctrl</kbd>+<kbd>b</kbd> as the prefix
            key followed by other commands
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
