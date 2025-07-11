"use client"

import React, { useState } from "react"
import Link from "next/link"
import { Cpu, ArrowLeft, Copy, Check, Terminal } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from "@/components/ui/accordion"

export default function GPUPassthroughPage() {
  const [viewMode, setViewMode] = useState<"table" | "accordion">("table")

  // Group commands by category for better organization
  const commandGroups = [
    {
      title: "Device Identification",
      commands: [
        { command: "lspci -nn | grep -i nvidia", description: "List NVIDIA PCI devices" },
        { command: "lspci -nn | grep -i vga", description: "List all VGA compatible devices" },
        { command: "lspci -nn | grep -i amd", description: "List AMD PCI devices" },
        { command: "lspci -nnk | grep -A3 VGA", description: "List VGA devices with kernel drivers" },
        { command: "lspci -v -s <PCI_ID>", description: "Show detailed info for specific PCI device" },
      ],
    },
    {
      title: "VFIO Configuration",
      commands: [
        { command: "dmesg | grep -i vfio", description: "Check VFIO module messages" },
        { command: "cat /etc/modprobe.d/vfio.conf", description: "Review VFIO passthrough configuration" },
        { command: "ls -la /etc/modprobe.d/", description: "List all modprobe configuration files" },
        { command: "cat /etc/modules", description: "Show modules loaded at boot time" },
        { command: "lsmod | grep vfio", description: "Check if VFIO modules are loaded" },
      ],
    },
    {
      title: "IOMMU Configuration",
      commands: [
        { command: "cat /etc/default/grub", description: "Review GRUB options for IOMMU" },
        { command: "update-grub", description: "Apply GRUB changes" },
        { command: "dmesg | grep -i iommu", description: "Check IOMMU messages in kernel log" },
        { command: "dmesg | grep -e DMAR -e IOMMU", description: "Check DMAR and IOMMU messages" },
        { command: "find /sys/kernel/iommu_groups/ -type l | sort -V", description: "List IOMMU groups" },
      ],
    },
    {
      title: "System Updates",
      commands: [
        { command: "update-initramfs -u", description: "Apply initramfs changes (VFIO)" },
        { command: "update-initramfs -u -k all", description: "Update initramfs for all kernels" },
        { command: "cat /proc/cmdline", description: "Show current kernel boot parameters" },
      ],
    },
    {
      title: "VM Configuration",
      commands: [
        { command: "qm config <vmid> | grep hostpci", description: "Show PCI passthrough config for a VM" },
        {
          command: "qm set <vmid> -hostpci0 <PCI_ID>,pcie=1,x-vga=1",
          description: "Add GPU passthrough to a VM",
        },
        { command: "cat /etc/pve/qemu-server/<vmid>.conf", description: "View VM configuration file" },
        {
          command: "qm set <vmid> -machine q35",
          description: "Set VM to use Q35 chipset (recommended for passthrough)",
        },
        {
          command: "qm set <vmid> -bios ovmf",
          description: "Set VM to use UEFI/OVMF (required for GPU passthrough)",
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
          <h1 className="text-3xl font-bold text-black">GPU Passthrough Commands</h1>
        </div>

        <p className="text-lg mb-6">
          This section provides commands for configuring and managing GPU passthrough in Virtuliser VE. Learn how to
          identify GPU devices, configure VFIO and IOMMU, and set up VMs for GPU passthrough.
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
        <h3 className="text-lg font-semibold mb-2 text-black">GPU Passthrough Tips</h3>
        <ul className="list-disc pl-5 space-y-2 text-gray-700">
          <li>
            Replace <code className="bg-gray-100 px-1 py-0.5 rounded text-black">&lt;PCI_ID&gt;</code> with your GPU's
            PCI ID (e.g., 01:00.0)
          </li>
          <li>
            Replace <code className="bg-gray-100 px-1 py-0.5 rounded text-black">&lt;vmid&gt;</code> with your VM's ID
          </li>
          <li>
            For IOMMU to work, you need to enable it in BIOS/UEFI (look for settings like "VT-d", "AMD-Vi", or "IOMMU")
          </li>
          <li>
            Common GRUB parameters for IOMMU:
            <ul className="list-disc pl-5 mt-1">
              <li>
                For Intel: <code className="bg-gray-100 px-1 py-0.5 rounded text-black">intel_iommu=on</code>
              </li>
              <li>
                For AMD: <code className="bg-gray-100 px-1 py-0.5 rounded text-black">amd_iommu=on</code>
              </li>
              <li>
                Additional options:{" "}
                <code className="bg-gray-100 px-1 py-0.5 rounded text-black">
                  iommu=pt video=efifb:off video=vesa:off
                </code>
              </li>
            </ul>
          </li>
          <li>
            After making changes to GRUB or modprobe configurations, run{" "}
            <code className="bg-gray-100 px-1 py-0.5 rounded text-black">update-grub</code> and{" "}
            <code className="bg-gray-100 px-1 py-0.5 rounded text-black">update-initramfs -u</code>, then reboot
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
