({
    init : function(component, event, helper) {
        
        var action = component.get("c.getProjectRecord");
        
        action.setParams({
            "recordId": component.get("v.recordId")  
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state'+state);
            if(state === "SUCCESS") {
                component.set("v.record",response.getReturnValue());
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
        console.log('En Quier action ');
        $A.enqueueAction(action);
    },
    
    upload : function(component, event, helper) {
        
        var action = component.get("c.uploadHouse");
        
        action.setParams({
            project : component.get("v.record")  
        });
        
        component.set("v.loaded", true); 
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state'+state);
            if(state === "SUCCESS") {
                
                component.set("v.loaded", false); 
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'House has been successfully upload',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
                
                $A.get("e.force:closeQuickAction").fire();
                $A.get("e.force:refreshView").fire();
            }
            else if (state === "ERROR") {
                component.set("v.loaded", false); 
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Error',
                            message: errors[0].message,
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
                component.set("v.Spinner", false);
            } 
        });
        console.log('En Quier action ');
        $A.enqueueAction(action);
    },
    
    cancel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    

    
})