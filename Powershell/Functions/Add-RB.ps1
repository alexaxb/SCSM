function Add-RB {
    <#
    .DESCRIPTION
    Applies a template on a Runbook Activity

    .PARAMETER Id
    Specifies the activity Id that should be updated

    .PARAMETER TemplateDisplayName
    Specifies the displayname of the template object to apply


    .EXAMPLE
    Apply-RBTemplate -Id RB123 -TemplateDisplayname 'Runbook name'

    .NOTES
    #>

    param (
                [Parameter(Mandatory=$true)]$Parent,

                [Parameter(Mandatory=$true)][string]$TemplateDisplayname
            )

    try{
        if ( !(Get-Module smlets) ) {
            try{
                Import-Module SMLets
            }
            catch {
                Throw "Apply-RBTemplate : Could not load smlets!"
            }
        }

        $Count = (Get-SCSMRelatedObject -SMObject $Parent -Relationship $ContainsActRel).Count

        $hash=@{
            'Id'='RB{0}';
            'SequenceId'=$Count;
        }

        $RB = New-SCSMObject -Class $RBClass -PropertyHashtable $hash -PassThru -NoCommit
        $RB_rel = New-SCSMRelationshipObject -Relationship $ContainsActRel -Source $Parent -Target $RB -PassThru -NoCommit
        $RB_rel.Commit()

        $Projection = Get-SCSMTypeProjection Microsoft.SystemCenter.Orchestrator.RunbookAutomationActivity.Projection
        if (!$Projection) {
            Throw "Apply-RBTemplate : Could not fetch SCSM type projection"
        }
        Write-Verbose "Type projection loaded"
    

        $AAObject = get-scsmobjectprojection $projection -filter "Id -eq $($RB.Name)"
        if (!$AAObject) {
            Throw "Apply-RBTemplate : Could not find Activity with Id: $($RB.NAme)"
        }
        Write-Verbose "Activity object found using type projection"


        $template = Get-SCSMObjectTemplate | ? {$_.Displayname -eq $TemplateDisplayname}
        if (!$template) {
            Throw "Apply-RBTemplate : Could not find a runbook template with displayname: $TemplateDisplayname"
        }
        Write-Verbose "Template object found"


        $AAObject.__base.ApplyTemplate($template)
        $AAObject.__base.Commit()
    
        Write-Verbose "Template applied"

        Return
    } catch {
        Throw "Add-RB : Error creating RB acitivity - $($_)"
    }
}