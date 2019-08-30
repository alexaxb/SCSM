function Get-UserSMTP {
    param(
        [parameter(Mandatory=$true)]$User
    )

    $Endpoint = Get-SCSMRelatedObject -Relationship (Get-SCSMRelationshipClass System.UserHasPreference) -SMObject $User | Where-Object {$_.ClassName -eq 'System.Notification.Endpoint' -and $_.DisplayName -match 'smtp'}
    Return $Endpoint.TargetAddress

}
