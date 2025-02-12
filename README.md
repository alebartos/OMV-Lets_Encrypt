# OMV-Lets_Encrypt
Script and daemon to make Let's Encrypt work with OMV

This script works ONLY if you have only ONE SSL Certificate

To make it work change "/path/to/fullchain" and "/path/to/privatekey" with the actual path gived to you after you run Certbot

Run chmod +x /path/to/ssl-cert-check.sh (change "path/to" with the actual path to the script) 
To make it a daemon follow these instructions:
  
  1)  run this command
      sudo nano /etc/systemd/system/ssl-cert-check.service

  2) copy the content of ssl-cert-check.service from this page to the new file
     
  3) click ctrl+o to save the file and ctrl+x to close nano

  4) run this command
     sudo systemctl daemon-reload

  5) run this command to enable script at startup
     sudo systemctl enable ssl-cert-check.service

  6) run this command to start the service
     sudo systemctl start ssl-cert-check.service

  7) check if service works with this command
     sudo systemctl status ssl-cert-check.service

Feel free to ask
