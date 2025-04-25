({
    doInit : function(component, event, helper) {
        
        var action = component.get("c.getChildAccountsWithPropertyOwner");
        component.set("v.status","Active");
        action.setParams({
            "recordId": component.get("v.recordId"),
            "status" :  component.get("v.status")
        });
        
        action.setCallback(this, function(response) {   
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();
                var arrayMapKeys = [];
                for(var key in result){
                    console.log('key'+key);
                    arrayMapKeys.push({key: key.split('-')[1],accId: '/'+key.split('-')[0] ,value: result[key]});
                }
                component.set("v.myMap", arrayMapKeys);
            }else if (state === "INCOMPLETE") {
                
            }else if (state === "ERROR") {
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
        $A.enqueueAction(action);  
    },
    
    onStatusChange:function(component,event,helper){
        var checkCmp = component.find("chkbox").get("v.value");
        if(checkCmp){
            component.set("v.status","All");
        }else{
            component.set("v.status","Active");
        }
        
        var action = component.get("c.getChildAccountsWithPropertyOwner");
        action.setParams({
            "recordId": component.get("v.recordId"),
            "status" :  component.get("v.status")
        });
        
        action.setCallback(this, function(response) {   
            var state = response.getState();
            if (state === "SUCCESS")
            {
                var result = response.getReturnValue();
                var arrayMapKeys = [];
                for(var key in result){
                    console.log('key'+key);
                    arrayMapKeys.push({key: key.split('-')[1],accId: '/'+key.split('-')[0] ,value: result[key]});
                }
                component.set("v.myMap", arrayMapKeys);
                $A.get('e.force:refreshView').fire();
            }else if (state === "INCOMPLETE") 
            {
                
            }else if (state === "ERROR") 
            {
                var errors = response.getError();
                if (errors) 
                {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                }else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    }
})