function Add-RA {
    param(
        [parameter(Mandatory=$true)]$Parent,
        [parameter(Mandatory=$true)]$Title,
        [parameter(Mandatory=$false)]$Approvers,
        [parameter(Mandatory=$false)]$Description,
        [parameter(Mandatory=$false)][int]$ApprovalPercentage = 100
    )
	
	$RAClass = Get-SCSMClass System.WorkItem.Activity.ReviewActivity
	$ReviewerClass = Get-SCSMClass System.Reviewer
	$ContainsActRel = Get-SCSMRelationshipClass System.WorkItemContainsActivity
	$RAHasReviewerRel = Get-SCSMRelationshipClass System.ReviewActivityHasReviewer
	$ReviewerIsUserRel = Get-SCSMRelationshipClass System.ReviewerIsUser
	
    $Count = (Get-SCSMRelatedObject -SMObject $Parent -Relationship $ContainsActRel).Count

    if($ApprovalPercentage -lt 100){
        $Condition = 'ApprovalEnum.Percentage'
    } else {
        $Condition = 'ApprovalEnum.Unanimous'
    }

    $hash = @{
        'Id'='RA{0}';
        'Title'=$Title;
        'SequenceId'=$Count;
		'ApprovalPercentage'=$ApprovalPercentage;
		'ApprovalCondition'=$Condition;
        'Description'=$Description;
    }

    $RA = New-SCSMObject -Class $RAClass -PropertyHashtable $hash -PassThru -NoCommit
    $RA_rel = New-SCSMRelationshipObject -Relationship $ContainsActRel -Source $Parent -Target $RA -PassThru -NoCommit
    $RA_rel.Commit()
	

	if($Approvers){
		foreach ($Approver in $Approvers){
			$ReviewerHash = @{
				'ReviewerId'=[guid]::NewGuid().Guid;
			}
		    $Reviewer = New-SCSMObject -Class $ReviewerClass -PropertyHashtable $ReviewerHash -PassThru -NoCommit
		    $ReviewerRelObj = New-SCSMRelationshipObject -Relationship $RAHasReviewerRel -Source $RA -Target $Reviewer -NoCommit -PassThru
            $ReviewerRelObj.Commit()
			New-SCSMRelationshipObject -Relationship $ReviewerIsUserRel -Source $Reviewer -Target $Approver -Bulk
		}
	
	} else {
		$ReviewerHash = @{
			'ReviewerId'=[guid]::NewGuid().Guid;
		}
		$Reviewer = New-SCSMObject -Class $ReviewerClass -PropertyHashtable $ReviewerHash -PassThru -NoCommit
		$ReviewerRelObj = New-SCSMRelationshipObject -Relationship $RAHasReviewerRel -Source $RA -Target $Reviewer -NoCommit -PassThru
        $ReviewerRelObj.Commit()
	}

    Return $RA
}