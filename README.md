# QuickTestNet
Throw up a quick WiFi Access Point from your Linux OS to do further testing of a target device

Installation
============
I'm not 100% sure that this is everything needed but it worked for me on Kali Linux as my test VM.
```
apt install hostapd dnsmasq tmux python3
```

Running
=======
You need at least one WiFi card capable of running in AP (access point) mode with HostAPd.  Most cards nowadays support this pretty well.

edit the `setup_test_network.sh` script's first few lines to match the configuration you want/have.  For example, your wireless card may not be named `wlan0` on modern Debian based Systemd installs.  YMMV.

Run the script from inside the Github repo project folder: `bash setup_test_network.sh`
