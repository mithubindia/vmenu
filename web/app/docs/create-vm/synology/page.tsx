import type { Metadata } from "next"
import { Settings } from "lucide-react"
import Image from "next/image"

export const metadata: Metadata = {
  title: "ProxMenux - Create Synology DSM VM",
  description:
    "Step-by-step guide to create and configure a Synology DSM VM using ProxMenux with Arc, RR, and TinyCore loaders.",
  openGraph: {
    title: "ProxMenux - Create Synology DSM VM",
    description:
      "Step-by-step guide to create and configure a Synology DSM VM using ProxMenux with Arc, RR, and TinyCore loaders.",
    type: "article",
    url: "https://macrimi.github.io/ProxMenux/docs/synology-vm",
    images: [
      {
        url: "https://macrimi.github.io/ProxMenux/synology-vm-guide.png",
        width: 1200,
        height: 630,
        alt: "ProxMenux - Create Synology DSM VM",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "ProxMenux - Create Synology DSM VM",
    description:
      "Step-by-step guide to create and configure a Synology DSM VM using ProxMenux with Arc, RR, and TinyCore loaders.",
    images: ["https://macrimi.github.io/ProxMenux/synology-vm-guide.png"],
  },
}

function StepNumber({ number }: { number: number }) {
  return (
    <div
      className="inline-flex items-center justify-center w-8 h-8 mr-3 text-white bg-blue-500 rounded-full"
      aria-hidden="true"
    >
      <span className="text-sm font-bold">{number}</span>
    </div>
  )
}

function ImageWithCaption({ src, alt, caption }: { src: string; alt: string; caption: string }) {
  return (
    <div className="flex flex-col items-center">
      <div className="relative w-full h-48 md:h-64 overflow-hidden rounded-md">
        <Image
          src={src || "/placeholder.svg"}
          alt={alt}
          fill
          className="object-contain"
          sizes="(max-width: 768px) 100vw, (max-width: 1200px) 33vw, 25vw"
        />
      </div>
      <span className="mt-2 text-sm text-gray-600">{caption}</span>
    </div>
  )
}

export default function SynologyVmPage() {
  return (
    <div className="container mx-auto px-4 py-8">
      {/* Title + Icon */}
      <div className="flex items-center mb-6">
        <Settings className="h-8 w-8 mr-2 text-blue-500" />
        <h1 className="text-2xl md:text-3xl font-bold">Create Synology DSM VM using ProxMenux</h1>
      </div>

      {/* Introduction */}
      <div className="bg-gray-50 p-4 rounded-lg mb-8">
        <p className="text-base md:text-lg text-black mb-4">
          ProxMenux provides an automated script that creates and configures a VM to install Synology DSM (DiskStation
          Manager). This script allows you to choose from three different loaders:
        </p>
        <ul className="list-disc list-inside mb-4 ml-4">
          <li>
            <strong>AuxXxilium Arc</strong> (referred to as "arc")
          </li>
          <li>
            <strong>edPill rr</strong> (referred to as "rr")
          </li>
          <li>
            <strong>TinyCore RedPill M-shell</strong> (referred to as "tinycore")
          </li>
        </ul>
        <p className="text-base md:text-lg text-black mb-2">
          You also have the option to add a custom loader if you prefer to modify or create your own configuration.
        </p>
      </div>

      {/* STEP 1 */}
      <section className="mb-12 border-b pb-8">
        <h2 className="text-xl font-semibold mb-4 flex items-center" id="step1">
          <StepNumber number={1} />
          Start the VM and Access the Main Menu
        </h2>
        <p className="mb-4">
          Once the VM is created, start it. The first time you boot the VM, you'll access the
          <strong> loader's main menu</strong> to select and configure the DSM model you want to build. Once the loader
          is created, this step will be skipped unless you manually force a reconfiguration from the boot monitor.
        </p>

        {/* Command RR */}
        <div className="bg-gray-50 p-4 rounded-lg mb-6">
          <p className="mb-2">
          <strong>In the case of RR</strong>, you'll need to manually enter the following command to open the menu
            as shown in the image below:
          </p>
          <pre className="bg-gray-100 p-4 rounded-md overflow-x-auto text-sm">
            <code>./menu.sh</code>
          </pre>
          <div className="mt-4 flex justify-center">
            <div className="relative w-64 h-48 overflow-hidden rounded-md">
              <Image
                src="https://macrimi.github.io/ProxMenux/vm/synology/rr/rr_2_0_1.png"
                alt="RR Command Example"
                fill
                className="object-contain"
                sizes="(max-width: 768px) 100vw, 256px"
              />
            </div>
          </div>
          <p className="text-center text-sm text-gray-600 mt-2">RR Command Example: ./menu.sh</p>
        </div>

        {/* Example images */}
        <h3 className="text-lg font-semibold mb-4">Examples of loader interfaces:</h3>
        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-4">
          <ImageWithCaption
            src="https://macrimi.github.io/ProxMenux/vm/synology/arc/arc_1_1_1.png"
            alt="Arc Loader Interface"
            caption="Arc Loader Interface"
          />
          <ImageWithCaption
            src="https://macrimi.github.io/ProxMenux/vm/synology/rr/rr_2_1_1.png"
            alt="RR Loader Interface"
            caption="RR Loader Interface"
          />
          <ImageWithCaption
            src="https://macrimi.github.io/ProxMenux/vm/synology/tinycore/tinycore_3_1_1.png"
            alt="TinyCore Loader Interface"
            caption="TinyCore Loader Interface"
          />
        </div>
      </section>

      {/* STEP 2 */}
      <section className="mb-12 border-b pb-8">
        <h2 className="text-xl font-semibold mb-4 flex items-center" id="step2">
          <StepNumber number={2} />
          Select Model
        </h2>
        <p className="mb-4">After loading the menu, select the Synology DSM model you want to install.</p>
        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-4">
          <ImageWithCaption
            src="https://macrimi.github.io/ProxMenux/vm/synology/arc/arc_1_2_1.png"
            alt="Arc Model Selection"
            caption="Arc Model Selection"
          />
          <ImageWithCaption src="/vm/synology/rr/rr_2_2_1.png" alt="RR Model Selection" caption="RR Model Selection" />
          <ImageWithCaption
            src="https://macrimi.github.io/ProxMenux/vm/synology/tinycore/tinycore_3_2_1.png"
            alt="TinyCore Model Selection"
            caption="TinyCore Model Selection"
          />
        </div>
      </section>

      {/* STEP 3 */}
      <section className="mb-12 border-b pb-8">
        <h2 className="text-xl font-semibold mb-4 flex items-center" id="step3">
          <StepNumber number={3} />
          Select DSM Version
        </h2>
        <p className="mb-4">
          After selecting the model, you need to choose the DSM version you want to install. In some loaders (such as{" "}
          <strong>arc</strong>), you may encounter additional options at this stage.
        </p>

        <div className="mb-8">
          <h3 className="text-lg font-semibold mb-4">Arc Loader:</h3>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <ImageWithCaption
              src="https://macrimi.github.io/ProxMenux/vm/synology/arc/arc_1_3_1.png"
              alt="Arc Version Selection - Step 1"
              caption="Arc Version Selection - Step 1"
            />
            <ImageWithCaption
              src="https://macrimi.github.io/ProxMenux/vm/synology/arc/arc_1_3_2.png"
              alt="Arc Version Selection - Step 2"
              caption="Arc Version Selection - Step 2"
            />
          </div>
        </div>

        <div className="mb-8">
          <h3 className="text-lg font-semibold mb-4">RR Loader:</h3>
          <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-4">
            <ImageWithCaption
              src="https://macrimi.github.io/ProxMenux/vm/synology/rr/rr_2_3_1.png"
              alt="RR Version Selection - Step 1"
              caption="RR Version Selection - Step 1"
            />
            <ImageWithCaption
              src="https://macrimi.github.io/ProxMenux/vm/synology/rr/rr_2_3_2.png"
              alt="RR Version Selection - Step 2"
              caption="RR Version Selection - Step 2"
            />
            <ImageWithCaption
              src="https://macrimi.github.io/ProxMenux/vm/synology/rr/rr_2_3_3.png"
              alt="RR Version Selection - Step 3"
              caption="RR Version Selection - Step 3"
            />
          </div>
        </div>

        <div>
          <h3 className="text-lg font-semibold mb-4">TinyCore Loader:</h3>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <ImageWithCaption
              src="https://macrimi.github.io/ProxMenux/vm/synology/tinycore/tinycore_3_3_1.png"
              alt="TinyCore Version Selection - Step 1"
              caption="TinyCore Version Selection - Step 1"
            />
            <ImageWithCaption
              src="https://macrimi.github.io/ProxMenux/vm/synology/tinycore/tinycore_3_3_2.png"
              alt="TinyCore Version Selection - Step 2"
              caption="TinyCore Version Selection - Step 2"
            />
          </div>
        </div>
      </section>

      {/* STEP 4 */}
      <section className="mb-12 border-b pb-8">
        <h2 className="text-xl font-semibold mb-4 flex items-center" id="step4">
          <StepNumber number={4} />
          Select Add-Ons
        </h2>
        <p className="mb-4">This step allows you to add additional features or custom configurations to the loader.</p>
        <p className="mb-4">
          <strong>Arc</strong> gives you the option to configure automatically or manually adjust the settings.
        </p>

        <div className="mb-8">
          <h3 className="text-lg font-semibold mb-4">Arc Loader Add-Ons:</h3>
          <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-4">
            <ImageWithCaption
              src="https://macrimi.github.io/ProxMenux/vm/synology/arc/arc_1_4_1.png"
              alt="Arc Auto Configuration"
              caption="Arc Auto Configuration"
            />
            <ImageWithCaption
              src="https://macrimi.github.io/ProxMenux/vm/synology/arc/arc_1_4_2.png"
              alt="Arc Manual Configuration"
              caption="Arc Manual Configuration"
            />
            <ImageWithCaption
              src="https://macrimi.github.io/ProxMenux/vm/synology/arc/arc_1_4_3.png"
              alt="Arc SN/Mac Configuration"
              caption="Arc SN/Mac Configuration"
            />
            <ImageWithCaption src="/vm/synology/arc/arc_1_4_4.png" alt="Arc Sata Portmap" caption="Arc Sata Portmap" />
            <ImageWithCaption
              src="https://macrimi.github.io/ProxMenux/vm/synology/arc/arc_1_4_5.png"
              alt="Arc Add-Ons Selection"
              caption="Arc Add-Ons Selection"
            />
          </div>
        </div>

        <div className="mb-8">
          <h3 className="text-lg font-semibold mb-4">RR Loader Add-Ons:</h3>
          <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-4">
            <ImageWithCaption src="https://macrimi.github.io/ProxMenux/vm/synology/rr/rr_2_4_1.png" alt="RR Add-On Step 1" caption="RR Add-On Step 1" />
            <ImageWithCaption src="https://macrimi.github.io/ProxMenux/vm/synology/rr/rr_2_4_2.png" alt="RR Add-On Step 2" caption="RR Add-On Step 2" />
            <ImageWithCaption src="https://macrimi.github.io/ProxMenux/vm/synology/rr/rr_2_4_3.png" alt="RR Add-On Step 3" caption="RR Add-On Step 3" />
          </div>
        </div>

        <div>
          <h3 className="text-lg font-semibold mb-4">TinyCore Loader Add-Ons:</h3>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <ImageWithCaption
              src="https://macrimi.github.io/ProxMenux/vm/synology/tinycore/tinycore_3_4_1.png"
              alt="TinyCore SN Configuration"
              caption="TinyCore SN Configuration"
            />
            <ImageWithCaption
              src="https://macrimi.github.io/ProxMenux/vm/synology/tinycore/tinycore_3_4_2.png"
              alt="TinyCore Random Option"
              caption="TinyCore Random Option"
            />
            <ImageWithCaption
              src="https://macrimi.github.io/ProxMenux/vm/synology/tinycore/tinycore_3_4_3.png"
              alt="TinyCore MAC Configuration"
              caption="TinyCore MAC Configuration"
            />
            <ImageWithCaption
              src="https://macrimi.github.io/ProxMenux/vm/synology/tinycore/tinycore_3_4_4.png"
              alt="TinyCore VM MAC"
              caption="TinyCore VM MAC"
            />
          </div>
        </div>
      </section>

      {/* STEP 5 */}
      <section className="mb-12 border-b pb-8">
        <h2 className="text-xl font-semibold mb-4 flex items-center" id="step5">
          <StepNumber number={5} />
          Build the Loader
        </h2>
        <p className="mb-4">Once you have selected the model, DSM version, and add-ons, proceed to build the loader.</p>
        <p className="mb-4">
          This process might take a few minutes depending on the loader and the selected configuration. To start, select
          the <strong>"Build the Loader"</strong> option.
        </p>

        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-4">
          <ImageWithCaption src="https://macrimi.github.io/ProxMenux/vm/synology/arc/arc_1_5_1.png" alt="Arc Build Loader" caption="Arc Build Loader" />
          <ImageWithCaption src="https://macrimi.github.io/ProxMenux/vm/synology/rr/rr_2_5_1.png" alt="RR Build Loader" caption="RR Build Loader" />
          <ImageWithCaption
            src="https://macrimi.github.io/ProxMenux/vm/synology/tinycore/tinycore_3_5_1.png"
            alt="TinyCore Build Loader"
            caption="TinyCore Build Loader"
          />
        </div>
      </section>

      {/* STEP 6 */}
      <section className="mb-12 border-b pb-8">
        <h2 className="text-xl font-semibold mb-4 flex items-center" id="step6">
          <StepNumber number={6} />
          Boot the Loader
        </h2>
        <p className="mb-4">
          Once the loader has been built, it will prompt you to boot. The VM will restart with the configuration you've
          created and start the DSM installation.
        </p>

        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-4">
          <ImageWithCaption src="https://macrimi.github.io/ProxMenux/vm/synology/arc/arc_1_6_1.png" alt="Arc Boot Loader" caption="Arc Boot Loader" />
          <ImageWithCaption src="https://macrimi.github.io/ProxMenux/vm/synology/rr/rr_2_6_1.png" alt="RR Boot Loader" caption="RR Boot Loader" />
          <ImageWithCaption
            src="/vm/synology/tinycore/tinycore_3_6_1.png"
            alt="TinyCore Boot Loader"
            caption="TinyCore Boot Loader"
          />
        </div>
      </section>

      {/* STARTING DSM INSTALLATION */}
      <section className="mb-8">
        <h2 className="text-xl font-semibold mb-4 flex items-center">
          <div
            className="inline-flex items-center justify-center w-8 h-8 mr-3 text-white bg-green-500 rounded-full"
            aria-hidden="true"
          >
            <span className="text-sm">✓</span>
          </div>
          Starting the DSM Installation
        </h2>
        <p className="mb-4">Once the loader is booted, you can find your Synology device using:</p>
        <div className="bg-gray-100 p-4 rounded-md overflow-x-auto text-sm mb-4">
          <code>https://find.synology.com</code>
        </div>
        <p className="mb-6">Follow the on-screen steps to complete the DSM installation.</p>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <ImageWithCaption src="https://macrimi.github.io/ProxMenux/vm/synology/install_DSM.png" alt="DSM Setup" caption="DSM Setup Screen" />
          <ImageWithCaption
            src="https://macrimi.github.io/ProxMenux/vm/synology/finish_install_DSM.png"
            alt="Installation Complete"
            caption="Installation Complete"
          />
        </div>
      </section>

      {/* Table of Contents - Fixed on the side for larger screens */}
      <div className="hidden lg:block fixed top-1/4 right-4 bg-white p-4 rounded-lg shadow-md w-64">
        <h3 className="font-bold text-lg mb-2">Quick Navigation</h3>
        <ul className="space-y-2">
          <li>
            <a href="#step1" className="text-blue-500 hover:underline">
              1. Start the VM
            </a>
          </li>
          <li>
            <a href="#step2" className="text-blue-500 hover:underline">
              2. Select Model
            </a>
          </li>
          <li>
            <a href="#step3" className="text-blue-500 hover:underline">
              3. Select DSM Version
            </a>
          </li>
          <li>
            <a href="#step4" className="text-blue-500 hover:underline">
              4. Select Add-Ons
            </a>
          </li>
          <li>
            <a href="#step5" className="text-blue-500 hover:underline">
              5. Build the Loader
            </a>
          </li>
          <li>
            <a href="#step6" className="text-blue-500 hover:underline">
              6. Boot the Loader
            </a>
          </li>
        </ul>
      </div>
    </div>
  )
}

