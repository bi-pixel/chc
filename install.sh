#!/bin/bash

# запускать под рутом
# wget -O install.sh 'https://github.com/bi-pixel/chc/raw/master/install.sh'; bash install.sh MASTERNODEGENKEY

clear
echo "============================================================================================="
echo "                              WELCOME TO CHC FAST DEPLOY!"
echo "============================================================================================="
echo
echo "Hardening your OS..."
echo "---------------------------"
NODEIP=$(dig +short myip.opendns.com @resolver1.opendns.com)
PRIVIP=$(hostname -I)
RPCUSER=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w10 | head -n1)
RPCPASSWORD=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w22 | head -n1)
GENKEY=$1
export DEBIAN_FRONTEND=noninteractive
apt-get -qq update
apt-get -qq upgrade -y
apt-get -y install python-virtualenv virtualenv
cd ~ || exit
mkdir -p .chaincoincore
mkdir -p chaincoin
wget -O chaincoin-0.16.4.tar.gz 'https://github.com/bi-pixel/chc/raw/master/chaincoin-0.16.4-x86_64-linux-gnu.tar.gz'
wget -O sen.tar.gz 'https://github.com/bi-pixel/chc/raw/master/sen.tar.gz'
tar xvzf chaincoin-0.16.4.tar.gz
rm chaincoin-0.16.4.tar.gz
mv chaincoin-0.16.4/bin/* chaincoin
rm -r chaincoin-0.16.4/
tar xvzf sen.tar.gz
rm sen.tar.gz
mv sentinel/ .chaincoincore/

echo \
"daemon=1
listen=1
rpcport=11995
rpcallowip=127.0.0.1
server=1
rpcuser=$RPCUSER
rpcpassword=$RPCPASSWORD
masternode=1
masternodeprivkey=$GENKEY
externalip=$NODEIP:11994
addnode=80.210.127.13:11994
addnode=52.183.12.76:11994
addnode=104.236.89.11:11994
" | sudo tee .chaincoincore/chaincoin.conf

cd .chaincoincore/sentinel/ || exit
rm -rf venv
virtualenv ./venv
./venv/bin/pip install -r requirements.txt
cd ~ || exit

( crontab -l | cat; echo "* * * * * cd /root/.chaincoincore/sentinel && ./venv/bin/python bin/sentinel.py >/dev/null 2>&1" ) | crontab -
( crontab -l | cat; echo "@reboot sudo /sbin/iptables -t nat -A OUTPUT -s $PRIVIP -d $NODEIP -j DNAT --to-destination 127.0.0.1" ) | crontab -
( crontab -l | cat; echo "@reboot /root/chaincoin/chaincoind" ) | crontab -
( crontab -l | cat; echo "*/20 * * * * /root/chaincoin/chaincoind" ) | crontab -

# создаем файл подкачки
# Получите список имен и путей файлов подкачки для вашей системы
swapon -s
# Выключите и удалите файл подкачки, если он уже существует
swapoff /swapfile
rm /swapfile
# Выделите файл подкачки, при необходимости изменив команду
fallocate -l 1G /swapfile
# Установите разрешения для файла подкачки
chmod 600 /swapfile
# Отформатируйте файл как пространство подкачки
mkswap /swapfile
# Активировать своп
swapon /swapfile
# Отредактируйте файл / etc / fstab, указав, что своп должен монтироваться при загрузке
echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab

reboot