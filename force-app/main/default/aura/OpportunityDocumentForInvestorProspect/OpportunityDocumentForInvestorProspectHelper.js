({
    doinit : function (cmp, event,helper){
        
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
    
})