function Add-PA {
    param(
        $Parent,
        $Title
    )
    $ContainsActRel = Get-SCSMRelationshipClass System.WorkItemContainsActivity
    $PAClass = Get-SCSMClass System.WorkItem.Activity.ParallelActivity

    $Count = (Get-SCSMRelatedObject -SMObject $Parent -Relationship $ContainsActRel).Count

    $hash = @{
        'Id'='PA{0}';
        'Title'=$Title;
        'SequenceId'=$Count;
    }

    $PA = New-SCSMObject -Class $PAClass -PropertyHashtable $hash -PassThru -NoCommit
    $PA_rel = New-SCSMRelationshipObject -Relationship $ContainsActRel -Source $Parent -Target $PA -PassThru -NoCommit
    $PA_rel.Commit()
    Return $PA
}