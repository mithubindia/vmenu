"use client"

import Image from "next/image"
import { Wrench, Target, CheckCircle, Github } from "lucide-react"
import { useState } from "react"

export default function Page() {
  const [activeLoader, setActiveLoader] = useState("arc")

  return (
    <div className="container mx-auto px-4 py-8">
      <h1 className="text-3xl font-bold mb-6">Create VM Synology DSM</h1>

      <section className="mb-10">
        <h2 className="text-2xl font-semibold mb-4 flex items-center">Introduction</h2>
        <p className="mb-4">
          ProxMenux provides an automated script that creates and configures a VM to install Synology DSM (DiskStation
          Manager). This script simplifies the process by downloading and adding one of the available loaders to the VM
          boot, giving you the option between three different choices:
        </p>

        <ul className="list-disc pl-5 mb-4">
          <li>
            <a
              href="https://github.com/AuxXxilium/arc"
              target="_blank"
              rel="noopener noreferrer"
              className="text-blue-600 hover:underline"
            >
              AuxXxilium Arc
            </a>{" "}
            (referred to as "arc")
          </li>
          <li>
            <a
              href="https://github.com/RROrg/rr"
              target="_blank"
              rel="noopener noreferrer"
              className="text-blue-600 hover:underline"
            >
              RedPill rr
            </a>{" "}
            (referred to as "rr")
          </li>
          <li>
            <a
              href="https://github.com/PeterSuh-Q3/tinycore-redpill"
              target="_blank"
              rel="noopener noreferrer"
              className="text-blue-600 hover:underline"
            >
              TinyCore RedPill M-shell
            </a>{" "}
            (referred to as "tinycore")
          </li>
        </ul>

        <p className="mb-4">
          You also have the option to add a custom loader if you prefer to modify or create your own configuration.
        </p>
        <p className="mb-4">
          All loaders are similar although each has its own structure and configuration methods. This guide describes
          the 6 basic steps involved in setting up a Synology DSM loader. The exact steps may vary depending on the
          loader and/or changes introduced by the developer, so <strong>understanding the basic steps</strong> similar in all of them
          will <strong>help you know how to build the loader</strong> of your choice for the proper functioning of Synology DSM.
        </p>
      </section>

      <section className="mb-10">
        <h2 className="text-2xl font-semibold mb-4 flex items-center">
          <Wrench className="h-6 w-6 mr-2 text-blue-500" />
          Step-by-Step Guide
        </h2>
        <p className="mb-6">
          This guide will walk you through the process of configuring the loader. Select your
          loader type below to see the steps for that loader.
        </p>

        {/* Selector de loader global */}
        <div className="bg-blue-50 p-4 rounded-lg mb-6">
          <h3 className="text-lg font-semibold mb-2">Select your loader type:</h3>
          <div className="flex space-x-4">
            <button
              onClick={() => setActiveLoader("arc")}
              className={`px-4 py-2 rounded-md font-medium ${
                activeLoader === "arc"
                  ? "bg-blue-500 text-white"
                  : "bg-white border border-gray-300 text-gray-700 hover:bg-gray-50"
              }`}
            >
              Arc Loader
            </button>
            <button
              onClick={() => setActiveLoader("rr")}
              className={`px-4 py-2 rounded-md font-medium ${
                activeLoader === "rr"
                  ? "bg-blue-500 text-white"
                  : "bg-white border border-gray-300 text-gray-700 hover:bg-gray-50"
              }`}
            >
              RR Loader
            </button>
            <button
              onClick={() => setActiveLoader("tinycore")}
              className={`px-4 py-2 rounded-md font-medium ${
                activeLoader === "tinycore"
                  ? "bg-blue-500 text-white"
                  : "bg-white border border-gray-300 text-gray-700 hover:bg-gray-50"
              }`}
            >
              TinyCore Loader
            </button>
          </div>
        </div>
      </section>

      <section className="mb-12 border-b pb-8">
        <h2 className="text-xl font-semibold mb-4 flex items-center" id="step1">
          <StepNumber number={1} />
          Start the VM and Access the Main Menu
        </h2>
        <p className="mb-4">
        Once the VM is created, start it. The first time you boot the VM, you'll access the loader's main menu to select 
        and configure the DSM model you want to build. Once the loader is created, this step will be skipped unless you 
        manually force a reconfiguration from the boot monitor. All loaders also have the option to configure the loader 
        via a web interface.
        </p>

        <div className="mt-6">
          {activeLoader === "arc" && (
            <div className="flex flex-col space-y-8">

              <p className="mt-16 mb-2">
                  <strong>Web interface</strong>, To access the web interface, simply open a web browser and enter 
                  the IP address shown in the VM's console output. For example, in our case: http://192.169.0.32.
                </p>

              <ImageWithCaption
                src="https://macrimi.github.io/ProxMenux/vm/synology/arc/arc_1_0_1.png"
                alt="Arc Loader Web Interface"
                caption="Arc Loader Web Interface"
              />

            <p className="mt-16 mb-2">
                  <strong>Terminal interface</strong>, Access it directly from the VM's console output.
                </p>

              <ImageWithCaption
                src="https://macrimi.github.io/ProxMenux/vm/synology/arc/arc_1_1_1.png"
                alt="Arc Loader Terminal Interface"
                caption="Arc Loader Terminal Interface"
              />
            </div>
          )}

          {activeLoader === "rr" && (
            <div className="flex flex-col space-y-8">
              
              <p className="mt-16 mb-2">
                  <strong>Web interface</strong>, To access the web interface, simply open a web browser and enter 
                  the IP address shown in the VM's console output. For example, in our case: http://192.169.0.33.
                </p>

              <ImageWithCaption
                src="https://macrimi.github.io/ProxMenux/vm/synology/rr/rr_2_0_2.png"
                alt="RR Command Example"
                caption="RR Loader Web Interface"
              />

              <p className="mt-16 mb-2">
                  <strong>Terminal interface</strong>, Access it directly from the VM's console output by typing <strong>menu.sh</strong> on the screen
                </p>

              <ImageWithCaption
                src="https://macrimi.github.io/ProxMenux/vm/synology/rr/rr_2_0_1.png"
                alt="RR Loader Interface"
                caption="RR Loader Terminal Interface"
              />

              <ImageWithCaption
                src="https://macrimi.github.io/ProxMenux/vm/synology/rr/rr_2_1_1.png"
                alt="RR Loader Interface"
                caption="RR Loader Terminal Interface"
              />     
            </div>
          )}

          {activeLoader === "tinycore" && (
            <div className="flex flex-col space-y-8">

                <p className="mt-16 mb-2">
                  <strong>Web interface</strong>, To access the web interface, simply open a web browser and enter 
                  the IP address shown in the VM's console output. For example, in our case: http://192.169.0.35.
                </p>

              <ImageWithCaption
                src="https://macrimi.github.io/ProxMenux/vm/synology/tinycore/tinycore_3_0_1.png"
                alt="TinyCore Loader Interface"
                caption="TinyCore Loader Web Interface"
              />

               <p className="mt-16 mb-2">
                <strong>Terminal interface</strong>, Access it directly from the VM's console output. Keep an eye on 
                the screen, as at some point it may prompt you to press a key to continue or ask if you want to change the language.
                </p>

              <ImageWithCaption
                src="https://macrimi.github.io/ProxMenux/vm/synology/tinycore/tinycore_3_1_1.png"
                alt="TinyCore Loader Interface"
                caption="TinyCore Loader Terminal Interface"
              />
            </div>
          )}
        </div>
      </section>

      <section className="mb-12 border-b pb-8">
        <h2 className="text-xl font-semibold mb-4 flex items-center" id="step2">
          <StepNumber number={2} />
          Select Model
        </h2>
        <p className="mb-4">
          After loading the menu, select the Synology DSM model you want to install. Depending on the loader, you may
          sometimes need to expand the options to see more models.
        </p>

        <div className="mt-6">
          {activeLoader === "arc" && (
            <div className="flex flex-col space-y-8">
              <ImageWithCaption
                src="https://macrimi.github.io/ProxMenux/vm/synology/arc/arc_1_2_1.png"
                alt="Arc Model Selection"
                caption="Arc Model Selection"
              />
            </div>
          )}

          {activeLoader === "rr" && (
            <div className="flex flex-col space-y-8">
              <ImageWithCaption
                src="https://macrimi.github.io/ProxMenux/vm/synology/rr/rr_2_2_1.png"
                alt="RR Model Selection"
                caption="RR Model Selection"
              />
            </div>
          )}

          {activeLoader === "tinycore" && (
            <div className="flex flex-col space-y-8">
              <ImageWithCaption
                src="https://macrimi.github.io/ProxMenux/vm/synology/tinycore/tinycore_3_2_1.png"
                alt="TinyCore Model Selection"
                caption="TinyCore Model Selection"
              />
            </div>
          )}
        </div>
        <p className="mt-4">In our example, we'll choose the SA6400 model.</p>
      </section>

      <section className="mb-12 border-b pb-8">
        <h2 className="text-xl font-semibold mb-4 flex items-center" id="step3">
          <StepNumber number={3} />
          Select DSM Version
        </h2>
        <p className="mb-4">
          After selecting the model, you need to choose the DSM version you want to install.
        </p>

        <div className="mt-6">
          {activeLoader === "arc" && (
            <div className="flex flex-col space-y-16">
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
          )}

          {activeLoader === "rr" && (
            <div className="flex flex-col space-y-16">
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
          )}

          {activeLoader === "tinycore" && (
            <div className="flex flex-col space-y-16">
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
          )}
        </div>
      </section>

      <section className="mb-12 border-b pb-8">
        <h2 className="text-xl font-semibold mb-4 flex items-center" id="step4">
          <StepNumber number={4} />
          Select Add-Ons
        </h2>
        <p className="mb-4">This step allows you to add additional features or custom configurations to the loader.</p>

        <div className="mt-6">
          {activeLoader === "arc" && (
            <div className="flex flex-col space-y-16">
              <p className="mb-2">
                <strong>Arc</strong> gives you the option to configure automatically or manually adjust the settings. 
                If automatic configuration is selected, the loader will start applying the necessary settings and will 
                automatically reboot once the process is complete.
              </p>
              <ImageWithCaption
                src="https://macrimi.github.io/ProxMenux/vm/synology/arc/arc_1_4_1.png"
                alt="Arc Auto Configuration"
                caption="Arc Auto Configuration"
              />
              <p className="mb-2">
                If we choose not to use automatic mode, we enter the menu to configure different options necessary for
                the loader:
              </p>
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
              <ImageWithCaption
                src="https://macrimi.github.io/ProxMenux/vm/synology/arc/arc_1_4_4.png"
                alt="Arc Sata Portmap"
                caption="Arc Sata Portmap (use the recommended option)"
              />
              <ImageWithCaption
                src="https://macrimi.github.io/ProxMenux/vm/synology/arc/arc_1_4_5.png"
                alt="Arc Add-Ons Selection"
                caption="Arc Add-Ons Selection"
              />
            </div>
          )}

          {activeLoader === "rr" && (
            <div className="flex flex-col space-y-8">
              <ImageWithCaption
                src="https://macrimi.github.io/ProxMenux/vm/synology/rr/rr_2_4_1.png"
                alt="RR Add-On Step 1"
                caption="RR Add-On Step 1"
              />
              <ImageWithCaption
                src="https://macrimi.github.io/ProxMenux/vm/synology/rr/rr_2_4_2.png"
                alt="RR Add-On Step 2"
                caption="RR Add-On Step 2 - Press to add add-ons"
              />
              <ImageWithCaption
                src="https://macrimi.github.io/ProxMenux/vm/synology/rr/rr_2_4_3.png"
                alt="RR Add-On Step 3"
                caption="RR Add-On Step 3 - Select the one you want by clicking on it. If you want to add more, repeat the process from images 2.4.2 and 2.4.3"
              />
            </div>
          )}

          {activeLoader === "tinycore" && (
            <div className="flex flex-col space-y-8">
              <ImageWithCaption
                src="https://macrimi.github.io/ProxMenux/vm/synology/tinycore/tinycore_3_4_1.png"
                alt="TinyCore SN Configuration"
                caption="TinyCore SN Configuration"
              />
              <ImageWithCaption
                src="https://macrimi.github.io/ProxMenux/vm/synology/tinycore/tinycore_3_4_2.png"
                alt="TinyCore Random Option"
                caption="TinyCore Random Option - The random option is recommended"
              />
              <ImageWithCaption
                src="https://macrimi.github.io/ProxMenux/vm/synology/tinycore/tinycore_3_4_3.png"
                alt="TinyCore MAC Configuration"
                caption="TinyCore MAC Configuration"
              />
              <ImageWithCaption
                src="https://macrimi.github.io/ProxMenux/vm/synology/tinycore/tinycore_3_4_4.png"
                alt="TinyCore VM MAC"
                caption="TinyCore VM MAC - Choose to use your VM's MAC or a random one"
              />
            </div>
          )}
        </div>
      </section>

      <section className="mb-12 border-b pb-8">
        <h2 className="text-xl font-semibold mb-4 flex items-center" id="step5">
          <StepNumber number={5} />
          Build the Loader
        </h2>
        <p className="mb-4">
          Once you have selected the model, DSM version, and add-ons, proceed to build the loader. This process might
          take a few minutes depending on the loader and the selected configuration. To start, select the "Build the
          Loader" option.
        </p>

        <div className="mt-6">
          {activeLoader === "arc" && (
            <div className="flex flex-col space-y-8">
              <ImageWithCaption
                src="https://macrimi.github.io/ProxMenux/vm/synology/arc/arc_1_5_1.png"
                alt="Arc Build Loader"
                caption="Arc Build Loader"
              />
            </div>
          )}

          {activeLoader === "rr" && (
            <div className="flex flex-col space-y-8">
              <ImageWithCaption
                src="https://macrimi.github.io/ProxMenux/vm/synology/rr/rr_2_5_1.png"
                alt="RR Build Loader"
                caption="RR Build Loader"
              />
            </div>
          )}

          {activeLoader === "tinycore" && (
            <div className="flex flex-col space-y-8">
              <ImageWithCaption
                src="https://macrimi.github.io/ProxMenux/vm/synology/tinycore/tinycore_3_5_1.png"
                alt="TinyCore Build Loader"
                caption="TinyCore Build Loader"
              />
            </div>
          )}
        </div>
      </section>

      <section className="mb-12 border-b pb-8">
        <h2 className="text-xl font-semibold mb-4 flex items-center" id="step6">
          <StepNumber number={6} />
          Boot the Loader
        </h2>
        <p className="mb-4">
          Once the loader has been built, it will prompt you to boot. The VM will restart with the configuration you've
          created and start the DSM installation.
        </p>

        <div className="mt-6">
          {activeLoader === "arc" && (
            <div className="flex flex-col space-y-8">
              <ImageWithCaption
                src="https://macrimi.github.io/ProxMenux/vm/synology/arc/arc_1_6_1.png"
                alt="Arc Boot Loader"
                caption="Arc Boot Loader"
              />
            </div>
          )}

          {activeLoader === "rr" && (
            <div className="flex flex-col space-y-8">
              <ImageWithCaption
                src="https://macrimi.github.io/ProxMenux/vm/synology/rr/rr_2_6_1.png"
                alt="RR Boot Loader"
                caption="RR Boot Loader"
              />
            </div>
          )}

          {activeLoader === "tinycore" && (
            <div className="flex flex-col space-y-8">
              <ImageWithCaption
                src="https://macrimi.github.io/ProxMenux/vm/synology/tinycore/tinycore_3_6_1.png"
                alt="TinyCore Boot Loader"
                caption="TinyCore Boot Loader"
              />
            </div>
          )}
        </div>
      </section>

      {/* STARTING DSM INSTALLATION */}
      <section className="mb-8">
        <h2 className="text-xl font-semibold mb-4 flex items-center">
          <CheckCircle className="h-6 w-6 mr-3 text-green-500" />
          Starting the DSM Installation
        </h2>
        <p className="mb-4">Once the loader is booted, you can find your Synology device using:</p>
        <div className="bg-gray-100 p-4 rounded-md overflow-x-auto text-sm mb-4">
          <code>https://finds.synology.com</code>
        </div>
        <p className="mb-6">Follow the on-screen steps to complete the DSM installation.</p>
        <div className="flex flex-col space-y-8">
          <ImageWithCaption
            src="https://macrimi.github.io/ProxMenux/vm/synology/install_DSM.png"
            alt="DSM Setup"
            caption="DSM Setup Screen"
          />
          <ImageWithCaption
            src="https://macrimi.github.io/ProxMenux/vm/synology/finish_install_DSM.png"
            alt="Installation Complete"
            caption="Installation Complete"
          />
        </div>
      </section>

      <section className="mb-8">
        <h2 className="text-2xl font-semibold mt-20 mb-4 flex items-center">
          <Target className="h-6 w-6 mr-2 text-blue-500" />
          Tips
        </h2>
        <ul className="list-disc pl-5 space-y-4">
          <li>
            Keep in mind that available options may change depending on the loader version and developer updates. If you
            encounter issues during the loader creation process, consult the loader documentation:
          </li>

          <div className="flex flex-wrap gap-4 mt-2">
              <a
                href="https://github.com/AuxXxilium/arc"
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center px-3 py-2 text-sm font-medium rounded-md bg-gray-100 text-gray-800 hover:bg-gray-200 transition-colors"
              >
                <Github className="h-5 w-5 mr-2" />
                Arc Documentation
              </a>
              <a
                href="https://github.com/RROrg/rr"
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center px-3 py-2 text-sm font-medium rounded-md bg-gray-100 text-gray-800 hover:bg-gray-200 transition-colors"
              >
                <Github className="h-5 w-5 mr-2" />
                RR Documentation
              </a>
              <a
                href="https://github.com/PeterSuh-Q3/tinycore-redpill"
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center px-3 py-2 text-sm font-medium rounded-md bg-gray-100 text-gray-800 hover:bg-gray-200 transition-colors"
              >
                <Github className="h-5 w-5 mr-2" />
                TinyCore Documentation
              </a>
            </div>

          <li>
            Some older DSM models may have issues recognizing disks or the network card. It is recommended to use more
            recent models.
          </li>

          <div className="bg-blue-100 border-l-4 border-blue-500 text-blue-700 p-4 mb-4">
            <p className="font-semibold">Update:</p>
            <p>
            Some loaders offer the option to update the loader directly from the menu.
            </p>
          </div>

          <div className="bg-yellow-100 border-l-4 border-yellow-500 text-yellow-700 p-4 mb-4">
            <p className="font-semibold">Important:</p>
            <p>
            ProxMenux does not provide support for the different loaders.
            </p>
          </div>

        </ul>
      </section>
    </div>
  )
}

function ImageWithCaption({ src, alt, caption }: { src: string; alt: string; caption: string }) {
  return (
    <div className="flex flex-col items-center w-full max-w-[768px] mx-auto my-4">
      <div className="w-full rounded-md overflow-hidden">
        <Image
          src={src || "/placeholder.svg"}
          alt={alt}
          width={768}
          height={0}
          style={{ height: "auto" }}
          className="object-contain w-full"
          sizes="(max-width: 768px) 100vw, 768px"
        />
      </div>
      <span className="mt-2 text-sm text-gray-600">{caption}</span>
    </div>
  )
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

