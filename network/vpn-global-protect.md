# global protect linux cli installation
 
## pop-os, mint, ubuntu, debian
 
-----------------------------
### if is there any apt error 
```sh
sudo apt --fix-broken install
 ```

---------------------
### package install 

```sh
sudo apt-get install gir1.2-gtk-3.0 gir1.2-webkit2-4.0
sudo add-apt-repository ppa:yuezk/globalprotect-openconnect
sudo apt-get update
sudo apt-get install globalprotect-openconnect
```
 
------------------
### connect vpn
```sh
sudo -E gpclient connect --browser default globalprotect.yourcompany.com
```
