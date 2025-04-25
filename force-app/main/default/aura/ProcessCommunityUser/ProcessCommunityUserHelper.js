({
    processCommunityUser: function(component, event, helper) {
        var action = component.get("c.processUser");
        action.setParams({  
            "contactId": component.get("v.recordId")
        });
        console.log('In helper');
        action.setCallback(this, function(response) {
            console.log('response.getReturnValue()'+ response.getReturnValue());
            if (response.getState() == "SUCCESS") {
                if( response.getReturnValue() == 'User Created'){
                    
                    $A.get('e.force:refreshView').fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "User Record Created"
                    });
                    toastEvent.fire();
                    // 
                    $A.get("e.force:closeQuickAction").fire();
                }
                else if(response.getReturnValue() != null){
                    //$A.get('e.force:refreshView').fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": response.getReturnValue()
                    });
                    toastEvent.fire();
                    // 
                    $A.get("e.force:closeQuickAction").fire();
                } 
                
            } else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": response.getReturnValue()
                });
                toastEvent.fire();
                //$A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
    }
})