$Days = -1
$smtphost="srv08"
$from="scsm@scsm.se"

#### Räkna ut datum ####
Function Get-GMTDate () {
$LocalZone = [System.TimeZoneInfo]::Local
$Hours = [system.Math]::Abs($LocalZone.BaseUtcOffset.Hours)
$Mins = [System.Math]::Abs($LocalZone.BaseUtcOffset.Minutes)
if ($LocalZone.IsdaylightSavingTime([system.DateTime]::Now)) { $Hours -= 1 }
$TimeDiff = New-Object TimeSpan 0,$Hours,$Mins,0,0
(Get-Date).Subtract($TimeDiff)
}
#### End ####

Import-Module -Name SMLets

$GMTDate = Get-GMTDate
$Tier1 = Get-SCSMEnumeration -Name IncidentTierQueuesEnum.Tier1$
$Tier2 = Get-SCSMEnumeration -Name IncidentTierQueuesEnum.Tier2$
$Tier3 = Get-SCSMEnumeration -Name IncidentTierQueuesEnum.Tier3$
$IncidentClass = Get-SCSMClass -Name System.WorkItem.Incident$
$AssignedUserRelClass = Get-SCSMRelationshipClass System.WorkItemAssignedToUser$

#### Hämta alla Incidenter som faller inom vårt kriteria, hämta assigned user och initiera mailutskick####
$AffectedIncidents = Get-SCSMObject -class $IncidentClass | where{ ($_.TierQueue -eq $Tier2 -or $_.TierQueue -eq $Tier3) -and ($_.LastModified).AddDays($Days) -lt $GMTDate}

if ($AffectedIncidents -ne $NULL) {
    foreach ($IR in $AffectedIncidents)
     {
        $to = GetAssignedUser $IR
        if ($to -ne $NULL) {
            $subject = "Amne[" + $IR.Id + "]"
            $body = "<div style=""font-family:Arial,Helvetica,sans-serif; font-size:16px;"">
Dear "+$to[1]+",
<br /><br />An incident which you are the assignee of haven't been modified since "+$IR.LastModified+"
<br /><br />
<div style=""font-weight:bold"">ID:</div>
"+$IR.Id+"<br />
<br />
<div style=""font-weight:bold"">Title:</div>"+$IR.Title+"<br />
<br />
<div style=""font-weight:bold"">Description:</div>
<pre style=""margin-top: 0px; font-family:Arial,Helvetica,sans-serif; font-size:16px;"">"+$IR.description+"</pre>
Best Regards<br />
IT support<br />"
            Send-Mail $from $to[0] $subject $body
            #write-host $from $to[0] $subject $body $GMTDate
        }
     }
}

#### End ####

#### Funktioner ####
function GetAssignedUser

{param ($Incident)

$AssignedUser = Get-SCSMRelatedObject -SMObject $Incident -Relationship $AssignedUserRelClass

if($AssignedUser -ne $NULL)
    {
        #Get the endpoint related to the affected user that specifies the smtp address
        $endPoint = Get-SCSMRelatedObject -SMObject $AssignedUser -Relationship $userPref|?{$_.DisplayName -like '*SMTP'}
        if($endPoint -ne $NULL)
        {
        if($endPoint.TargetAddress.length -gt 0)
            {
                #Output the located smtp address
                $endPoint.TargetAddress
                $AssignedUser.FirstName
            }
        }
    }



 }
 
function Send-Mail
 {
 param($From,$To,$Subject,$Body)
 $smtp = new-object system.net.mail.smtpClient($smtphost)
 $mail = new-object System.Net.Mail.MailMessage
 $mail.from= $From
 $mail.to.add($To)
 $mail.subject= $Subject
 $mail.body= $Body
 $mail.isbodyhtml=$true
 $smtp.send($mail)
 }
 
#### End ####