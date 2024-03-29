﻿Import-Module SMLets

# This function adds a comment to the SR Action Log
# NOTE: SMlets must be loaded in order for the function to work

Function Add-SRComment {
    param (
        [parameter(Mandatory=$True,Position=0)]$SRObject,
        [parameter(Mandatory=$True,Position=1)]$Comment,
        [parameter(Mandatory=$True,Position=2)]$EnteredBy,
        [parameter(Mandatory=$False,Position=3)][switch]$AnalystComment,
        [parameter(Mandatory=$False,Position=4)][switch]$IsPrivate
    )

    try{      
        If ($AnalystComment) {
            $CommentClass = "System.WorkItem.TroubleTicket.AnalystCommentLog"
            $CommentClassName = "AnalystCommentLog"
        } else {
            $CommentClass = "System.WorkItem.TroubleTicket.UserCommentLog"
            $CommentClassName = "EndUserCommentLog"
        }

        # Generate a new GUID for the comment
        $NewGUID = ([guid]::NewGuid()).ToString()

        # Create the object projection with properties
        $Projection = @{__CLASS = "System.WorkItem.ServiceRequest";
                        __SEED = $SRObject;
                        EndUserCommentLog = @{__CLASS = $CommentClass;
                                            __OBJECT = @{Id = $NewGUID;
                                                        DisplayName = $NewGUID;
                                                        Comment = $Comment;
                                                        EnteredBy = $EnteredBy;
                                                        EnteredDate = (Get-Date).ToUniversalTime();
                                                        IsPrivate = $IsPrivate.ToBool();
                                            }
                        }
        }

        # Create the actual comment
        New-SCSMObjectProjection -Type "System.WorkItem.ServiceRequestProjection" -Projection $Projection
    }
    catch{
        Throw "Add-SRComment: $($_)"
    }
}