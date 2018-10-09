#!/usr/bin/env python
# -*- coding: utf-8 -*-
#A Script for basic anonymity in Kaly Linux
#serverdaeron[at]gmail[dot]com

import sys, os, subprocess

#Show network devices
print subprocess.check_output(['ifconfig'], stderr=None, shell=False, universal_newlines=True)

#Chose the network device
nd = raw_input("Please, insert the network device name: ")
print "\nThe MAC address for ", nd, "is changing.."

#Change the mac address
subprocess.check_output(["ifconfig", nd, "down"], stderr=None, shell=False, universal_newlines=True)
print subprocess.check_output(["macchanger", "-r", nd], stderr=None, shell=False, universal_newlines=True)
subprocess.check_output(["ifconfig", nd, "up"], stderr=None, shell=False, universal_newlines=True)
print "\n...Restarting networking...\n"
subprocess.check_output(["service", "network-manager", "restart"], stderr=None, shell=False, universal_newlines=True)

#Hostname changer
os.system("clear")
hn = raw_input("Please, insert the new hostname: ")
subprocess.check_output(["hostname", hn], stderr=None, shell=False, universal_newlines=True)

#DNS Changer
os.system("clear")
print "\nPlease, chose your DNS and enter the number: \n\n[1] OpenDNS \n[2] Whonix Gateway"
print "\n##################\n" 

while (True):
    sh = input("Please, insert an option: ")
    if sh == 1:
        os.system("echo nameserver 208.67.222.222 > /etc/resolv.conf")
        os.system("sed -i '1 a nameserver 208.67.222.220' /etc/resolv.conf")
        break
    if sh == 2:
        os.system("echo nameserver 10.152.152.10 > /etc/resolv.conf")        
        os.system("sed -i '1 a nameserver 208.67.222.222' /etc/resolv.conf")
        break
#Restart Network manager
newMAC = "ifconfig " + nd + " | grep ether"
os.system("clear")
print "\nThe new MAC address is: "
print os.system(newMAC)
print '\nThe new Hostname is: '
print subprocess.check_output(["hostname"], stderr=None, shell=False, universal_newlines=True)
print 'The new DNS are: '
print subprocess.check_output(["cat", "/etc/resolv.conf"], stderr=None, shell=False, universal_newlines=True)
print 'ENJOY!'
