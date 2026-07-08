# Samba File Server

Student: Munifa Abbas
Course: DACS Batch #56, PNY Trainings, Arfa Tower, Lahore

## About this project

This project sets up a Samba file server on Ubuntu Server so that Windows
clients on the same network can access shared folders the same way they
would access a shared drive on a Windows server. I built this lab inside
VirtualBox on my Lenovo ThinkPad, with the Ubuntu Server VM acting as the
file server and a Windows 10 VM acting as the client used for testing.

The server was set up with three shares:

- **shared** - a group share where every lab user with a Samba account can
  read and write files
- **public** - a read only guest share, no login needed
- **munifa** - a private home folder that only my own account can access

## Lab environment

- Host machine: Lenovo ThinkPad, Windows 10
- Virtualization: VirtualBox
- Server VM: Ubuntu Server 22.04 LTS
- Client VM: Windows 10
- Network mode: VirtualBox internal network so both VMs can reach each other

## How I built it

1. Installed Ubuntu Server 22.04 in VirtualBox and gave it a static IP on the
   internal lab network.
2. Installed the `samba` and `samba-common-bin` packages.
3. Created the `sambashare` Linux group and the three share directories under
   `/srv/samba/`.
4. Wrote the `smb.conf` file in this repo, defining the global settings and
   the three shares with the permissions each one needed.
5. Created a Linux user for myself and set a separate Samba password with
   `smbpasswd`.
6. Restarted the `smbd` and `nmbd` services and tested the config with
   `testparm`.
7. From the Windows 10 client VM, mapped the network drive using
   `\\<server-ip>\shared` and confirmed I could read and write files.
8. Tested the public share from the client without logging in, and confirmed
   it was read only.
9. Tested that my private home share was not visible to other users on the
   network.

## How to use this repo

Clone this repo onto your Ubuntu server:

```bash
git clone https://github.com/your-username/samba-file-server.git
cd samba-file-server/scripts
sudo bash install_samba.sh
```

The script installs Samba, creates the directories and group, copies the lab
`smb.conf` into `/etc/samba/`, creates a user, and restarts the services. It
will ask you to set a Samba password during the run.

To add more lab users later:

```bash
sudo bash add_user.sh <username>
```

## Connecting from a Windows client

1. Open File Explorer.
2. In the address bar type `\\<server-ip>\shared`.
3. Enter the Samba username and password when prompted.
4. To make it a permanent mapped drive, right click **This PC** and choose
   **Map network drive**.

## Testing checklist I used

- [x] `testparm -s` runs with no syntax errors
- [x] `smbclient -L localhost -U munifa` lists all three shares
- [x] Windows client can map the shared drive and create a new file
- [x] Public share is visible without a login and is read only
- [x] Private share (munifa) does not show up for other users
- [x] Files created from Windows keep correct Linux permissions

## Project structure

```
samba-file-server/
├── config/
│   └── smb.conf
├── scripts/
│   ├── install_samba.sh
│   └── add_user.sh
├── README.md
└── LICENSE
```

## Problems I ran into

The client VM could not see the server at first because the two VMs were on
different VirtualBox network types, one on NAT and one on internal network.
Once I put both VMs on the same internal network and gave the server a
static IP, discovery worked. I also had to open the Samba ports through
`ufw` on the server since the firewall was blocking discovery traffic from
the Windows client.

## Future improvements

- Add Active Directory domain join instead of standalone user authentication
- Set up disk quotas per user
- Add automatic backup of the shared folder to an external location
