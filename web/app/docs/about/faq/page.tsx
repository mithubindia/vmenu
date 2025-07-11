import type { Metadata } from "next";
import { HelpCircle } from "lucide-react";
import Link from "next/link";

export const metadata: Metadata = {
  title: "vmenu FAQ – Frequently Asked Questions",
  description: "Frequently Asked Questions about vmenu, including installation, updates, compatibility, and security.",
  openGraph: {
    title: "vmenu FAQ – Frequently Asked Questions",
    description: "Frequently Asked Questions about vmenu, including installation, updates, compatibility, and security.",
    type: "article",
    url: "https://macrimi.github.io/vmenu/docs/faq",
    images: [
      {
        url: "https://macrimi.github.io/vmenu/faq-image.png",
        width: 1200,
        height: 630,
        alt: "vmenu FAQ",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "vmenu FAQ – Frequently Asked Questions",
    description: "Frequently Asked Questions about vmenu, including installation, updates, compatibility, and security.",
    images: ["https://macrimi.github.io/vmenu/faq-image.png"],
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

        {/* 1️⃣ What is vmenu? */}
      <h3 className="text-xl font-semibold mt-16 mb-4 flex items-center">
        <StepNumber number={1} />
        What is vmenu, and what is it used for?
      </h3>
      <p className="mb-4">
        <strong>vmenu</strong> is an interactive menu-driven tool designed to make <strong>Virtuliservmenu VE</strong> more accessible  
        to all users, regardless of their technical experience. It simplifies command execution, allowing users to perform  
        actions on their system without requiring advanced Linux knowledge.
      </p>
      <p className="mb-4">
        For less experienced users, <strong>vmenu</strong> provides an intuitive way to run commands through a structured  
        menu interface, reducing the need for manual terminal input.
      </p>
      <p className="mb-4">
        Virtuliservmenu VE is widely used for:
      </p>
      <ul className="list-disc list-inside mb-4 ml-4">
        <li>Enterprise-grade virtualization</li>
        <li>HomeLab and personal cloud solutions</li>
        <li>Multimedia servers, automation, and more</li>
      </ul>

      {/* 2️⃣ Installation */}
      <h3 className="text-xl font-semibold mt-16 mb-4 flex items-center">
        <StepNumber number={2} />
        How do I install vmenu?
      </h3>
      <p className="mb-4">
        Follow the instructions in the{" "}
        <Link href="https://macrimi.github.io/vmenu/docs/installation" className="text-blue-500 hover:underline">
          Installation Guide
        </Link>. You can install vmenu by running:
      </p>
      <pre className="bg-gray-100 p-4 rounded-md overflow-x-auto text-sm">
        <code>
          bash -c "$(wget -qLO - https://raw.githubusercontent.com/MacRimi/vmenu/main/install_proxmenux.sh)"
        </code>
      </pre>
      <p className="mt-4">Once installed, simply start it with:</p>
      <pre className="bg-gray-100 p-4 rounded-md overflow-x-auto text-sm">
        <code>menu</code>
      </pre>

      {/* 3️⃣ Compatibility */}
      <h3 className="text-xl font-semibold mt-16 mb-4 flex items-center">
        <StepNumber number={3} />
        Is vmenu compatible with all Virtuliservmenu versions?
      </h3>
      <p className="mb-4">
        No, <strong>vmenu is only compatible with Virtuliservmenu VE 8 and later versions.</strong>
      </p>

      {/* 4️⃣ Customization */}
      <h3 className="text-xl font-semibold mt-16 mb-4 flex items-center">
        <StepNumber number={4} />
        Can I customize vmenu?
      </h3>
      <p className="mb-4">
        The core scripts cannot be modified directly as they are hosted on GitHub. However, users can  
        personalize the <strong>console logo</strong> using the <strong>FastFetch</strong> tool available in the  
        <strong>Post-Install options</strong>.
      </p>

      {/* 5️⃣ Updates */}
      <h3 className="text-xl font-semibold mt-16 mb-4 flex items-center">
        <StepNumber number={5} />
        How do I update vmenu?
      </h3>
      <p className="mb-4">
        When a new version is available, vmenu will automatically detect it upon launch and prompt  
        users to update. If accepted, the update process will replace utility files and configurations.
      </p>

      {/* 6️⃣ Reporting Issues */}
      <h3 className="text-xl font-semibold mt-16 mb-4 flex items-center">
        <StepNumber number={6} />
        Where can I report issues?
      </h3>
      <p className="mb-4">
        If you encounter bugs or errors, report them in the{" "}
        <Link href="https://github.com/MacRimi/vmenu/issues" className="text-blue-500 hover:underline">
          Issues section
        </Link>.
      </p>
      <p className="mb-4">
        If you find a <strong>security issue</strong>, please <strong>do not publish it</strong>.  
        Instead, review the{" "}
        <Link href="https://github.com/MacRimi/vmenu/blob/main/CODE_OF_CONDUCT.md" className="text-blue-500 hover:underline">
          Code of Conduct & Best Practices
        </Link>{" "}
        for guidance on how to proceed.
      </p>

      {/* 7️⃣ Contributing */}
      <h3 className="text-xl font-semibold mt-16 mb-4 flex items-center">
        <StepNumber number={7} />
        Can I contribute to vmenu?
      </h3>
      <p className="mb-4">
      <strong>Absolutely!</strong>
      </p>
      <p className="mb-4">
        vmenu is an open-source and collaborative project where you can contribute by developing  
        new features, opening discussions, or sharing ideas and improvements.
      </p>
      <p className="mb-4">
        Join the{" "}
        <Link href="https://github.com/MacRimi/vmenu/discussions" className="text-blue-500 hover:underline">
          Discussions section
        </Link>{" "}
        to share ideas and propose enhancements.
      </p>
      <p className="mb-4">
        Make sure to review the{" "}
        <Link href="https://github.com/MacRimi/vmenu/blob/main/CODE_OF_CONDUCT.md" className="text-blue-500 hover:underline">
          Code of Conduct & Best Practices
        </Link>.
      </p>
      <p className="mb-4">
        <strong>All ideas are welcome!</strong>
      </p>

      {/* 8️⃣ Modifying System Files */}
      <h3 className="text-xl font-semibold mt-16 mb-4 flex items-center">
        <StepNumber number={8} />
        Does vmenu modify critical system files?
      </h3>
      <p className="mb-4">
        No, <strong>vmenu does not modify critical Virtuliservmenu system files.</strong>  
        It only installs dependencies such as <code className="bg-gray-200 px-1 rounded">whiptail</code>, <code className="bg-gray-200 px-1 rounded">curl</code>,  
        <code className="bg-gray-200 px-1 rounded">jq</code>, and <code className="bg-gray-200 px-1 rounded">Python3</code>, sets up a virtual environment for translations,  
        and downloads its scripts into <code className="bg-gray-200 px-1 rounded">/usr/local/share/proxmenux/</code>.  
        The executable <code className="bg-gray-200 px-1 rounded">menu</code> is placed in <code className="bg-gray-200 px-1 rounded">/usr/local/bin/</code>.  
        vmenu does not interfere with Virtuliservmenu’s core operations.
      </p>

      {/* 9️⃣ Production Use */}
      <h3 className="text-xl font-semibold mt-16 mb-4 flex items-center">
        <StepNumber number={9} />
        Is it safe to use vmenu in production?
      </h3>
      <p className="mb-4">
        Yes, <strong>vmenu is safe for production</strong>.  
        Since it does not modify core Virtuliservmenu files, it can be used in production environments.  
        However, it is always recommended to test it in a controlled environment first.
      </p>

      {/* 🔟 Uninstallation */}
      <h3 className="text-xl font-semibold mt-16 mb-4 flex items-center">
        <StepNumber number={10} />
        How do I uninstall vmenu?
      </h3>
      <p className="mb-4">
        You can uninstall vmenu from the <strong>Settings menu</strong> using the <strong>Uninstall vmenu</strong> option.  
        Detailed steps can be found in the{" "}
        <Link href="https://macrimi.github.io/vmenu/docs/settings/uninstall-proxmenux" className="text-blue-500 hover:underline">
          Uninstall Guide
        </Link>.
      </p>

    </div>
  );
}