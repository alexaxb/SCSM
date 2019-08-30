import-module smlets 
$Pending = Get-SCSMEnumeration -Name ActivityStatusEnum.Ready
$Cancelled = Get-SCSMEnumeration -Name ActivityStatusEnum.Cancelled 

$SRFailed = Get-SCSMEnumeration ServiceRequestStatusEnum.Failed$
$SRFailedGUID = $SRFailed.Get_ID()

$CRFailed = Get-SCSMEnumeration ChangeStatusEnum.Failed$
$CRFailedGUID = $CRFailed.Get_ID()

$SRClass = Get-SCSMClass WorkItem.ServiceRequest$
$CRClass = Get-SCSMClass WorkItem.ChangeRequest$

$FailedSRs = Get-SCSMObject -Class $SRClass -Filter "Status -eq $SRFailedGUID"
$FailedCRs = Get-SCSMObject -Class $CRClass -Filter "Status -eq $CRFailedGUID"

Foreach($SR in $FailedSRs) {
    $ChildActivities = (Get-SCSMRelationshipObject -BySource $SR |?{$_.RelationshipID -eq "2da498be-0485-b2b2-d520-6ebd1698e61b"}) 
    
    Foreach($ActivityObj in $ChildActivities) {
        $Activity = Get-SCSMObject -ID $ActivityObj.TargetObject.Id
        
        If($Activity.Status -eq $Pending){
            $Activity.Id
            #$SetStatus = Set-SCSMObject -SMObject $Activity -Property Status -Value $Cancelled -PassThru
        }
    }

}

Foreach($CR in $FailedCRs) {
    $ChildActivities = (Get-SCSMRelationshipObject -BySource $CR |?{$_.RelationshipID -eq "2da498be-0485-b2b2-d520-6ebd1698e61b"}) 
    
    Foreach($ActivityObj in $ChildActivities) {
        $Activity = Get-SCSMObject -ID $ActivityObj.TargetObject.Id
        
        If($Activity.Status -eq $Pending){
            $Activity.Id
            $SetStatus = Set-SCSMObject -SMObject $Activity -Property Status -Value $Cancelled -PassThru
        }
    }

}