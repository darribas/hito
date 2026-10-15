# Testing on a VM

Development happens against a Fedora COSMIC Spin VM in **virt-manager**, with a
post-install snapshot you revert between runs. Everything is driven over SSH
from the laptop, so commands and output never have to be typed or copied
inside the VM window.

Why not GNOME Boxes: copy and paste between the laptop and a COSMIC guest
doesn't work (COSMIC is Wayland), and the Boxes Flatpak can't forward a port to
the guest (it ships without `passt`), so there's no way to SSH in.

## One-time setup

**1. Install virt-manager** (laptop):

```bash
sudo dnf install -y virt-manager libvirt-daemon-kvm
sudo systemctl enable --now libvirtd
sudo usermod -aG libvirt "$USER"   # optional: skips the password prompt; applies after next login
```

**2. Create the VM.** In virt-manager: **File → New Virtual Machine**, pick
the Fedora COSMIC Spin ISO, keep the default network (NAT), and install. Log in
once to reach a COSMIC session.

**3. Enable SSH in the VM.** The only thing ever typed inside the VM:

```bash
sudo systemctl enable --now sshd
```

The commands below use `<vm-ip>` for the VM's address. It's handed out by
libvirt's DHCP and can change, so look it up each session from the laptop:

```bash
virsh -c qemu:///system list --all                       # <vm>: the VM's name
virsh -c qemu:///system domifaddr <vm> --source agent    # asks the guest agent
```

The plain `domifaddr <vm>` (DHCP lease) can come back empty. Fallbacks:
`virsh -c qemu:///system net-dhcp-leases default`,
`domifaddr <vm> --source arp`, or `ip -4 addr show scope global` inside the VM. Check from the laptop:
`ssh <user>@<vm-ip>`.

**4. If the VM has no internet, fix Docker's firewall rule.** Docker sets
the laptop's `FORWARD` policy to `DROP`, which blocks libvirt's NAT: the VM
gets DNS but can't reach anything. Check with
`sudo iptables -L FORWARD -n | head -1` (`policy DROP` plus `DOCKER` chains
means this is it). Allow the VM network through Docker's user chain:

```bash
sudo iptables -I DOCKER-USER -i virbr0 -j ACCEPT
sudo iptables -I DOCKER-USER -o virbr0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
```

These rules are lost on reboot. To make it permanent instead (Docker 28+),
add `"ip-forward-no-drop": true` to `/etc/docker/daemon.json` and
`sudo systemctl restart docker`. That restart stops every running container.

**5. Optional: give an agent in a container access.** See
[Driving the VM from a container](#driving-the-vm-from-a-container) below. Do
it now, before the snapshot, so the snapshot carries the key.

**6. Take the snapshot.** Shut the VM down (a snapshot of a powered-off VM
reverts more reliably), then in the VM window: **View → Snapshots → ＋**. Name
it `clean-install-ssh`.

## Each session

1. **After a laptop reboot only:** re-add the two `iptables` rules from step 4
   (unless you made it permanent).
2. **Revert:** VM window → **View → Snapshots** → select `clean-install-ssh`
   → **▶ (Run selected snapshot)**. The snapshot was taken powered off, so the
   VM is off afterwards: power it on and log in. From a terminal instead:
   `virsh -c qemu:///system snapshot-revert <vm> clean-install-ssh && virsh -c qemu:///system start <vm>`.
3. **Connect:** find `<vm-ip>` (see step 3 above), then `ssh <user>@<vm-ip>`.
   If SSH complains the host key changed, run `ssh-keygen -R <vm-ip>`:
   reverting can bring back a key
   SSH no longer expects.

## Test loops

**Full run from a branch.** The real install path, run in the VM from a laptop
terminal (`-t` so sudo and the "Continue?" prompt can ask you):

```bash
ssh -t <user>@<vm-ip> 'PROVISION_REF=my-branch bash -c "$(curl -fsSL https://raw.githubusercontent.com/darribas/hito/main/bootstrap.sh)"'
```

Drop `PROVISION_REF=my-branch` to test `main`.

**One unit, without pushing.** Copy it over and run it:

```bash
ssh <user>@<vm-ip> 'rm -rf /tmp/hito && mkdir -p /tmp/hito/apps'
scp -r apps/<name> <user>@<vm-ip>:/tmp/hito/apps/
ssh -t <user>@<vm-ip> 'bash /tmp/hito/apps/<name>/setup.sh'
```

**Idempotency check.** After a successful run, *don't* revert: run the same
thing again. Nothing should change. To prove it for config payloads, hash the
managed files before and after the second run:

```bash
find ~/.config/cosmic -type f -exec sha256sum {} + | sort > /tmp/h1
# ...second run...
find ~/.config/cosmic -type f -exec sha256sum {} + | sort > /tmp/h2
diff /tmp/h1 /tmp/h2 && echo "no changes"
```

**Capturing a setting.** To find which files a GUI setting writes (how
`apps/cosmic/config/` and `apps/cosmic-term/config/` were built): snapshot the
config before, change the setting in the GUI, then diff.

```bash
cp -a ~/.config/cosmic /tmp/before
# ...change the setting in COSMIC Settings / the app...
diff -r /tmp/before ~/.config/cosmic
```

Commit only the files that changed, and only the settings you meant to change:
some settings pages write their defaults when you merely visit them.

## Driving the VM from a container

If the tool driving tests runs in a Docker container on the laptop (for
example a coding agent), it can't reach the VM directly: libvirt's firewall
only lets the laptop itself into its NAT network. Two extra pieces:

**A tunnel**, run on the laptop and left open for the session. It listens on
Docker's bridge address (`<docker-bridge-ip>`: find it with
`ip -4 addr show docker0` on the laptop), which the container can reach:

```bash
ssh -N -L <docker-bridge-ip>:2222:localhost:22 <user>@<vm-ip>
```

**A dedicated key**, generated in the container (somewhere other than `~/.ssh`
if that's mounted read-only), with an SSH config entry like:

```
Host hito-vm
  HostName <docker-bridge-ip>
  Port 2222
  User <user>
  IdentityFile <key-file>
  IdentitiesOnly yes
  StrictHostKeyChecking no      # the VM is reverted constantly; test VM only
  UserKnownHostsFile /dev/null
  LogLevel ERROR
```

Authorise its public key from the laptop:

```bash
echo '<public key>' | ssh <user>@<vm-ip> 'mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys'
```

The key lives in the container, so it's lost whenever the container is
recreated. Then generate a new one, authorise it as above, and **retake the
snapshot**: the old snapshot still carries the old key, so every revert would
lock the container out again.

The container can then copy units over and read config (`ssh -F <config>
hito-vm ...`). The VM's sudo still asks for a password, so steps that need
sudo are run by you with `ssh -t` from the laptop, as above.
