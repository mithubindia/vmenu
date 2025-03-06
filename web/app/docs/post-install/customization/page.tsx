import { Sliders } from "lucide-react"
import CodeBlock from "./code-block"

function StepNumber({ number }: { number: number }) {
  return (
    <div className="inline-flex items-center justify-center w-8 h-8 mr-3 text-white bg-blue-500 rounded-full">
      <span className="text-sm font-bold">{number}</span>
    </div>
  )
}

export default function CustomizationSettingsPage() {
  return (
    <div className="container mx-auto px-4 py-8">
      <div className="flex items-center mb-6">
        <Sliders className="h-8 w-8 mr-2 text-blue-500" />
        <h1 className="text-3xl font-bold">Customization Settings</h1>
      </div>
      <p className="mb-4">
        The <strong>Customization Settings</strong> section allows you to configure and personalize the Proxmox VE
        environment with specific adjustments.
      </p>

      <h3 className="text-xl font-semibold mt-16 mb-4 flex items-center">
        <StepNumber number={1} />
        Customize Bash Prompt and Aliases
      </h3>
      <p className="mb-4">
        This option modifies the root user's <code>.bashrc</code> to enhance command-line usability by adding colorized
        prompts and useful aliases.
      </p>
      <p className="mb-4">What it does:</p>
      <ul className="list-disc pl-5 mb-4">
        <li>
          Backs up the original <code>.bashrc</code> file
        </li>
        <li>Configures a custom prompt with timestamp</li>
        <li>
          Adds colorized <code>ls</code> and <code>grep</code> aliases
        </li>
        <li>
          Ensures <code>.bashrc</code> is sourced in <code>.bash_profile</code>
        </li>
      </ul>
      <p className="text-lg mb-2">This adjustment automates the following commands:</p>
      <CodeBlock
        code={`# Modify .bashrc for root
cp /root/.bashrc /root/.bashrc.bak
sed -i '/HISTTIMEFORMAT/d' /root/.bashrc
sed -i '/PS1/d' /root/.bashrc
sed -i '/alias/d' /root/.bashrc

echo 'export HISTTIMEFORMAT="%d/%m/%y %T "' >> /root/.bashrc
echo 'export PS1="\\u@\\h:\\W \\\$ "' >> /root/.bashrc
echo "alias ll='ls -alF'" >> /root/.bashrc
source /root/.bashrc`}
      />

      <h3 className="text-xl font-semibold mt-16 mb-4 flex items-center">
        <StepNumber number={2} />
        Configure MOTD (Message of the Day)
      </h3>
      <p className="mb-4">This option customizes the MOTD to display a ProxMenux optimization message upon login.</p>
      <p className="text-lg mb-2">This adjustment automates the following commands:</p>
      <CodeBlock
        code={`# Backup original MOTD
cp /etc/motd /etc/motd.bak

echo "This system is optimized by: ProxMenux" | cat - /etc/motd > temp && mv temp /etc/motd`}
      />

      <h3 className="text-xl font-semibold mt-16 mb-4 flex items-center">
        <StepNumber number={3} />
        Remove Proxmox Subscription Banner
      </h3>
      <p className="mb-4">
        This option removes the Proxmox subscription banner and nag prompts from the web interface.
      </p>
      <p className="mb-4">What it does:</p>
      <ul className="list-disc pl-5 mb-4">
        <li>
          Patches <code>proxmoxlib.js</code> to disable banner checks
        </li>
        <li>Creates a cron job to ensure banner removal persists</li>
        <li>Configures APT to prevent nagging messages</li>
      </ul>
      <p className="text-lg mb-2">This adjustment automates the following commands:</p>
      <CodeBlock
        code={`# Remove Proxmox subscription banner
sed -i "s/data.status !== 'Active'/false/g" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
sed -i "s/checked_command: function(orig_cmd) {/checked_command: function() {} || function(orig_cmd) {/g" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js

echo "DPkg::Post-Invoke { \\"dpkg -V proxmox-widget-toolkit | grep -q '/proxmoxlib\\\\.js$'; if [ $\\? -eq 1 ]; then { echo 'Removing subscription nag from UI...'; sed -i '/data.status/{s/\\!/\\!/;s/Active/NoMoreNagging/}' /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js; }; fi\\"; };" > /etc/apt/apt.conf.d/xs-pve-no-nag`}
      />

      <section className="mt-12 p-4 bg-blue-100 rounded-md">
        <h2 className="text-xl font-semibold mb-2">Customization Application</h2>
        <p>
          These customization settings are applied automatically when selected in the post-install process. Adjustments
          can be made manually as needed.
        </p>
      </section>
    </div>
  )
}

