function Import-FileAttachment {
    param(
        [parameter(Mandatory=$true)]$WorkItemObject,
        [parameter(Mandatory=$true)][string]$FilePath,
        [parameter(Mandatory=$true)][string]$SCSMServer
    )

    $managementGroup = new-object Microsoft.EnterpriseManagement.EnterpriseManagementGroup $SCSMServer
    $mode =[System.IO.FileMode]::Open
    
    $FileObject = Get-Item $FilePath

    $fRead = New-Object System.IO.FileStream $FilePath, $mode
    $length = $FileObject.length
    
    $hash  = @{}
    $hash.Add("Id",[Guid]::NewGuid().ToString())
    $hash.Add("DisplayName",$FileObject.Name)
    $hash.Add("Description",$FileObject.Name)
    $hash.Add("Extension",$FileObject.Extension)
    $hash.Add("Size",$length)
    $hash.Add("AddedDate",[DateTime]::Now.ToUniversalTime())
    $hash.Add("Content",$fRead)
    $newFileAttach = New-SCSMObject -Class (Get-SCSMClass System.FileAttachment) -NoCommit -PropertyHashtable $hash

    $AttachmentRelObject = New-SCSMRelationshipObject -Relationship $FileAttachmentRel -Target $newFileAttach -Source $WorkItemObject -NoCommit
    
    try{
        $AttachmentRelObject.Commit()
    } catch {
        Throw "Add-Attachment: Error adding attachment to WorkItem: $($_)"
    }

    $fRead.close()
}