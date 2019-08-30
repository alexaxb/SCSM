Import-Module SMlets

$Projection = @{__CLASS = "System.WorkItem.Incident";
                __OBJECT = @{"Id" = "IR{0}";
                                "DisplayName" = "Test incident"; 
                                "Impact" = "Medium"; 
                                "Urgency" = "Medium"; 
                                "Title" = "Test incident"
                            }
                UserComments = @{__CLASS = "System.WorkItem.TroubleTicket.UserCommentLog";
                                 __OBJECT = @{"Id" = ([guid]::NewGuid()).ToString();
                                                    "Comment" = "This is a comment";
                                                    "DisplayName" = "This is a display name";
                                                    "EnteredBy" = "contoso\administrator";
                                                    "EnteredDate" = (Get-Date).ToUniversalTime()
                                             }
                                }
                }

New-SCSMObjectProjection -Type System.WorkItem.IncidentPortalProjection -Projection $Projection