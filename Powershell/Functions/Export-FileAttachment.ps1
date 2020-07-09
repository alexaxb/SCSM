function Export-FileAttachment {
    param(
        [parameter(Mandatory=$true)]$WorkItemObject,
        [parameter(Mandatory=$true)][string]$OutputFolder
    )

    Try {
    $WorkItemId = $WorkItemObject.Id
    #Create folder for IR
    New-Item -ItemType directory -Path $($OutputFolder + $WorkItemId) -Force | Out-Null
    
    $FileObject = Get-SCSMRelatedObject -SMObject $WorkItemObject  -Relationship (Get-SCSMRelationshipClass System.WorkItemHasFileAttachment)
    if(!$FileObject){
        Return
    }

    foreach ($obj in $FileObject){
        #File byte buffer
        $buffer = new-object byte[] -ArgumentList 4096

        $DisplayName = ($obj.Values | Where-Object {$_.type -match "DisplayName"}).value 
        $Content =  ($obj.Values | Where-Object {$_.type -match "Content"}).value # as Microsoft.EnterpriseManagement.Common.ServerBinaryStream

        #i.e. "2012.08.24 12.18.PM CR7050.xml"
        $filepath = ($OutputFolder + "$WorkItemId\" + $DisplayName)

        $stream = new-object System.IO.FileStream($filePath,[System.IO.FileMode]'Create',[System.IO.FileAccess]'Write')

        #Loop through the server content stream, copying bytes into the buffer, 4k at a time, until there are no more bytes
        $ReadBytes = 0
        do {
            if ($ReadBytes -Ne 0) {
                $Stream.Write($buffer,0,$ReadBytes)
            }
            $ReadBytes = $Content.Read($Buffer, 0,4096)
        } until ($ReadBytes -eq 0)

        #clean up
        $Stream.Close()
        $content.Close()
    }
    }
    Catch {
        Throw "Export-Attachment: Error exporting attachment $($_)"
    }
}