# neo-pixel-pi-scripts
Bash scripts for controlling a Raspberry Pi with a NeoPixel HAT

If `/opt/vc/bin/vcgencmd: No such file or directory`
```
apt install libraspberrypi-bin
```
If doubt leads to dispair
```
apt reinstall libraspberrypi-bin
```
If dispair leads to desperation
```
pip3 install vcgencmd
or
sudo pip3 install vcgencmd
```

Install scripts & Services
```
cd ~/neo-pixel-pi-scripts/
sudo -E ./install.sh
```

Update scripts & Services
```
cd ~/neo-pixel-pi-scripts/
git pull; sudo -E ./install.sh
```
