#!/bin/bash

# if you are lost 
# https://www.jamesbower.com/linux-memory-analysis/
# https://markuta.com/live-memory-acquisition-on-linux-systems/

clear

if [[ $1 == debug ]]; then
    echo "Entering Cleanup mode."

    rm -rf /home/root/LiME /home/root/volatility
    rm -f /tmp/test.mem
    apt-get purge -y build-essential
    apt-get purge -y linux-headers-`uname -r`
    apt-get purge -y git python dwarfdump zip python-distorm3 python-crypto
    pip uninstall python-distorm3
    
    rmmod lime
    echo "Removed everything. exiting..."
    exit
fi

echo "Updating..."
sudo add-apt-repository universe
sudo apt-get update

echo "Setting up basic dependencies..."
for i in build-essential linux-headers-`uname -r` git python dwarfdump zip python-crypto python-pip; do
	sudo apt-get install -y $i
done

pip install distorm3

echo "Setting up LiME..."
git clone https://github.com/504ensicsLabs/LiME
cd LiME/src/
limeKO=$(make | tail -1 | cut -d ' ' -f 3)

insmod $limeKO "path=/tmp/test.mem format=lime"

echo "Setting up volatility..."
cd ../../
git clone https://github.com/volatilityfoundation/volatility
cd volatility/tools/linux
make clean
make

#limeKOversion=$(echo $limeKO | cut -c6-13)
#limeKOversion2=$(echo $limeKO | cut -c6-14)
#echo "limeKOversion = $limeKOversion"

cd ../../
sudo zip volatility/plugins/overlays/linux/Ubuntu_gogo.zip tools/linux/module.dwarf /boot/System.map-`uname -r`

printf "\n\n"
echo "Running volatility..." 
python vol.py --info | grep Linux

profile="LinuxUbuntu_gogox64"

printf "\n"
echo "[ Install Complete ]" 
echo "Usage (getting commands): python vol.py --info | grep -i linux_"
echo "Usage (actually using): python vol.py -f /tmp/test.mem --profile=$profile <command>"
printf "\n"

cp vol.py /opt/vol.py
printf "\nCopied vol.py to /opt/vol.py\n"

