function Write-Logfile { 
    <# 
    .SYNOPSIS
    Writes a message to a logfile on disk.

    .DESCRIPTION
    Use the following variables to control the logging:
    $WL_EnableLogging
    $WL_LogFilePath
    $WL_LoggingLevel = WARNING/INFO/ERROR

    .PARAMETER Message
    The text that should be logged

    .PARAMETER MessageHash
    Send an entire hashtable to be logged

    .PARAMETER New
    Creates a new logfile

    .PARAMETER Object
    Define a specific object to log about

    .PARAMETER EventType
    Set log event, Warning-Error-Info
    All Error events will be logged by default

    .EXAMPLE
    Write-Logfile -Message "Log this text..."

    .EXAMPLE
    Write-Logfile -Message "Log this text about a computer..." -Object Computer01
    .INPUTS

    .OUTPUTS

    .NOTES
    Created by Lumagate
    .LINK

    #>
    [CmdletBinding()] 
    param ( 
        [parameter(ValueFromPipeline=$false, ValueFromPipelineByPropertyName=$false, Mandatory=$true)] 
        [string]$Message,
        [parameter(ValueFromPipeline=$false, ValueFromPipelineByPropertyName=$false, Mandatory=$false)] 
        [hashtable]$MessageHash,
        [parameter(ValueFromPipeline=$false, ValueFromPipelineByPropertyName=$false, Mandatory=$false)] 
        [ValidateSet('New','Update')][string]$Logfile,
        [parameter(ValueFromPipeline=$false, ValueFromPipelineByPropertyName=$false, Mandatory=$false)] 
        [string]$Object,
        [parameter(ValueFromPipeline=$false, ValueFromPipelineByPropertyName=$false, Mandatory=$false)] 
        [ValidateSet('Error','Warning','Info')][string]$EventType='Info'

    ) 
    BEGIN{
        if ($WL_EnableLogging -eq $null ){
            #Write-Warning 'EnableLogging variable not set, logging will be disabled'
            Return
        }

        if ($WL_LogFilePath -eq $null -or ''){
            #Write-Warning 'LogFilePath variable not set, script.log will be created in local directory'
            $WL_LogFilePath = '.\script.log'
        }

        $Date = Get-Date -UFormat "%Y-%m-%d %H:%M"

        if ($Logfile -eq 'New'){
            New-Item -Path $WL_LogFilePath -ItemType File -Force | Out-Null
            $("[$Date] ***** NEW LOGFILE CREATED *****") | Out-File -Append -FilePath $WL_LogFilePath
        }
        elseif ($Logfile -eq 'Update') {
            $("[$Date] ***** LOGGING STARTED *****") | Out-File -Append -FilePath $WL_LogFilePath
        }

        


    }#begin 
    PROCESS{

        if ($EventType -eq 'Info') {
            $Type = '[INF]'

            If($WL_LoggingLevel -eq 'INFO'){
                if($Object){
                    $("[$Date]$Type [$Object] $Message") | Out-File -Append -FilePath $WL_LogFilePath
                }
                else{
                    $("[$Date]$Type $Message") | Out-File -Append -FilePath $WL_LogFilePath
                }

                if ($MessageHash){
                    $MessageHash | Out-String | Out-File -Append -FilePath $WL_LogFilePath
                }
            }

        }
        elseif ($EventType -eq 'Warning') {
            $Type = '[WAR]'

            If($WL_LoggingLevel -eq 'INFO' -or $WL_LoggingLevel -eq 'WARNING'){
                if($Object){
                    $("[$Date]$Type [$Object] $Message") | Out-File -Append -FilePath $WL_LogFilePath
                }
                else{
                    $("[$Date]$Type $Message") | Out-File -Append -FilePath $WL_LogFilePath
                }

                if ($MessageHash){
                    $MessageHash | Out-String | Out-File -Append -FilePath $WL_LogFilePath
                }
            }
        }
        elseif ($EventType -eq 'Error') {
            $Type = '[ERR]'

            If($WL_LoggingLevel -eq 'INFO' -or $WL_LoggingLevel -eq 'WARNING' -or $WL_LoggingLevel -eq 'ERROR' ){
                if($Object){
                    $("[$Date]$Type [$Object] $Message") | Out-File -Append -FilePath $WL_LogFilePath
                }
                else{
                    $("[$Date]$Type $Message") | Out-File -Append -FilePath $WL_LogFilePath
                }

                if ($MessageHash){
                    $MessageHash | Out-String | Out-File -Append -FilePath $WL_LogFilePath
                }
            }
        }




   
    }#process 
    END{



    }#end



}