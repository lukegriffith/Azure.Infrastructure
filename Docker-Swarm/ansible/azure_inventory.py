#!/usr/bin/python
'''
    azure dynamic inventory for ansible.
'''

import argparse
import json
from azure.common.credentials import UserPassCredentials
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


HOSTS = ["51.140.72.134", "51.140.87.247", "51.140.86.218", "51.140.75.241"]

PARSER = argparse.ArgumentParser(description="Azure dynamic inventory script.")
PARSER.add_argument('--list', action='store_true')
PARSER.add_argument('--host', type=str, required=False)
ARGS = PARSER.parse_args()

if ARGS.list:
    print(get_output())
elif ARGS.host:
    print(get_host(ARGS.host))


