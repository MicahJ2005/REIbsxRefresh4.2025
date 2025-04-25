({
	doInit : function(component, event, helper) {
		var action = component.get("c.returnInvestorAccountRelatedOpportunities");
        action.setParams({
            "opportunityId": component.get("v.recordId")
            
        });
        
        // Register the callback function
        action.setCallback(this, function(response) {   
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.opportunityList" , response.getReturnValue());
            }else if (state === "INCOMPLETE") {
                // do something
            } else if (state === "ERROR") {
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
        
        // Invoke the service
        $A.enqueueAction(action);
    }
})