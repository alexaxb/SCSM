# Can be evolved
function Create-CR {

    param(
        [Parameter(Mandatory=$true)]
        [string]$Title,
        [Parameter(Mandatory=$false)]
        [string]$Description,
        [Parameter(Mandatory=$false)]
        [string]$Area,
        [Parameter(Mandatory=$false)]
        [string]$ScheduledStartDate,
        [Parameter(Mandatory=$false)]
        [string]$ScheduledEndDate,
        [Parameter(Mandatory=$false)]
        [string]$TemplateName        
    )


    $hash=@{
        'Id'='CR{0}';
        'Title'=$Title;
        'Description'=$Description;
        'Status'='ChangeStatusEnum.New';
        'Area'=$Area;
        'ScheduledStartDate'=$ScheduledStartDate.ToUniversalTime();
        'ScheduledEndDate'=$ScheduledEndDate.ToUniversalTime();
    }    
    $CR = New-SCSMObject -Class $CRClass -PropertyHashtable $hash -PassThru
    $CRwithProj = Get-SCSMObjectProjection System.WorkItem.ChangeRequestPortalProjection -Filter "Id -eq '$($CR.Id)'"
    $Template = Get-SCSMObjectTemplate $TemplateName
    $CRwithProj.__base.ApplyTemplate($Template)
    $CRwithProj.__base.Commit()

    Return $CR
}
