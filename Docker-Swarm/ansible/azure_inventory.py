#!/usr/bin/python
'''
    azure dynamic inventory for ansible.
'''
import os
import sys
import argparse
import json
import configparser
from pprint import PrettyPrinter
from azure.common.credentials import ServicePrincipalCredentials    
from azure.mgmt.compute import ComputeManagementClient
from azure.mgmt.network import NetworkManagementClient



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

NMC = NetworkManagementClient(credentials=CREDENTIAL,
                              subscription_id=SUBSCRIPTION)



class AzureMachine:
    def __init__(self, name, location, tags, public_ip, private_ip):
        self.name = name
        self.location = location
        self.tags = tags
        self.public_ip = public_ip
        self.private_ip = private_ip



MACHINES = get_machines(CMC)

Inventory = list()

for m in MACHINES:
    
    m_name = str()
    m_location = str()
    m_tags = list()
    m_public_ip = str()
    m_private_ip = str()


    m_name = m.name
    m_location = m.location
    m_tags = m.tags


    ### ID In this object, has the ID of the network interface.
    ### Use this to identify ip addresses.
    network = m.network_profile.network_interfaces

    for n in network:
        interfaces = NMC.network_interfaces.list_all()
        ip_config = NMC.public_ip_addresses.list_all()

        for inter in interfaces:
            if inter.id == n.id:
                for x in inter.ip_configurations:
                    m_private_ip = x.private_ip_address

                    for pip in ip_config:
                        if pip.id == x.public_ip_address.id:
                            m_public_ip = pip.ip_address
                            

    

    azure_host = AzureMachine(name=m_name, location=m_location,
                              tags=m_tags,public_ip =m_public_ip,
                              private_ip=m_private_ip)

    Inventory.append(azure_host)



pp = PrettyPrinter(indent=4)

for m in Inventory:
    pp.pprint(vars(m))
    print()


HOSTS = ["51.140.72.134", "51.140.87.247", "51.140.86.218", "51.140.75.241"]

PARSER = argparse.ArgumentParser(description="Azure dynamic inventory script.")
PARSER.add_argument('--list', action='store_true')
PARSER.add_argument('--host', type=str, required=False)
PARSER.add_argument('--ToggleBoundry', action='store_true',)
ARGS = PARSER.parse_args()

if ARGS.ToggleBoundry:
    b = CONFIG.get("settings", "boundry")

    if b:
        CONFIG.set("settings", "boundry", 0)
    else:
        CONFIG.set("settings", "boundry", 1)


if ARGS.list:
    print(get_output())
elif ARGS.host:
    print(get_host(ARGS.host))





