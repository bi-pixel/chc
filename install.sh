#!/bin/bash

clear
echo "============================================================================================"
echo "                              WELCOME TO CHC FAST DEPLOY!"
echo "============================================================================================"
echo
echo "Hardening your OS..."
echo "---------------------------"
export DEBIAN_FRONTEND=noninteractive
apt-get -qq update > /dev/null 2>&1
apt-get -qq upgrade -y > /dev/null 2>&1