#!/bin/bash -e
echo ------------------------------------------------------------------
echo Bitcoin Node Installer / Copyright the Israeli Bitcoin Association, 2015
echo ------------------------------------------------------------------
echo BSD Licensed, NO WARRANTY WHATSOEVER. THIS MAY BRICK OR KILL
echo this will work on Raspberry Pi v2 model B, 1GB RAM.
echo will probably also work on others.
echo original installation instructions here: http://blog.pryds.eu/2014/06/compile-bitcoin-core-on-raspberry-pi.html
echo low resource hacks from this German post: https://bitcoin-forums.net/index.php?topic=1062396.0


echo you need a 64GB USB flash drive linked at ~/.bitcoin. If you do not have this, it will fail.
echo 
echo this script assumes you did NOT change the original pi / raspberry username/password
echo nor did you change the folder description.


echo first, making sure all dependencies are met.
echo updating repositories.
sudo apt-get update
echo upgrading software
sudo apt-get upgrade -y

echo upgrading kernel
sudo rpi-update

echo resizing swap
sudo echo CONF_SWAPSIZE=2048 > /etc/dphys-swapfile
echo restarting swap
sudo /etc/init.d/dphys-swapfile stop
sudo /etc/init.d/dphys-swapfile start

echo installing required software for bitcoind.

sudo apt-get install build-essential autoconf libssl-dev libboost-dev libboost-chrono-dev libboost-filesystem-dev libboost-program-options-dev libboost-system-dev libboost-test-dev libboost-thread-dev libtool

echo cloning the bitcoin git repository.
cd ~
git clone https://github.com/bitcoin/bitcoin.git

cd bitcoin

echo preparing files for installation
./autogen.sh

echo configuring, this may take an hour. we are not installing a full wallet.
./configure --disable-wallet

echo making brownies, this may take a few hours.
make

echo installing
sudo make install.

echo making bitcoin.conf
echo rpcuser=bitcoin > /home/pi/.bitcoin/bitcoin.conf
echo rpcpassword=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1) >> /home/pi/.bitcoin/bitcoin.conf

echo please change your RPC password in ~/.bitcoin/bitcoin.conf.

echo downloading the start and stop scripts. These are bash scripts to check if bitcoind crashed,
echo and if so, to restart it. We also added a script to crash bitcoind generously three times per
echo hour. Why? because we want to make sure it is not stuck processing something.

cd ~
wget --no-check-certificate https://github.com/jonklinger/Raspbian-Bitnote-Installer/raw/master/startcoin.sh
# wget --no-check-certificate https://github.com/jonklinger/Raspbian-Bitnote-Installer/raw/master/stopcoin.sh
chmod +x startcoin.sh
# chmod +x stopcoin.sh

echo startcoin.sh starts the bitcoin daemon with very low resources. If you see your pi not crashing
echo or something like that, you can increase the numbers.

echo changing crontab to run the start script. start will run on every five minutes to see if the daemon is up.
# echo stopcoin will run every half hour (or so) to kill the daemon.

cat <(crontab -l) <(echo "*/5 * * * * /home/pi/startcoin.sh") | crontab -
# cat <(crontab -l) <(echo "*/34 * * * * /home/pi/stopcoin.sh") | crontab -

echo done. Please reboot.
echo After reboot bitcoind should start within the minute. please check the running.log from time to time
