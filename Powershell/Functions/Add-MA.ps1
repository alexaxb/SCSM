function Add-MA {
    param(
        [parameter(Mandatory=$true)]$Parent,
        [parameter(Mandatory=$true)]$Title,
        [parameter(Mandatory=$false)]$Supportgroup,
        [parameter(Mandatory=$false)]$Description,
        [parameter(Mandatory=$false)]$AssignedTo,
        [parameter(Mandatory=$false)]$Area
    )

	$MAClass = Get-SCSMClass System.WorkItem.Activity.ManualActivity
	$ContainsActRel = Get-SCSMRelationshipClass System.WorkItemContainsActivity
    $AssignedToRel = Get-SCSMRelationshipClass System.WorkitemAssignedTo
	
    try{
        if($Parent.ClassName -match 'parallel'){
            $Count = 0
        } else {
            $Count = (Get-SCSMRelatedObject -SMObject $Parent -Relationship $ContainsActRel).Count
        }

        $hash = @{
            'Id'='MA{0}';
            'Title'=$Title;
            'SequenceId'=$Count;
            'Description'=$Description;
            'Area'=$Area;
        }
        if($Supportgroup){$hash.Add('Supportgroup',$Supportgroup)}

        $MA = New-SCSMObject -Class $MAClass -PropertyHashtable $hash -PassThru -NoCommit
        $MA_rel = New-SCSMRelationshipObject -Relationship $ContainsActRel -Source $Parent -Target $MA -PassThru -NoCommit
        $MA_rel.Commit()

        if($AssignedTo){
            New-SCSMRelationshipObject -Relationship $AssignedToRel -Source $MA -Target $AssignedTo -Bulk
        }

        Return $MA
    } catch {
        Throw "Add-MA: $($_)"
    }
}