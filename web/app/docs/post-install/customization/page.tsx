import type { Metadata } from "next"
import { Paintbrush } from "lucide-react"
import CopyableCode from "@/components/CopyableCode"

export const metadata: Metadata = {
  title: "ProxMenux Post-Install: Customization Settings",
  description:
    "Guide to Customization Settings in the ProxMenux post-install script for personalizing your Proxmox VE environment.",
  openGraph: {
    title: "ProxMenux Post-Install: Customization Settings",
    description:
      "Guide to Customization Settings in the ProxMenux post-install script for personalizing your Proxmox VE environment.",
    type: "article",
    url: "https://macrimi.github.io/ProxMenux/docs/post-install/customization",
    images: [
      {
        url: "https://macrimi.github.io/ProxMenux/customization-settings-image.png",
        width: 1200,
        height: 630,
        alt: "ProxMenux Post-Install Customization Settings",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "ProxMenux Post-Install: Customization Settings",
    description:
      "Guide to Customization Settings in the ProxMenux post-install script for personalizing your Proxmox VE environment.",
    images: ["https://macrimi.github.io/ProxMenux/customization-settings-image.png"],
  },
}

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
        <Paintbrush className="h-8 w-8 mr-2 text-blue-500" />
        <h1 className="text-3xl font-bold">Customization Settings</h1>
      </div>
      <p className="mb-4">
        The <strong>Customization Settings</strong> category allows you to personalize various aspects of your Proxmox
        VE installation. These settings are optional and can be adjusted according to your preferences.
      </p>
      <h2 className="text-2xl font-semibold mt-8 mb-4">Available Customizations</h2>

      <h3 className="text-xl font-semibold mt-16 mb-4 flex items-center">
        <StepNumber number={1} />
        Customize bashrc
      </h3>
      <p className="mb-4">
        This customization modifies the .bashrc file for the root user, adding various aliases and configurations.
      </p>
      <p className="mb-4">The following changes are made:</p>
      <ul className="list-disc pl-5 mb-4">
        <li>Sets HISTTIMEFORMAT to include date and time in command history</li>
        <li>Configures a custom colorful prompt</li>
        <li>Adds aliases for common ls commands (l, la, ll)</li>
        <li>Enables color output for ls, grep, fgrep, and egrep commands</li>
        <li>Sources bash completion script</li>
      </ul>
      <p className="text-lg mb-2">This adjustment automates the following commands:</p>
      <CopyableCode
        code={`
# Add custom configurations to .bashrc
echo 'export HISTTIMEFORMAT="%d/%m/%y %T "' >> /root/.bashrc
echo 'export PS1="[\u@\h \W]\\$ "' >> /root/.bashrc
echo "alias l='ls -CF'" >> /root/.bashrc
echo "alias la='ls -A'" >> /root/.bashrc
echo "alias ll='ls -alF'" >> /root/.bashrc
echo "alias ls='ls --color=auto'" >> /root/.bashrc
echo "alias grep='grep --color=auto'" >> /root/.bashrc
echo "alias fgrep='fgrep --color=auto'" >> /root/.bashrc
echo "alias egrep='egrep --color=auto'" >> /root/.bashrc
echo "source /etc/profile.d/bash_completion.sh" >> /root/.bashrc

# Ensure .bashrc is sourced in .bash_profile
echo "source /root/.bashrc" >> /root/.bash_profile
      `}
      />

      <h3 className="text-xl font-semibold mt-16 mb-4 flex items-center">
        <StepNumber number={2} />
        Remove Subscription Banner
      </h3>
      <p className="mb-4">
        This customization removes the Proxmox VE subscription banner and nag messages from the web interface.
      </p>
      <p className="mb-4">The following changes are made:</p>
      <ul className="list-disc pl-5 mb-4">
        <li>Creates a daily cron job to remove the subscription banner</li>
        <li>Adds an APT hook to remove the nag message after package updates</li>
        <li>Applies the changes immediately by reinstalling the proxmox-widget-toolkit</li>
      </ul>
      <p className="text-lg mb-2">This adjustment automates the following commands:</p>
      <CopyableCode
        code={`
# Create cron job for banner removal
cat <<EOF > /etc/cron.daily/xs-pve-nosub
#!/bin/sh
sed -i "s/data.status !== 'Active'/false/g" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
sed -i "s/checked_command: function(orig_cmd) {/checked_command: function() {} || function(orig_cmd) {/g" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
EOF
chmod 755 /etc/cron.daily/xs-pve-nosub

# Create APT hook for nag removal
echo 'DPkg::Post-Invoke { "sed -i '/data.status/s/!//;s/Active/NoMoreNagging/' /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js"; };' > /etc/apt/apt.conf.d/xs-pve-no-nag

# Apply changes immediately
apt-get --reinstall install proxmox-widget-toolkit
      `}
      />

      <h3 className="text-xl font-semibold mt-16 mb-4 flex items-center">
        <StepNumber number={3} />
        Set up Custom MOTD Banner
      </h3>
      <p className="mb-4">
        This customization adds a custom message to the MOTD (Message of the Day) that appears when logging into the
        system via SSH.
      </p>
      <p className="mb-4">The following changes are made:</p>
      <ul className="list-disc pl-5 mb-4">
        <li>Adds a custom message at the beginning of the MOTD file</li>
        <li>Creates a backup of the original MOTD file</li>
        <li>Removes any empty lines from the MOTD file</li>
      </ul>
      <p className="text-lg mb-2">This adjustment automates the following commands:</p>
      <CopyableCode
        code={`
# Add custom message to MOTD
custom_message="This system is optimised by: ProxMenux"
cp /etc/motd /etc/motd.bak
echo -e "$custom_message\n\n$(cat /etc/motd)" > /etc/motd
sed -i '/^$/N;/^\n$/D' /etc/motd
      `}
      />

      <section className="mt-12 p-4 bg-blue-100 rounded-md">
        <h2 className="text-xl font-semibold mb-2">Automatic Application</h2>
        <p>
          All of these customizations are automatically applied when selected in the Customization section. This
          automation ensures that these personalized settings are applied consistently and correctly, saving time and
          reducing the potential for manual configuration errors.
        </p>
      </section>
    </div>
  )

}