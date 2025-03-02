import type { Metadata } from "next"
import { Zap } from "lucide-react"
import CopyableCode from "@/components/CopyableCode"

export const metadata: Metadata = {
  title: "ProxMenux Post-Install: Performance Settings",
  description:
    "Guide to Performance Settings in the ProxMenux post-install script for optimizing your Proxmox VE system performance.",
  openGraph: {
    title: "ProxMenux Post-Install: Performance Settings",
    description:
      "Guide to Performance Settings in the ProxMenux post-install script for optimizing your Proxmox VE system performance.",
    type: "article",
    url: "https://macrimi.github.io/ProxMenux/docs/post-install/performance",
    images: [
      {
        url: "https://macrimi.github.io/ProxMenux/performance-settings-image.png",
        width: 1200,
        height: 630,
        alt: "ProxMenux Post-Install Performance Settings",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "ProxMenux Post-Install: Performance Settings",
    description:
      "Guide to Performance Settings in the ProxMenux post-install script for optimizing your Proxmox VE system performance.",
    images: ["https://macrimi.github.io/ProxMenux/performance-settings-image.png"],
  },
}

function StepNumber({ number }: { number: number }) {
  return (
    <div className="inline-flex items-center justify-center w-8 h-8 mr-3 text-white bg-blue-500 rounded-full">
      <span className="text-sm font-bold">{number}</span>
    </div>
  )
}

export default function PerformanceSettingsPage() {
  return (
    <div className="container mx-auto px-4 py-8">
      <div className="flex items-center mb-6">
        <Zap className="h-8 w-8 mr-2 text-blue-500" />
        <h1 className="text-3xl font-bold">Performance Settings</h1>
      </div>
      <p className="mb-4">
        The <strong>Performance Settings</strong> category focuses on optimizing various aspects of your Proxmox VE
        system to enhance overall performance. These settings are designed to improve system efficiency and speed up
        certain operations.
      </p>
      <h2 className="text-2xl font-semibold mt-8 mb-4">Available Optimizations</h2>

    <h3 className="text-xl font-semibold mt-16 mb-4 flex items-center">
      <StepNumber number={1} />
      Configure pigz for Faster gzip Compression
    </h3>

    <p className="mb-4">
      This optimization configures <strong>pigz</strong> as a faster replacement for gzip compression. 
      Pigz is a parallel implementation of gzip that utilizes multiple CPU cores, 
      significantly improving compression speed on modern systems.
    </p>

    <p className="mb-4"><strong>Why use pigz instead of gzip?</strong></p>
    <ul className="list-disc pl-5 mb-4">
      <li><strong>Parallel processing:</strong> Uses all available CPU cores for faster compression.</li>
      <li><strong>Faster vzdump backups:</strong> When used with Proxmox's vzdump, it reduces backup times.</li>
      <li><strong>Drop-in replacement for gzip:</strong> It works exactly like gzip but is much more efficient.</li>
    </ul>

    <p className="mb-4">The following steps are performed:</p>
    <ul className="list-disc pl-5 mb-4">
      <li>Enables pigz in the vzdump configuration for faster backups.</li>
      <li>Installs the pigz package if not already installed.</li>
      <li>Creates a pigz wrapper script to replace the standard gzip command.</li>
      <li>Replaces the system gzip command with the pigz wrapper.</li>
    </ul>

    <p className="mb-4">
      <strong>Note:</strong> This optimization can significantly speed up compression tasks, especially on systems 
      with multiple CPU cores.
    </p>

    <p className="text-lg mb-2">This adjustment automates the following commands:</p>

    <CopyableCode
      code={`
    # Enable pigz in vzdump configuration
    sed -i "s/#pigz:.*/pigz: 1/" /etc/vzdump.conf

    # Install pigz
    apt-get -y install pigz

    # Create pigz wrapper script
    cat <<EOF > /bin/pigzwrapper
    #!/bin/sh
    PATH=/bin:\$PATH
    GZIP="-1"
    exec /usr/bin/pigz "\$@"
    EOF
    chmod +x /bin/pigzwrapper

    # Replace gzip with pigz wrapper
    mv -f /bin/gzip /bin/gzip.original
    cp -f /bin/pigzwrapper /bin/gzip
    chmod +x /bin/gzip
      `}
    />

    <h4 className="text-lg font-semibold mt-6">How to Use pigz</h4>
    <p className="mb-4">
      Pigz works the same way as gzip but compresses files much faster by using multiple CPU cores.
      Here’s how you can test its performance:
    </p>

    <CopyableCode
      code={`
    # Compress a file with gzip
    time gzip largefile.img

    # Compress a file with pigz (parallel gzip)
    time pigz largefile.img
      `}
    />

    <p className="mb-4">
      The output will show that pigz completes the compression significantly faster than gzip.
      To check the number of CPU cores pigz is using, run:
    </p>

    <CopyableCode
      code={`
    pigz -p $(nproc) largefile.img
      `}
    />

    <h4 className="text-lg font-semibold mt-6">Verifying pigz Replacement</h4>
    <p className="mb-4">
      After replacing gzip with pigz, you can confirm that the system is using pigz instead of gzip:
    </p>

    <CopyableCode
      code={`
    which gzip
    ls -l /bin/gzip
      `}
    />

    <p className="mb-4">
      The output should show that <code>/bin/gzip</code> is now linked to the pigz wrapper.
    </p>

    <p className="mt-4">
      By enabling pigz, compression-heavy tasks like vzdump backups and log archiving 
      will run much faster, leveraging multi-core processing.
    </p>


    <h3 className="text-xl font-semibold mt-16 mb-4 flex items-center">
      <StepNumber number={1} />
      Configure pigz for Faster gzip Compression
    </h3>

    <p className="mb-4">
      This optimization configures <strong>pigz</strong> as a faster replacement for gzip compression. 
      Pigz is a parallel implementation of gzip that utilizes multiple CPU cores, 
      significantly improving compression speed on modern systems.
    </p>

    <p className="mb-4"><strong>Why use pigz instead of gzip?</strong></p>
    <ul className="list-disc pl-5 mb-4">
      <li><strong>Parallel processing:</strong> Uses all available CPU cores for faster compression.</li>
      <li><strong>Faster vzdump backups:</strong> When used with Proxmox's vzdump, it reduces backup times.</li>
      <li><strong>Drop-in replacement for gzip:</strong> It works exactly like gzip but is much more efficient.</li>
    </ul>

    <p className="mb-4">The following steps are performed:</p>
    <ul className="list-disc pl-5 mb-4">
      <li>Enables pigz in the vzdump configuration for faster backups.</li>
      <li>Installs the pigz package if not already installed.</li>
      <li>Creates a pigz wrapper script to replace the standard gzip command.</li>
      <li>Replaces the system gzip command with the pigz wrapper.</li>
    </ul>

    <p className="mb-4">
      <strong>Note:</strong> This optimization can significantly speed up compression tasks, especially on systems 
      with multiple CPU cores.
    </p>

    <p className="text-lg mb-2">This adjustment automates the following commands:</p>

    <CopyableCode
      code={`
    # Enable pigz in vzdump configuration
    sed -i "s/#pigz:.*/pigz: 1/" /etc/vzdump.conf

    # Install pigz
    apt-get -y install pigz

    # Create pigz wrapper script
    cat <<EOF > /bin/pigzwrapper
    #!/bin/sh
    PATH=/bin:\$PATH
    GZIP="-1"
    exec /usr/bin/pigz "\$@"
    EOF
    chmod +x /bin/pigzwrapper

    # Replace gzip with pigz wrapper
    mv -f /bin/gzip /bin/gzip.original
    cp -f /bin/pigzwrapper /bin/gzip
    chmod +x /bin/gzip
      `}
    />

    <h4 className="text-lg font-semibold mt-6">How to Use pigz</h4>
    <p className="mb-4">
      Pigz works the same way as gzip but compresses files much faster by using multiple CPU cores.
      Here’s how you can test its performance:
    </p>

    <CopyableCode
      code={`
    # Compress a file with gzip
    time gzip largefile.img

    # Compress a file with pigz (parallel gzip)
    time pigz largefile.img
      `}
    />

    <p className="mb-4">
      The output will show that pigz completes the compression significantly faster than gzip.
      To check the number of CPU cores pigz is using, run:
    </p>

    <CopyableCode
      code={`
    pigz -p $(nproc) largefile.img
      `}
    />

    <h4 className="text-lg font-semibold mt-6">Verifying pigz Replacement</h4>
    <p className="mb-4">
      After replacing gzip with pigz, you can confirm that the system is using pigz instead of gzip:
    </p>

    <CopyableCode
      code={`
    which gzip
    ls -l /bin/gzip
      `}
    />

    <p className="mb-4">
      The output should show that <code>/bin/gzip</code> is now linked to the pigz wrapper.
    </p>

    <p className="mt-4">
      By enabling pigz, compression-heavy tasks like vzdump backups and log archiving 
      will run much faster, leveraging multi-core processing.
    </p>


      <section className="mt-12 p-4 bg-blue-100 rounded-md">
        <h2 className="text-xl font-semibold mb-2">Automatic Application</h2>
        <p>
          This performance optimization is automatically applied when selected in the Performance section. The
          automation ensures that pigz is correctly configured and integrated into your system, potentially improving
          the speed of compression operations without requiring manual intervention.
        </p>
      </section>
    </div>
  )
}

