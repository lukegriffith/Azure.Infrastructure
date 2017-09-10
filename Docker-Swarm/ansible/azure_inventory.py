#!/usr/bin/python
'''
    azure dynamic inventory for ansible.
'''
import os
import sys
import argparse
import json
import configparser
from azure.common.credentials import ServicePrincipalCredentials    
from azure.mgmt.compute import ComputeManagementClient




def get_output():
    '''gets output'''

    output = dict()

    output["azure"] = HOSTS

    return json.dumps(output)

def get_host(host):
    '''gets indiviual host'''

    output = dict()

    #output["azure"] = [h for h in HOSTS if h == host]
    
    #return json.dumps(output)
    return dict()



def get_machines(Compute_Management_Client):
    '''returns list of all virtual machines from client'''
    return Compute_Management_Client.virtual_machines.list_all()


def get_config(ini_file):
    ''' return config from inifile '''
    config = configparser.RawConfigParser(allow_no_value=False)
    config.read_file(ini_file)
    return config

DIRECTORY = os.path.dirname(os.path.realpath(__file__))
INIFILE = open((DIRECTORY + "/.azureSubscription"))


CONFIG = get_config(INIFILE)

CLIENT_ID = CONFIG.get("accountDetails", "client_id")
SECRET = CONFIG.get("accountDetails", "secret")
TENANT = CONFIG.get("accountDetails", "tenant")
SUBSCRIPTION = CONFIG.get("accountDetails", "subscription")


CREDENTIAL = ServicePrincipalCredentials(client_id=CLIENT_ID,
                                         secret=SECRET,
                                         tenant=TENANT)

CMC = ComputeManagementClient(credentials=CREDENTIAL,
                              subscription_id=SUBSCRIPTION)


MACHINES = get_machines(CMC)

for m in MACHINES:
    
    print("Name: " + m.name)
    print("Location: " + m.location )
    print()
    print("OS_Profile: ")
    print(m.os_profile)
    
    ### ID In this object, has the ID of the network interface.
    ### Use this to identify ip addresses.
    network = m.network_profile.network_interfaces

    for n in network:
        print()
        print ("Network Interface ID: " + n.id)

    print()
    print("===="*20)



#print(CMC)


HOSTS = ["51.140.72.134", "51.140.87.247", "51.140.86.218", "51.140.75.241"]

PARSER = argparse.ArgumentParser(description="Azure dynamic inventory script.")
PARSER.add_argument('--list', action='store_true')
PARSER.add_argument('--host', type=str, required=False)
ARGS = PARSER.parse_args()

if ARGS.list:
    print(get_output())
elif ARGS.host:
    print(get_host(ARGS.host))



