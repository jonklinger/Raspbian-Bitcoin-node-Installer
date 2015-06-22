#!/bin/bash -e
date >> /home/pi/.bitcoin/running.log

if [ "$(pidof bitcoind)" ]
then
   echo sync at block >> /home/pi/.bitcoin/running.log
	/usr/local/bin/bitcoind getblockcount >> /home/pi/.bitcoin/running.log

else

	/usr/local/bin/bitcoind -dns -noupnp -maxconnections=24 -timeout=120 -noirc -gen=0 -maxorphantx=15 -maxorphanblocks=15 -dbcache=15 -daemon -checkblocks=25 -maxreceivebuffer=1250 -maxsendbuffer=250 -disablewallet &
	echo was dead >> /home/pi/.bitcoin/running.log

  fi
