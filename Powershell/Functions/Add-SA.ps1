function Add-SA{
    [CmdletBinding()] 
    param ( 
        [parameter(ValueFromPipeline=$false, ValueFromPipelineByPropertyName=$false, Mandatory=$false)] 
        [string]$Title,
        [parameter(Mandatory=$true)]
        [object]$ParentWI,
        [parameter(Mandatory=$false)]
        [string]$Description
    )

    $Count = (Get-SCSMRelatedObject -Relationship $ContainsActRel -SMObject $ParentWI|measure).Count

    # Classes & Relations
    $SAClass = Get-SCSMClass System.WorkItem.Activity.SequentialActivity
    $ContainsActRel = Get-SCSMRelationshipClass System.WorkItemContainsActivity

    $hash = @{
        'Id'='SA{0}';
        'Title'=$Title;
        'Description'=$Description;
        'Status'='ActivityStatusEnum.Ready';
        'SequenceId'=$Count;
    }

    try{
        # Create activity & relation in memory
        $NewSA = New-SCSMObject -Class $SAClass -PropertyHashtable $hash -PassThru -NoCommit
        $Relation = New-SCSMRelationshipObject -Relationship $ContainsActRel -Source $ParentWI -Target $NewSA -PassThru -NoCommit

        # Commit creation to SDK
        $Relation.Commit()
    } catch {
        Throw "Add-SA : Error creating activity: $($_)"
    }

    Return $NewSA
}