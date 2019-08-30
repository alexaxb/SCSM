# SCSM Management Pack Backup 2.1
#
# This script will export all unsealed Management Packs in the SCSM installation and save them as xml-files. Should be run on a daily basis and will create a new folder for each it runs, and save up to 2 months old exports.
# Start with: C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File "Backup.ps1"
# Made by:
# Alexander Axberg, Lumagate 2015


# Target directory for storing the Management Pack exports
[string]$TargetDir = "C:\SCSM\Backup\ManagementPacks"
 
 
 #Import SM module if not present
 If ( ! (Get-module System.Center.Service.Manager )) 
 {
	Try{
		 write-host Loading Service Manager module
		 Import-Module "$env:programfiles\Microsoft System Center 2012 R2\Service Manager\Powershell\System.Center.Service.Manager.psd1"
		 }
	 Catch{
		Throw "Could not import Service Manager cmdlets!"
		}
 }

 #Format date
[int]$Day = (get-date).Day
[string]$Month = Get-Date -UFormat %b

#Set how many months of old exports to save
$MonthToDelete = (Get-Date).AddMonths(-2)
$MonthToDelete = Get-Date $MonthToDelete -UFormat %b

#If we have exports older than 2 month, delete the entire month
try {
    $Old = (Resolve-Path "$TargetDir\$MonthToDelete" -ErrorAction Ignore).Path
}
catch {}

If ($old -ne $null){
    Remove-Item $old -Force -Recurse
}

 #Create a new datefolder for this backup
if (test-path "$TargetDir\$Month\$Day"){
    Remove-Item "$TargetDir\$Month\$Day" -Force -Recurse
}
New-Item "$TargetDir\$Month\$Day"  -ItemType Directory | Out-Null
Get-SCManagementPack | ?{$_.Sealed -eq $False}|Export-SCManagementPack -Path "$TargetDir\$Month\$Day"