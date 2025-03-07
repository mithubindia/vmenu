import type { Metadata } from "next";
import { Link2 } from "lucide-react";
import Link from "next/link";

export const metadata: Metadata = {
  title: "ProxMenux - External Repositories",
  description:
    "Learn about the external repositories used in ProxMenux, how they are selected, and how to report issues or suggest new integrations.",
  openGraph: {
    title: "ProxMenux - External Repositories",
    description:
      "Learn about the external repositories used in ProxMenux, how they are selected, and how to report issues or suggest new integrations.",
    type: "article",
    url: "https://macrimi.github.io/ProxMenux/docs/external-repositories",
    images: [
      {
        url: "https://macrimi.github.io/ProxMenux/external-repos-image.png",
        width: 1200,
        height: 630,
        alt: "ProxMenux External Repositories",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "ProxMenux - External Repositories",
    description:
      "Learn about the external repositories used in ProxMenux, how they are selected, and how to report issues or suggest new integrations.",
    images: ["https://macrimi.github.io/ProxMenux/external-repos-image.png"],
  },
};

function SectionHeader({ number, title }: { number: number; title: string }) {
  return (
    <h3 className="text-xl font-semibold mt-16 mb-4 flex items-center">
      <div className="inline-flex items-center justify-center w-8 h-8 mr-3 text-white bg-blue-500 rounded-full">
        <span className="text-sm font-bold">{number}</span>
      </div>
      {title}
    </h3>
  );
}

export default function ExternalRepositoriesPage() {
  return (
    <div className="container mx-auto px-4 py-8">
      <div className="flex items-center mb-6">
        <Link2 className="h-8 w-8 mr-2 text-blue-500" />
        <h1 className="text-3xl font-bold">External Repositories</h1>
      </div>

      {/* Introduction */}
      <p className="mb-4">
        ProxMenux integrates with selected external repositories to provide alternative scripts for 
        various functionalities. These scripts come from <strong>trusted sources</strong> and serve as additional 
        options in some menu sections.
      </p>
      <p className="mb-4">
        When an external script is available as an alternative, ProxMenux will clearly indicate that it 
        originates from an external repository and specify which one.
      </p>

      {/* 1️⃣ Example of External Repository */}
      <SectionHeader number={1} title="Example of an External Repository" />
      <p className="mb-4">
        One essential repository for Proxmox VE users is:
      </p>
      <p className="mb-4">
        <Link
          href="https://community-scripts.github.io/ProxmoxVE/"
          className="text-blue-500 hover:underline"
          target="_blank"
        >
          Proxmox VE Helper-Scripts
        </Link>{" "}
        - A highly recommended repository that provides additional tools and utilities for 
        managing Proxmox VE more efficiently.
      </p>

      {/* 2️⃣ Attribution & Recognition */}
      <SectionHeader number={2} title="Attribution & Recognition" />
      <ul className="list-disc list-inside mb-4 ml-4">
        <li>Credit is always given to the original authors.</li>
        <li>A link to the source repository is provided.</li>
        <li>Users are encouraged to support the developers of these external projects.</li>
      </ul>

      {/* 3️⃣ Reporting Issues with External Scripts */}
      <SectionHeader number={3} title="Reporting Issues with External Scripts" />
      <p className="mb-4">
        If you encounter an issue with an external script, <strong>please report it directly to the original 
        repository</strong> instead of opening an issue in the ProxMenux repository.
      </p>
      <p className="mb-4">
      <strong>ProxMenux does not modify external scripts</strong>; it simply provides a link to the original source.  
        Therefore, any problems related to functionality should be reported to the respective developers.
      </p>

      {/* 4️⃣ Suggesting New External Repositories */}
      <SectionHeader number={4} title="Suggesting New External Repositories" />
      <p className="mb-4">
        If you know of a script or repository that could enhance ProxMenux, feel free to suggest it by 
        opening a discussion or issue in our GitHub repository.
      </p>
      <p className="mb-4">
        🔗{" "}
        <Link
          href="https://github.com/MacRimi/ProxMenux/discussions"
          className="text-blue-500 hover:underline"
          target="_blank"
        >
          Open a Discussion
        </Link>{" "}
        |{" "}
        <Link
          href="https://github.com/MacRimi/ProxMenux/issues"
          className="text-blue-500 hover:underline"
          target="_blank"
        >
          Report an Issue
        </Link>
      </p>
    </div>
  );
}
