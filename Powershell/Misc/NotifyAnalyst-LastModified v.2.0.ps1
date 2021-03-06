# Configure these variables
$ModifiedDays = 7
$smtphost="cas.eskilstuna.se"
$from="itsupport@eskilstuna.se"

# End

$Modules = (get-module|%{$_.name}) -join " "
if(!$Modules.Contains("SMLets")){Import-Module SMLets -ErrorVariable err -Force}

# Funktioner
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
 
Function Get-GMTDate () {
$LocalZone = [System.TimeZoneInfo]::Local
$Hours = [system.Math]::Abs($LocalZone.BaseUtcOffset.Hours)
$Mins = [System.Math]::Abs($LocalZone.BaseUtcOffset.Minutes)
if ($LocalZone.IsdaylightSavingTime([system.DateTime]::Now)) { $Hours -= 1 }
$TimeDiff = New-Object TimeSpan 0,$Hours,$Mins,0,0
(Get-Date).Subtract($TimeDiff)
}
# End

# Set some basic variables

$GMTDate = Get-GMTDate
$GMTDateMod = $GMTDate.AddDays(-$ModifiedDays)
#$Tier1 = (Get-SCSMEnumeration -Name IncidentTierQueuesEnum.Tier1$).Id
#$Tier2 = (Get-SCSMEnumeration -Name IncidentTierQueuesEnum.Tier2$).Id
#$Tier3 = (Get-SCSMEnumeration -Name IncidentTierQueuesEnum.Tier3$).Id
$Active = (Get-SCSMEnumeration -Name IncidentStatusenum.Active$).Id
$IncidentClass = Get-SCSMClass -Name System.WorkItem.Incident$
$AssignedUserRelClass = Get-SCSMRelationshipClass System.WorkItemAssignedToUser$

# End

# Get all incidents within our criteria, get the assigned user and send notification email
$cType = "Microsoft.EnterpriseManagement.Common.EnterpriseManagementObjectCriteria"
$cString = "(Status = '$Active' and LastModified <= '$GMTDateMod')"
$crit = new-object $cType $cString,$IncidentClass
 
$AffectedIncidents = Get-SCSMObject -criteria $crit 

if ($AffectedIncidents -ne $NULL) {
    foreach ($IR in $AffectedIncidents)
     {
        $to = GetAssignedUser $IR
        if ($to -ne $NULL) {
            $subject = "Påminnelse om Incident [" + $IR.Id + "]"
            $body = "<div style=""font-family:Arial,Helvetica,sans-serif; font-size:16px;"">
Hej "+$to[1]+",
<br /><br />Du är den tilldelade teknikern på ärende [" + $IR.Id + "]. <br /> 
Det har gått sju dagar sedan det här ärendet uppdaterades ("+$IR.LastModified+"). Var vänlig se över ärendet - återkoppla till kund och uppdatera ärendet vid behov.
<br /><br />
<div style=""font-weight:bold"">ID:</div>
"+$IR.Id+"<br />
<br />
<div style=""font-weight:bold"">Titel:</div>"+$IR.Title+"<br />
<br />
<div style=""font-weight:bold"">Beskrivning:</div>
<pre style=""margin-top: 0px; font-family:Arial,Helvetica,sans-serif; font-size:16px;"">"+$IR.description+"</pre>
<br />
Detta mail är autogenererat från SCSM<br />"
            Send-Mail $from $to[0] $subject $body
            #Set-scsmincident -ID $IR.Id -comment "Inactivity warning sent to assignee"
            #write-host $from $to[0] $subject $GMTDate
        }
     }
}

# End

remove-module -name SMLets -force