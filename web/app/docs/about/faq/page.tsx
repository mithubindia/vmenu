import type { Metadata } from "next";
import { HelpCircle } from "lucide-react";
import Link from "next/link";

export const metadata: Metadata = {
  title: "ProxMenux FAQ – Frequently Asked Questions",
  description: "Frequently Asked Questions about ProxMenux, including installation, updates, compatibility, and security.",
  openGraph: {
    title: "ProxMenux FAQ – Frequently Asked Questions",
    description: "Frequently Asked Questions about ProxMenux, including installation, updates, compatibility, and security.",
    type: "article",
    url: "https://macrimi.github.io/ProxMenux/docs/faq",
    images: [
      {
        url: "https://macrimi.github.io/ProxMenux/faq-image.png",
        width: 1200,
        height: 630,
        alt: "ProxMenux FAQ",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "ProxMenux FAQ – Frequently Asked Questions",
    description: "Frequently Asked Questions about ProxMenux, including installation, updates, compatibility, and security.",
    images: ["https://macrimi.github.io/ProxMenux/faq-image.png"],
  },
};

function StepNumber({ number }: { number: number }) {
  return (
    <div className="inline-flex items-center justify-center w-8 h-8 mr-3 text-white bg-blue-500 rounded-full">
      <span className="text-sm font-bold">{number}</span>
    </div>
  );
}

export default function FaqPage() {
  return (
    <div className="container mx-auto px-4 py-8">
      <div className="flex items-center mb-6">
        <HelpCircle className="h-8 w-8 mr-2 text-blue-500" />
        <h1 className="text-3xl font-bold">Frequently Asked Questions (FAQ)</h1>
      </div>

        {/* 1️⃣ What is ProxMenux? */}
      <h3 className="text-xl font-semibold mt-16 mb-4 flex items-center">
        <StepNumber number={1} />
        What is ProxMenux, and what is it used for?
      </h3>
      <p className="mb-4">
        <strong>ProxMenux</strong> is an interactive menu-driven tool designed to make <strong>Proxmox VE</strong> more accessible  
        to all users, regardless of their technical experience. It simplifies command execution, allowing users to perform  
        actions on their system without requiring advanced Linux knowledge.
      </p>
      <p className="mb-4">
        For less experienced users, <strong>ProxMenux</strong> provides an intuitive way to run commands through a structured  
        menu interface, reducing the need for manual terminal input.
      </p>
      <p className="mb-4">
        Proxmox VE is widely used for:
      </p>
      <ul className="list-disc list-inside mb-4 ml-4">
        <li>Enterprise-grade virtualization</li>
        <li>HomeLab and personal cloud solutions</li>
        <li>Multimedia servers, automation, and more</li>
      </ul>

      {/* 2️⃣ Installation */}
      <h3 className="text-xl font-semibold mt-16 mb-4 flex items-center">
        <StepNumber number={2} />
        How do I install ProxMenux?
      </h3>
      <p className="mb-4">
        Follow the instructions in the{" "}
        <Link href="https://macrimi.github.io/ProxMenux/docs/installation" className="text-blue-500 hover:underline">
          Installation Guide
        </Link>. You can install ProxMenux by running:
      </p>
      <pre className="bg-gray-100 p-4 rounded-md overflow-x-auto text-sm">
        <code>
          bash -c "$(wget -qLO - https://raw.githubusercontent.com/MacRimi/ProxMenux/main/install_proxmenux.sh)"
        </code>
      </pre>
      <p className="mt-4">Once installed, launch it with:</p>
      <pre className="bg-gray-100 p-4 rounded-md overflow-x-auto text-sm">
        <code>menu</code>
      </pre>

      {/* 3️⃣ Compatibility */}
      <h2 className="text-2xl font-semibold mt-8 mb-4">3️⃣ Is ProxMenux compatible with all Proxmox versions?</h2>
      <p className="mb-4">
        No, <strong>ProxMenux is only compatible with Proxmox VE 8 and later versions.</strong>
      </p>

      {/* 4️⃣ Customization */}
      <h2 className="text-2xl font-semibold mt-8 mb-4">4️⃣ Can I customize ProxMenux?</h2>
      <p className="mb-4">
        The core scripts cannot be modified directly as they are hosted on GitHub, but you can personalize 
        the <strong>console logo</strong> using the <strong>FastFetch</strong> tool in the <strong>Post-Install options</strong>.
      </p>

      {/* 5️⃣ Updates */}
      <h2 className="text-2xl font-semibold mt-8 mb-4">5️⃣ How do I update ProxMenux?</h2>
      <p className="mb-4">
        When a new version is available, ProxMenux will automatically detect it upon launch and ask 
        if you want to update. The update process will replace utility files and configurations.
      </p>

      {/* 6️⃣ Reporting Issues */}
      <h2 className="text-2xl font-semibold mt-8 mb-4">6️⃣ Where can I report issues?</h2>
      <p className="mb-4">
        If you encounter bugs or errors, report them in the{" "}
        <Link href="https://github.com/MacRimi/ProxMenux/issues" className="text-blue-500 hover:underline">Issues section</Link>.
      </p>

      {/* 7️⃣ Contributing */}
      <h2 className="text-2xl font-semibold mt-8 mb-4">7️⃣ Can I contribute to ProxMenux?</h2>
      <p className="mb-4">
        Yes! ProxMenux is an open-source project, and contributions are welcome.  
        You can share ideas or discuss improvements in the{" "}
        <Link href="https://github.com/MacRimi/ProxMenux/discussions" className="text-blue-500 hover:underline">Discussions section</Link>.  
        Make sure to check the{" "}
        <Link href="https://github.com/MacRimi/ProxMenux/blob/main/CODE_OF_CONDUCT.md" className="text-blue-500 hover:underline">Code of Conduct & Best Practices</Link>.
      </p>

      {/* 8️⃣ Modifying System Files */}
      <h2 className="text-2xl font-semibold mt-8 mb-4">8️⃣ Does ProxMenux modify critical system files?</h2>
      <p className="mb-4">
        No, <strong>ProxMenux does not modify critical Proxmox system files.</strong>  
        It installs dependencies (whiptail, curl, jq, Python3), sets up a virtual environment for translations, and downloads its scripts into 
        <code className="bg-gray-200 px-1 rounded">/usr/local/share/proxmenux/ and the executable menu into /usr/local/bin/</code>.  
        It does not interfere with Proxmox's core operations.
      </p>

      {/* 9️⃣ Production Use */}
      <h2 className="text-2xl font-semibold mt-8 mb-4">9️⃣ Is it safe to use ProxMenux in production?</h2>
      <p className="mb-4">
        Yes, ProxMenux is <strong>safe for production</strong>.  
        Since it does not modify core Proxmox files, it can be used in production environments.  
        However, it is always recommended to test it in a controlled environment first.
      </p>

      {/* 🔟 Uninstallation */}
      <h2 className="text-2xl font-semibold mt-8 mb-4">🔟 How do I uninstall ProxMenux?</h2>
      <p className="mb-4">
        You can uninstall ProxMenux from the **Settings menu** using the **Uninstall ProxMenux** option.  
        Detailed steps can be found in the{" "}
        <Link href="https://macrimi.github.io/ProxMenux/docs/settings/uninstall-proxmenux" className="text-blue-500 hover:underline">
          Uninstall Guide
        </Link>.
      </p>
    </div>
  );
}