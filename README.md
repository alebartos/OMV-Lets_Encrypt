# OMV-Lets_Encrypt
__Script and daemon to make Let's Encrypt work with OMV__

__This script works ONLY if you have only ONE SSL Certificate__

__To make it work change__ "/path/to/fullchain" __and__ "/path/to/privatekey" __with the actual path gived to you after you run Certbot__

__Run:__ chmod +x /path/to/ssl-cert-check.sh __(change__ "path/to" __with the actual path to the script)__
__To make it a daemon follow these instructions:__
  
  __1)  run this command:__
      sudo nano /etc/systemd/system/ssl-cert-check.service

  __2) copy the content of ssl-cert-check.service from this page to the new file__
     
  __3) click ctrl+o to save the file and ctrl+x to close nano__

  __4) run this command:__
     sudo systemctl daemon-reload

  __5) run this command to enable script at startup:__
     sudo systemctl enable ssl-cert-check.service

  __6) run this command to start the service:__
     sudo systemctl start ssl-cert-check.service

  __7) check if service works with this command:__
     sudo systemctl status ssl-cert-check.service

Feel free to ask
