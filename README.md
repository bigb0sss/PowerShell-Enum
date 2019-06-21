# PowerShell-Enum
Enumeration Tools for PowerShell

## GROUP2USER.ps1
Query domain groups || group-like to collect all users associated with them including specific properties. 
(*You can modifiy properties within the script. They are hardcoded...)

* Example:
```
PS C:\> .\GROUP2USER.ps1
  [*] Enter Client Name: <UI>
  [*] Enter DC(FQDN) Name: <UI> 

  [1] Domain Group (ex. Domain Admins)
  [2] Domain Group-Like (ex. *vpn*)
  [1] 1 Group  [2] 2 Group-Like  [?] Help (default is "2"): <UI>
    [*] Enter Domain Group (ex. Domain Admins): <UI>
    [*] Enter Domain Group-like (ex. vpn): <UI>
```
