# GoldenGate-VPN-Bridge
Bridge devices to VPN enabled PC

## Scenario
You have development machine connected to a VPN which hijacks all network interfaces,
and another machine and/or device without VPN permission you want to connect to that
network.

## Solution
A USB to Ethernet adaptor, a virtual machine and Linux bridge interfacing.

The VM is created with a single network interface, which should be bound to the
VPN. A single CPU and 512Mb RAM should be enough.

Install a suitable Linux on the VM. I originally used Ubuntu 16.

Test VM has access to network resources on the secure network. This may need
network configuration for either NAT or briding to a secure interface.

Enable USB support.

Configure host network preferences to NOT activate the USB adapter. 

Attach the USB adapter and enable to the Linux virtual machine. 

Run the script in this codebase as root.


Note. When using VMWare, the bridge will gain one of the VMWare addresses. This will allow the remote device, and any other VMWare VM's on the host to communicate too. ( My test had 192.168.198.* ).




