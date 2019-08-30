function Get-Manager {
    param(
        [parameter(Mandatory=$true)]$User
    )

    $ManagerRel = Get-SCSMRelationshipClass System.UserManagesUser
    
    $ManagerRelObj = Get-SCSMRelationshipObject -TargetRelationship $ManagerRel -TargetObject $User
    if($ManagerRelObj){
        $Manager = Get-SCSMObject -Id ($ManagerRelObj[0].SourceObject.Id.Guid)
        Return $Manager
    }
    Return
}