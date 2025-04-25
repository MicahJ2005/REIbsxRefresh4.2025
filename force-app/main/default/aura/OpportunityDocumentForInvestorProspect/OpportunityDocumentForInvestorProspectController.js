({
    handleUploadFinished: function (cmp, event,helper) {
        // Get the list of uploaded files
        var uploadedFiles = event.getParam("files");
        
        var action = cmp.get("c.updateFileType");
        action.setParams({fileName: uploadedFiles[0].name,
                          ContentDocumentId : uploadedFiles[0].documentId,
                          Field : event.getSource().getLocalId(),
                          OpportunityId : cmp.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.opportunityRec" , response.getReturnValue());
                console.log(cmp.get("v.opportunityRec"));
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
        
        
    },
    
    oppsendEmail :function(cmp,event,helper){
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url":"/apex/SendEmailOpportunity?id=" + cmp.get("v.recordId")
        });
        urlEvent.fire();
    }, openFile4 :function(cmp,event,helper){
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url":"/lightning/r/ContentDocument/" + cmp.get("v.opportunityRec").Contract_Document_4Id__c + "/view"
        });
        urlEvent.fire();
    }, openFile5 :function(cmp,event,helper){
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url":"/lightning/r/ContentDocument/" + cmp.get("v.opportunityRec").Contract_Document_5Id__c + "/view"
        });
        urlEvent.fire();
    }, openFile6 :function(cmp,event,helper){
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url":"/lightning/r/ContentDocument/" + cmp.get("v.opportunityRec").Contract_Document_6Id__c + "/view"
        });
        urlEvent.fire();
    }, openFile7 :function(cmp,event,helper){
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url":"/lightning/r/ContentDocument/" + cmp.get("v.opportunityRec").Contract_Document_7Id__c + "/view"
        });
        urlEvent.fire();
    }, openFile8 :function(cmp,event,helper){
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url":"/lightning/r/ContentDocument/" + cmp.get("v.opportunityRec").Contract_Document_8Id__c + "/view"
        });
        urlEvent.fire();
    }, openFile9 :function(cmp,event,helper){
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url":"/lightning/r/ContentDocument/" + cmp.get("v.opportunityRec").Contract_Document_9Id__c + "/view"
        });
        urlEvent.fire();
    }, 
    
    doInit : function (cmp, event,helper){
        
        var action = cmp.get("c.getOpportunityContractField");
        action.setParams({ OpportunityId : cmp.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
                cmp.set("v.opportunityRec" , response.getReturnValue());
                console.log(cmp.get("v.opportunityRec"));
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);  
    },
    
    oppsendEmailwithAttach : function (cmp, event,helper){
        console.log('oppRec'+cmp.get("v.opportunityRec"));
        var action = cmp.get("c.sendEmailwithAttach");
        
        action.setParams({ "oppty" : cmp.get("v.opportunityRec")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.opportunityRec" , response.getReturnValue());
                console.log(cmp.get("v.opportunityRec"));
                helper.doinit(cmp, event,helper);
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    }
})