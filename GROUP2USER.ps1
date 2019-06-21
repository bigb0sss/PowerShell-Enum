<#
    .VERSION
	v1 - June 21, 2019
	
    .SYNOPSIS
	Query user accounts of the Domain Group or Group-Like and parse it to CSV format to search for "Service Accounts." 

    .DESCRIPTION
        Takes in a raw PowerShell query and exports it to CSV format for further analysis.

    .PARAMETER Client Name
        Enter Client Name for your references.

    .PARAMETER DC(FQDN) Name
        Domain Controller that you query against
		
	.PARAMETER Doamin Group / Domain Group-Like Name
		Domain Group: You can specify a single Domain Group.
		Domain Group-Like: You can specify a single word which might be contained in many groups.

    .EXAMPLE
        PS C:\> .\GROUP2USER.ps1
		[*] Enter Client Name: <UI>
		[*] Enter DC(FQDN) Name: <UI> 

		[1] Domain Group (ex. Domain Admins)
		[2] Domain Group-Like (ex. *vpn*)
		[1] 1 Group  [2] 2 Group-Like  [?] Help (default is "2"): <UI>
		[*] Enter Domain Group: <UI>
		[*] Enter Domain Group-like (ex. vpn): <UI>
#>

$ClientName = $(Write-Host "[*] Enter Client Name: " -ForegroundColor Green -NoNewline; Read-Host)
$dc = $(Write-Host "[*] Enter DC(FQDN) Name: " -ForegroundColor Green -NoNewline; Read-Host)

$1 = "[1] Domain Group (ex. Domain Admins)"
$2 = "[2] Domain Group-Like (ex. *vpn*)"
$choices  = '&1 Group', '&2 Group-Like'

$decision = $Host.UI.PromptForChoice($1, $2, $choices, 1)
if ($decision -eq 0) {
    $group = $(Write-Host "[*] Enter Domain Group: " -ForegroundColor Blue -NoNewline; Read-Host)
	
} else {
    $group_like = $(Write-Host "[*] Enter Domain Group-like (ex. vpn): " -ForegroundColor Blue -NoNewline; Read-Host)
	
}

Start-Sleep -s 1
echo ""
echo "   =============================="
echo "   |                            |"
echo "   |       GROUP2User.ps1       |"
echo "   |                            |"	
echo "   |         by bigb0ss         |"
echo "   |                            |"
echo "   =============================="
echo ""
echo "[+] Mr.DC: $dc"
echo "[+] Mr.Group: $group$group_like"
echo "[+] Creating a folder..."
Start-Sleep -s 2

# Folder Creation
New-Item -ItemType directory -Path .\$ClientName-group

# Choice between Group vs. Group-Like
if (!$group -eq "") {
	
	Get-ADGroup -Server $dc -Identity $group | select Name | Out-File -FilePath .\$ClientName-group\group.txt
	
} else {
	
	Get-ADGroup -Server $dc -Filter "Name -like '*$group_like*'" | select Name | Out-File -FilePath .\$ClientName-group\group.txt
}

Get-Content .\$ClientName-group\group.txt | ? {$_.Trim() -ne "" } | select -Skip 2 | Set-Content "$ClientName-group\temp.txt";
Get-Content .\$ClientName-group\temp.txt | ForEach-Object { Get-ADGroupMember -Server $dc -Identity $_.trim() | select SamAccountName } | Out-File -FilePath .\$ClientName-group\temp2.txt;
Get-Content .\$ClientName-group\temp2.txt | ? {$_.Trim() -ne "" } | select -Skip 2 | Set-Content "$ClientName-group\alluser.txt";

# Collecting Info + Export to CSV
echo ""
echo "[+] Collecting Info for the Users..."

# You can add/modify/remove attributes as needed from the following command: "GET-ADUser -Server "DC" <Username> -Properties *"
Get-Content "$ClientName-group\alluser.txt" | ForEach-Object { Get-ADUser -Server $dc -Identity $_.trim() -Properties * | 
select SamAccountName, CN, Description, Title, Enabled, PasswordNeverExpires, WhenCreated, PasswordLastSet, ServicePrincipalNames } | 
Export-Csv -Path .\$ClientName-group\$ClientName-group.csv -NoTypeInformation

# Removing temp files
Remove-Item -path .\$ClientName-group\temp*.txt
echo "[+] Complete!"
