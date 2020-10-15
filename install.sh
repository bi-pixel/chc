#!/bin/bash

clear
echo "============================================================================================"
echo "                              WELCOME TO CHC FAST DEPLOY!"
echo "============================================================================================"
echo
echo "Hardening your OS..."
echo "---------------------------"
export DEBIAN_FRONTEND=noninteractive
apt-get -qq update 
apt-get -qq upgrade -y