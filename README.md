zero-adblock
============
An automated hosts scripts which downloading, parsing, merging, and de-duplicating the hosts list from various sources.

My project aims will always be as following
- Dynamic in coding == flexible && lesser maintenance,
- Resources alert == optimization in coding so that it not only achieve the task, it use better approach to finish the task quickly, mitigate resources intensive
- Educational / knowledge value == Using difference code technique and style so that we can learn difference and new alternative way on handling task together :)


I am a freelance programmer, if you find that my project helped you in any way,
please feel free to buy me a coffee, thanks!

paypal: 




Get started
============
Install dnsmassq from your repository

Create a dir /etc/dnsmasq/ and copy over the bash file
dnsmasq configuration file shall be copy to /etc/dnsmasq.d/

Edit the bash file using your favourite editor and insert the URLs into the bash scripts
- URL File, in the development process
- URL ended with "zip" is supported, but currently its only hard-coded with file name "hosts.txt"

Run the scripts, and it will automatically does its job.

You may want to configure your local network computer's DNS IP to point to dnsmasq server in order to benefit DNS Redirection from it :)




How it works
============
The supported format of the hosts file is: SOURCE DOMAIN HOSTNAMES. (for example: /etc/hosts format)
my scripts will only accept the sources line started with "127.0.0.1" and "0.0.0.0"
- the scripts will automatically process URLs listed
- it is also support URLs ended with "zip" but currently hard-coded to take only "hosts.txt" (flexible way in handling this is in developments)








