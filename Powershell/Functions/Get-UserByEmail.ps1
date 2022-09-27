# This function will return the user object of the specified Email Address. If a matching user isn't found, the function can create an Internal user within the SCSM CMDB
# NOTE: SMlets must be loaded in order for the function to work
Function Get-UserByEmail {
    param (
        [parameter(Mandatory=$True,Position=0)]$EmailAddress,
        [parameter(Mandatory=$False,Position=1)][switch]$CreateUser,
        [parameter(Mandatory=$False,Position=2)]$Name

    )
    try{
        # Get all the classes and relationships
        $objUserPreferenceClass = Get-SCSMClass System.UserPreference$
        $objUserPrefRel = Get-SCSMRelationshipClass System.UserHasPreference$
    
        # Check if the user exist
        $objUserPreference = Get-SCSMObject -Class $objUserPreferenceClass -Filter "DisplayName -like '*SMTP'" | Where-Object {$_.TargetAddress -eq $EmailAddress}

        If ($objUserPreference) {
            # A matching user exist, return the object

            # If, for some reason, several users are found, return the first one
            If ($objUserPreference.Count -gt 1) {$objUserPreference = $objUserPreference[0]}

            $RelObj = Get-SCSMRelationshipObject -TargetRelationship $objUserPrefRel -TargetObject $objUserPreference
            Return $objAffectedUser = Get-scsmobject -Id ($RelObj.SourceObject).Get_Id()

        } elseif ($CreateUser -and !$objUserPreference) {
            # A matching user does NOT exist. Do some processing to get the needed properties for creating the user object
            If (!$Name -or $Name -eq '') {
                $Name = $EmailAddress.Substring(0,$EmailAddress.IndexOf("@"))
                $UserName = $Name.Replace(",","")
                $UserName = $UserName.Replace(" ","")
            } else {
                $Name = $Name
                $UserName = $Name.Replace(",","")
                $UserName = $UserName.Replace(" ","")
            }

            # Try Username to make sure we have a unique username
            $Loop = $TRUE
            $i = 1

            While ($Loop -eq $TRUE) {
                $tempUser = Get-SCSMObject -Class (Get-SCSMClass System.Domain.User$) -Filter "UserName -eq $UserName"

                If ($tempUser) {
                    $UserName = $UserName + $i
                    $i = $i +1
                } elseif ($i -gt 15) {
                    Throw "Unable to find a unique username for the new user"
                } else {
                    $Loop = $False
                }
            }

            # Create the Property Hash for the new user object
            $PropertyHash = @{"DisplayName" = $Name;
                                "Domain" = "SMINTERNAL";
                                "UserName" = $UserName;
            }

            # Create the actual user object
            $objAffectedUser = New-SCSMObject -Class (Get-SCSMClass System.Domain.User$) -PropertyHashtable $PropertyHash -PassThru

            # Add the SMTP notification address to the created user object

            If ($objAffectedUser) {
                $NewGUID = ([guid]::NewGuid()).ToString()

                $DisplayName = $EmailAddress + "_SMTP"

                $Projection = @{__CLASS = "System.Domain.User";
                                __SEED = $objAffectedUser;
                                Notification = @{__CLASS = "System.Notification.Endpoint";
                                                __OBJECT = @{Id = $NewGUID;
                                                            DisplayName = $DisplayName;
                                                            ChannelName = "SMTP";
                                                            TargetAddress = $EmailAddress;
                                                            Description = $EmailAddress;
                                                }
                                }
                }

                New-SCSMObjectProjection -Type "System.User.Preferences.Projection" -Projection $Projection

            }

            # Return the created user object
            Return $objAffectedUser
        }
    }
    catch{
        Throw "Get-UserByEmail: $($_)"
    }

}