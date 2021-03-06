#### Configure these variables ####

$From = "itsupport@scsm.se"
$smtphost = "srv08"
$SSP_URL = "https://srv011.scsm.se:444/SMPortal"

# Number of hours that a Review Activity has been in status 'in progress' for us to the trigger the notification. 
# (This is actually based upon the Last Modified date of the Review Activity)
$Hours = 24

# If you want to change the subject and body of the notification e-mail, you can do so further down

#### End ####

Import-module SMLets

$RAClass = Get-SCSMClass System.WorkItem.Activity.ReviewActivity
$InProgress = Get-SCSMEnumeration ActivityStatusEnum.Active$
$NotYetVoted = Get-SCSMEnumeration DecisionEnum.NotYetVoted$
$ReviewerObjectRelClass = Get-SCSMRelationshipClass System.ReviewActivityHasReviewer$
$ReviewerUsertRelClass = Get-SCSMRelationshipClass System.ReviewerIsUser$
$Date = Get-Date

# Get all Review Activities which are in status In Progress and hasn't been modified for the specified ammount of hours
$RAObject = Get-SCSMObject -class $RAClass | where{ ($_.Status -eq $InProgress -and ($_.LastModified).AddHours($Hours) -lt $Date)}

if ($RAObject -ne $NULL) 
{
    # Step trough all Review Activities
    foreach ($RA in $RAObject)
        {
        # Get all related Reviewer objects to the current Review Activity
        $ReviewerObjects = Get-SCSMRelatedObject -SMObject $RA -Relationship $ReviewerObjectRelClass | where{ ($_.Decision -eq $NotYetVoted)}
                
        # Step trough all the retrieved Reviewer objects
        If ($ReviewerObjects -ne $NULL) {
            foreach ($ReviewerObject in $ReviewerObjects)
                {
                    
                    # Get the user which is related to the Review Object - The reviewing user
                    $ReviewingUser = Get-SCSMRelatedObject -SMObject $ReviewerObject -Relationship $ReviewerUsertRelClass
                    if ($ReviewingUser -ne $NULL) 
                        {
                        
                        # Get the users SMTP address                    
                        $endPoint = Get-SCSMRelatedObject -SMObject $ReviewingUser -Relationship $userPref| where{$_.DisplayName -like '*SMTP'}
                        if($endPoint -ne $NULL) 
                            {
                            # If the user have an SMTP address specified - compose and send the e-mail
                            if($endPoint.TargetAddress.length -gt 0) 
                                {
                                
                                
                                #### If you want, change the subject and body here ####
                                
                                # E-mail subject
                                $subject = "Reminder: please approve [" + $RA.Id + "]"
                                
                                # E-mail body
                                $body = "<div style=""font-family:Arial,Helvetica,sans-serif; font-size:16px;"">
                                Dear "+$ReviewingUser.firstname+",
                                <br /><br />This is a friendly reminder that we are awaiting your approval on "+$RA.Id+".
                                <br />Click <a href=""" + $SSP_URL + "/SitePages/My%20Activities.aspx?ActivityId=" + $RA.Get_ID() + """>here</a> to go to the approval page.
                                <br /><br />
                                <div style=""font-weight:bold"">ID:</div>
                                "+$RA.Id+"<br />
                                <br />
                                <div style=""font-weight:bold"">Title:</div>"+$RA.Title+"<br />
                                <br />
                                <div style=""font-weight:bold"">Description:</div>
                                <pre style=""margin-top: 0px; font-family:Arial,Helvetica,sans-serif; font-size:16px;"">"+$RA.description+"</pre>
                                Best Regards<br />
                                IT support<br />"
                                
                                #### End ####
                                
                                $to = $endpoint.TargetAddress
                                Send-Mail $From $To $Subject $Body
                                }
                            }
                        }
                }
            
            }
        }
}

#### Functions / Methods ####

function Send-Mail
 {
 param($From,$To,$Subject,$Body)
 $smtp = new-object system.net.mail.smtpClient($smtphost)
 $mail = new-object System.Net.Mail.MailMessage
 $mail.from=$From
 $mail.to.add($To)
 $mail.subject=$Subject
 $mail.body=$Body
 $mail.isbodyhtml=$true
 $smtp.send($mail)
 }
 
#### End ####

Remove-Module SMlets