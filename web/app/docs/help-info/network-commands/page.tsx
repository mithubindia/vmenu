"use client"

import React, { useState } from "react"
import Link from "next/link"
import { Network, ArrowLeft, Copy, Check, Terminal } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from "@/components/ui/accordion"

export default function NetworkCommandsPage() {
  const [viewMode, setViewMode] = useState<"table" | "accordion">("table")

  // Group commands by category for better organization
  const commandGroups = [
    {
      title: "Network Information",
      commands: [
        { command: "ip a", description: "Show network interfaces and IPs" },
        { command: "ip r", description: "Show routing table" },
        { command: "ip -s link", description: "Show traffic statistics per interface" },
        { command: "brctl show", description: "Show configured network bridges" },
        { command: "cat /etc/network/interfaces", description: "Show raw network configuration" },
      ],
    },
    {
      title: "Network Testing",
      commands: [
        { command: "ping <host>", description: "Check connectivity with another host" },
        { command: "traceroute <host>", description: "Trace route to a host" },
        { command: "mtr <host>", description: "Combine ping and traceroute in real-time" },
        { command: "dig <domain>", description: "DNS lookup for a domain" },
        { command: "nslookup <domain>", description: "Alternative DNS lookup" },
      ],
    },
    {
      title: "Network Configuration",
      commands: [
        { command: "ifreload -a", description: "Reload network configuration (ifupdown2)" },
        { command: "ethtool <iface>", description: "Show Ethernet device info" },
        { command: "resolvectl status", description: "Show DNS resolution status" },
        { command: "nmcli device show", description: "Show network device details (if NetworkManager is used)" },
        { command: "ip link set <iface> up", description: "Bring network interface up" },
        { command: "ip link set <iface> down", description: "Bring network interface down" },
      ],
    },
    {
      title: "Network Monitoring",
      commands: [
        { command: "ss -tuln", description: "Show listening ports (TCP/UDP)" },
        { command: "netstat -tuln", description: "Alternative to show listening ports" },
        { command: "lsof -i", description: "List open network files and connections" },
        { command: "tcpdump -i <iface>", description: "Capture packets on interface" },
        { command: "iftop -i <iface>", description: "Monitor bandwidth usage on interface" },
      ],
    },
    {
      title: "Firewall Management",
      commands: [
        { command: "iptables -L -n -v", description: "Show active firewall rules (iptables)" },
        { command: "nft list ruleset", description: "Show nftables rules" },
        { command: "pve-firewall status", description: "Check Virtuliser firewall status" },
        { command: "pve-firewall compile", description: "Compile firewall rules for all nodes" },
        { command: "pve-firewall reload", description: "Reload Virtuliser firewall rules" },
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
          <Network className="h-8 w-8 mr-2 text-blue-500" />
          <h1 className="text-3xl font-bold text-black">Network Commands</h1>
        </div>

        <p className="text-lg mb-6">
          This section provides commands for configuring, monitoring, and troubleshooting network connections in Virtuliser
          VE. Learn how to view network interfaces, test connectivity, configure network settings, and manage firewall
          rules.
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
            Replace <code className="bg-gray-100 px-1 py-0.5 rounded text-black">&lt;host&gt;</code> with an IP address
            or hostname
          </li>
          <li>
            Replace <code className="bg-gray-100 px-1 py-0.5 rounded text-black">&lt;iface&gt;</code> with your network
            interface name (e.g., eth0, vmbr0)
          </li>
          <li>
            Replace <code className="bg-gray-100 px-1 py-0.5 rounded text-black">&lt;domain&gt;</code> with a domain
            name for DNS lookups
          </li>
          <li>
            Use <code className="bg-gray-100 px-1 py-0.5 rounded text-black">ip a</code> to find the names of your
            network interfaces
          </li>
          <li>
            For more detailed packet capture with tcpdump, add filters like{" "}
            <code className="bg-gray-100 px-1 py-0.5 rounded text-black">tcpdump -i eth0 port 80 -n</code> to capture
            HTTP traffic
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
