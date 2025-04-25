({
    doInit : function(component, event, helper) {
        var OpprecordId = '';
        if(component.get("v.recordId") != undefined || component.get("v.recordId") != null)
        	OpprecordId = component.get("v.recordId");
        else
		 OpprecordId = component.get("v.OpprecordId");            
        var action = component.get("c.getHouse");
        action.setParams({
            "opportunityId": OpprecordId
        });
        
        // Register the callback function
        action.setCallback(this, function(response) {   
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.HouseRecordList" , response.getReturnValue());
                var saCount = 0;
                var saTotal = 0;
                var rentCount = 0;
                var rentTotal = 0;
                
                
                for(var x in response.getReturnValue()){
                    if(response.getReturnValue()[x].Appraised_SqFt__c >= 1){
                        saCount += 1;
                        saTotal += response.getReturnValue()[x].Appraised_SqFt__c;
                    } 
                    else if (response.getReturnValue()[x].Sale_Amount_SqFt__c >= 1){
                        saCount += 1;
                        saTotal += response.getReturnValue()[x].Sale_Amount_SqFt__c;
                    }
                    if(response.getReturnValue()[x].Rent_SqFt__c > 0){
                        rentCount += 1;
                        rentTotal += response.getReturnValue()[x].Rent_SqFt__c;
                    }
                }
                
                    component.set("v.SAAvg", saTotal/saCount);
                    component.set("v.RentAvg",rentTotal/rentCount);
                    
            }else if (state === "INCOMPLETE") {
                // do something
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
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