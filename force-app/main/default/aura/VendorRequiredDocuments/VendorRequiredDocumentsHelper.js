({
    fetchAccountDetails: function(component, event, helper) {
        var action = component.get("c.getAccount");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var records =response.getReturnValue();
                component.set("v.dataAcc", records[0]);
            }
        });
        $A.enqueueAction(action);
    },
    fetchContentVersions: function(component, event, helper) {
        var action = component.get("c.getConVersionList");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var records =response.getReturnValue();
                console.log('records---'+records);
                records.forEach(function(record){
                    if(record.ContentDocumentId){
                        record.linkName = '/lightning/r/ContentDocument/'+record.ContentDocumentId+'/view';
                    }
                });
                component.set("v.data", records);
            }
        });
        $A.enqueueAction(action);
    }
})