//Convert Incident to Service Request
app.custom.formTasks.add('Incident', "Convert IR to SR", function (formObj, viewModel) {
    $.when(kendo.ui.ExtYesNoDialog.show({
        title: "Convert Incident to Service Request",
        message: "Are you sure you want to convert this Incident to a Service Request?"
    })
    ).done(function (response) {
        if (response.button === "yes") {
         function RunRemote()   
          {  
		var opt; 
		opt = viewModel.Id
		opt2 = session.user.UserName
		var paramJsonShort = {
                "RunbookId": "a1db510e-4d43-43e4-9150-3e9ea336431e",
                "Parameters": "<Data><Parameter><ID>{77c79478-ed8b-41fb-a509-4efa310a6858}</ID><Value>"+ opt + "</Value></Parameter><Parameter><ID>{9292da0d-116e-4010-aab2-028f3eb7a559}</ID><Value>"+ opt2 + "</Value></Parameter></Data>"
            }
            var JobID;
	    var datastring = JSON.stringify(paramJsonShort);
            var orchurl = 'http://ORCHESTRATORSERVER.Domain.Com:81/Orchestrator2012/Orchestrator.svc/Jobs';
	    var newActionLog = {
                    EnteredBy: session.user.Name,
                    Title: localization.Analyst + " " + localization.Comment,
                    IsPrivate: false,
                    EnteredDate: new Date().toISOString().split(".")[0],
                    LastModified: new Date().toISOString().split(".")[0],
                    Description: "Request to convert Incident to Service Request has been submitted.",
                    Image: app.config.iconPath + app.config.icons["comment"],
                    ActionType: "AnalystComment"
                }
            $.ajax({
                url: orchurl,
                async: true,
                contentType: "application/json; charset=utf-8",
                type: "POST",
                data: datastring,
                dataType: 'json',
		success: function (json) {
                    JobID = json.d.Id;
		    alert("Your Request has been submitted.");
		    actionLogModel.push(newActionLog);
			save();
		},
                error: function (json) {
                    alert(datastring + " || " + json.responseText);
		    var newActionLogError = {
                    	EnteredBy: session.user.Name,
                    	Title: localization.Analyst + " " + localization.Comment,
                    	IsPrivate: false,
                    	EnteredDate: new Date().toISOString().split(".")[0],
                    	LastModified: new Date().toISOString().split(".")[0],
                    	Description: "Request to IR to an SR failed to submit.   The following is the returned error: " + datastring + " || " + json.responseText,
                    	Image: app.config.iconPath + app.config.icons["comment"],
                    	ActionType: "AnalystComment"
                	}
			actionLogModel.push(newActionLogError);
			save();
                }
            });
           }
	        var vm = pageForm
		var save = function () {
                //save/apply the current changes
                vm.save(function (data) {
                    app.lib.message.add(localization.ChangesApplied, "success");
                    switch (vm.type) {
                        case "ChangeRequest":
                            location.href = "/ChangeRequest/Edit/" + vm.viewModel.Id + "/";
                            break;
                        case "ServiceRequest":
                            location.href = "/ServiceRequest/Edit/" + vm.viewModel.Id + "/";
                            break;
                        case "Incident":
                            location.href = "/Incident/Edit/" + vm.viewModel.Id + "/";
                            break;
                        case "ReleaseRecord":
                            location.href = "/ReleaseRecord/Edit/" + vm.viewModel.Id + "/";
                            break;
                        case "Problem":
                            location.href = "/Problem/Edit/" + vm.viewModel.Id + "/";
                            break;
                        default:
                            location.href = "/WorkItems/MyItems/";
                            break;
                    		}
               		 }, saveFailure);
            		}

            var saveFailure = function (exceptionMessage) {
                if (exceptionMessage == localization.RequiredFieldsErrorMessage) {
                    app.lib.message.add(exceptionMessage, "danger");
                } else {
                    //fallback to generic message
                    app.lib.message.add(localization.PleaseCorrectErrors, "danger");
                }
                app.lib.message.show();
            }  
         RunRemote() 
 }
    });
    return;
});