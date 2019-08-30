function New-SR {
    <#
    .SYNOPSIS
    Create a new Service Request
    
    .DESCRIPTION
    
    .EXAMPLE
    
    .EXAMPLE
    
    .PARAMETER WFServer
    Name of the workflow server in the environment
    #>
    [CmdletBinding(
    )]
    param
    (
      [Parameter(
          Mandatory=$true,
          ValueFromPipeline=$True,
          ValueFromPipelineByPropertyName=$True,
          HelpMessage='Title field')]
      [ValidateLength(0,256)]
      [string]$Title,
  
      [Parameter(
          Mandatory=$false,
          ValueFromPipeline=$True,
          ValueFromPipelineByPropertyName=$True,
          HelpMessage='Description field')]
      [ValidateLength(0,2000)]
      [string]$Description,
  
      [Parameter(
          Mandatory=$true,
          ValueFromPipeline=$True,
          ValueFromPipelineByPropertyName=$True,
          HelpMessage='Priority field')]
      [ValidateSet('Immediate','High','Medium','Low')]
      [string]$Priority,
  
      [Parameter(
          Mandatory=$true,
          ValueFromPipeline=$True,
          ValueFromPipelineByPropertyName=$True,
          HelpMessage='Urgency field')]
      [ValidateSet('Immediate','High','Medium','Low')]
      [string]$Urgency,
  
      [Parameter(
          Mandatory=$false,
          ValueFromPipeline=$True,
          ValueFromPipelineByPropertyName=$True,
          HelpMessage='Custom Area value')]
      [ValidateLength(0,256)]
      [ValidatePattern("^(Enum.).*")]
      [string]$CustomAreaEnum,
     
      [Parameter(
          Mandatory=$true,
          ValueFromPipeline=$true,
          ValueFromPipelineByPropertyName=$true,
          HelpMessage='Custom area attribute name')]
          [ValidateLength(0,256)]
          [string]$CustomAreaAttributeName,
  
      [Parameter(
          Mandatory=$false,
          ValueFromPipeline=$True,
          ValueFromPipelineByPropertyName=$True,
          HelpMessage='Supportgroup field')]
      [ValidateLength(0,256)]
      [ValidatePattern("^(Enum.).*")]
      [string]$SupportgroupEnum,
  
      [Parameter(
          Mandatory=$true,
          ValueFromPipeline=$True,
          ValueFromPipelineByPropertyName=$True,
          HelpMessage='Source field')]
      [ValidateSet('Other','Email','Portal','Telephone')]
      [string]$Source,
  
      [Parameter(
          Mandatory=$false,
          ValueFromPipeline=$True,
          ValueFromPipelineByPropertyName=$True,
          HelpMessage='Username of AssignedTo user')]
      [ValidateLength(0,256)]
      [string]$AssignedToUsername,
  
      [Parameter(
          Mandatory=$false,
          ValueFromPipeline=$True,
          ValueFromPipelineByPropertyName=$True,
          HelpMessage='Username of Affected user')]
      [ValidateLength(0,256)]
      [string]$AffectedUserUsername,
  
      [Parameter(
          Mandatory=$false,
          ValueFromPipeline=$True,
          ValueFromPipelineByPropertyName=$True,
          HelpMessage='Username of Created by')]
      [ValidateLength(0,256)]
      [string]$CreatedByUsername,

      [Parameter(
          Mandatory=$false,
          ValueFromPipeline=$true,
          ValueFromPipelineByPropertyName=$True,
          HelpMessage='Enum name of template')]
      [ValidateLength(0,256)]
      [string]$TemplateName      
          
     )
  
    begin {
      switch ($Source)
          {
              Telephone {$SRSource = "Enum.36d0a538de494279b552c1a193a2b5e9"}
              default {$SRSource = "ServiceRequestSourceEnum.$Source"}
          }
    }
  
    process {
  
      $SRHash = @{
          'Id'='SR{0}';
          'Title'=$Title;
          'Description'=$Description;
          'Status'='ServiceRequestStatusEnum.New';
          'Priority'="ServiceRequestPriorityEnum.$Priority";
          'Urgency'="ServiceRequestUrgencyEnum.$Urgency";
          'SupportGroup'=$SupportgroupEnum;
          'Source'=$SRSource;
      }

      if($CustomAreaEnum -and !$CustomAreaAttributeName){
          Throw "New-SR: Parameter CustomAreaAttributeName needs to be set to be able to use parameter CustomAreaEnum"
      }

      if($CustomAreaAttributeName){
          $SRHash.Add("$CustomAreaAttributeName",$CustomAreaEnum)
      }
  
      $SR = New-SCSMObject -Class (Get-SCSMClass System.WorkItem.ServiceRequest$) -PropertyHashtable $SRHash -PassThru
      Set-SCSMObject -SMObject $SR -Property Displayname -Value "$($SR.Id) : $($SR.Title)"
  
      # Apply template
      if($TemplateName){
          $Projection = Get-SCSMTypeProjection System.WorkItem.ServiceRequestProjection$
          $Template = Get-SCSMObjectTemplate $TemplateName
          if($null -eq $Template){
              Throw "New-SR: No template found with the name $TemplateName"
          }
          Set-SCSMObjectTemplate -Projection $Projection -Template $Template
      }

      # Set assigned to
      if($AssignedToUsername){
          $AssignedTo = Get-SCSMObject -Class (Get-SCSMClass Microsoft.AD.User$) -Filter "Username -eq $AssignedToUsername"
          if($AssignedTo){
              New-SCSMRelationshipObject -Relationship (Get-SCSMRelationshipClass System.WorkItemAssignedToUser) -Source $SR -Target $AssignedTo -Bulk
          }
      }
  
      # Set affected user
      if($AffectedUserUsername){
          $AffectedUser = Get-SCSMObject -Class (Get-SCSMClass Microsoft.AD.User$) -Filter "Username -eq $AffectedUserUsername"
          if($AffectedUser){
              New-SCSMRelationshipObject -Relationship (Get-SCSMRelationshipClass System.WorkItemAffectedUser) -Source $SR -Target $AffectedUser -Bulk
          }
      }
  
      # Set created by
      if($CreatedByUsername){
          $CreatedByUser = Get-SCSMObject -Class (Get-SCSMClass Microsoft.AD.User$) -Filter "Username -eq $CreatedByUsername"
          if($CreatedByUser){
              New-SCSMRelationshipObject -Relationship (Get-SCSMRelationshipClass System.WorkItemCreatedBy) -Source $SR -Target $CreatedByUser -Bulk
          }
      }
  
      Return $SR
      
    }
  }