#Define criteria used by the two following measurements
$IncidentActive = (Get-SCSMEnumeration IncidentStatusEnum.Active$ -ComputerName $computerName).Id
$xmlCriteria = @'
<Criteria xmlns="http://Microsoft.EnterpriseManagement.Core.Criteria/">
  <Reference Id="System.WorkItem.Incident.Library" PublicKeyToken="31bf3856ad364e35" Version="7.0.6555.0" Alias="CoreIncident" />
  <Reference Id="System.WorkItem.Library" PublicKeyToken="31bf3856ad364e35" Version="7.0.6555.0" Alias="CoreWorkItem" />
  <Expression>
    <And>
      <Expression>
        <SimpleExpression>
          <ValueExpressionLeft>
            <Property>$Context/Property[Type='CoreIncident!System.WorkItem.Incident']/Status$</Property>
          </ValueExpressionLeft>
          <Operator>Equal</Operator>
          <ValueExpressionRight>
            <Value>{0}</Value>
          </ValueExpressionRight>
        </SimpleExpression>
      </Expression>
      <Expression>
        <UnaryExpression>
          <ValueExpression>
            <GenericProperty Path="$Context/Path[Relationship='CoreWorkItem!System.WorkItemAssignedToUser' SeedRole='Source']$">Id</GenericProperty>
          </ValueExpression>
          <Operator>IsNull</Operator>
        </UnaryExpression>
      </Expression>
    </And>
  </Expression>
</Criteria>
'@
# Define the required ObjectProjectionCriteria
$CTYPE = "Microsoft.EnterpriseManagement.Common.ObjectProjectionCriteria"
$cc = [string]::Format($xmlCriteria, $IncidentActive)


Write-Host "Starting to measure with the heavy type projection"
measure-command{
    #Get the heavy projection
    $IncidentProjection = Get-SCSMTypeProjection System.WorkItem.Incident.ProjectionType$ -ComputerName $computerName
    $criteria = new-object $CTYPE $cc,$IncidentProjection.__Base,$IncidentProjection.managementgroup 

    # Get incidents matching the criteria
    get-scsmobjectprojection -Criteria $criteria -ComputerName $computerName
}

Write-Host "Starting to measure with the lighter type projection (same result as previous)"
measure-command{
    #Get the lighter projection 
    $IncidentProjection = Get-SCSMTypeProjection System.WorkItem.Incident.View.ProjectionType$ -ComputerName $computerName
    $criteria = new-object $CTYPE $cc,$IncidentProjection.__Base,$IncidentProjection.managementgroup

    # Get incidents matching the criteria
    get-scsmobjectprojection -Criteria $criteria -ComputerName $computerName
}

