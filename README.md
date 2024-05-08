# Pritunl Client for Linux - Helper

## What is it.
Designed especially for Linux users with no time on their hands, this is a beautiful front-end UI to speed up the task of connecting and disconnecting from  Pritunl VPN endpoints

## What I hope for it to achieve.
Pritunl Inc are welcome to incorporate this script into the tool. If you do, please submit an issue so that other users can be informed. 

## Why was it created
I created this script because the GUI Pritunl client is not yet supported on Ubuntu 24.04 at the time.

## Why I really like it
It also helps because  I find my internet connection being terrible after being connected to 2 VPN servers at the same time. This script stops this behavior by disconnecting any existing sessions before establishing a new VPN session.

I like my colors!

# The technical bits

## Pre-requisites
You need to have `pritunl-client` installed: https://docs.pritunl.com/docs/command-line-interface

You need to first run the `add` command to add your profiles that your admin has given you:
```shell
pritunl-client add ./Downloads/zak.tar
```

You can either add the `tar` file or the `ovpn` file. 

(Replace the file name with your own, of course!)

## How to run it

```shell
./pritunl.sh
```
 
 
 
  

 
## Screenshots

![image](https://github.com/zaakiy/Pritunl-Client-for-Linux-Helper/assets/10609818/3ea770eb-69a8-481b-b8d4-a3ea257698e4)

![image](https://github.com/zaakiy/Pritunl-Client-for-Linux-Helper/assets/10609818/b8bd9430-9c0d-4c9d-aa1f-d0532663c428)

![image](https://github.com/zaakiy/Pritunl-Client-for-Linux-Helper/assets/10609818/eb9b9f41-8568-4fdb-ac5c-38a701a17d84)

![image](https://github.com/zaakiy/Pritunl-Client-for-Linux-Helper/assets/10609818/6ea90c29-cc11-41f2-a95c-c7b8978b86a6)

![image](https://github.com/zaakiy/Pritunl-Client-for-Linux-Helper/assets/10609818/598a6dda-2660-4b86-af74-67938c684163)
