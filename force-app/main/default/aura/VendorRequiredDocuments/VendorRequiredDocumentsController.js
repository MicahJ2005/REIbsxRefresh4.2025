({
	init : function(component, event, helper) {
        component.set('v.columns', [
            {label: 'Required Doc', fieldName: 'Attachment_Type__c', type: 'Picklist'}, 
            {label: 'Attachment Type', fieldName: 'linkName', type: 'url', 
            typeAttributes: {label: { fieldName: 'Attachment_Type__c' }, target: '_blank'}},
            {label: 'Expiration Date', fieldName: 'Expiration_Date__c', type: 'date-local',editable: true},
            {label: 'Status', fieldName: 'Status__c', type: 'Picklist',editable: true}
        ]);
        component.set('v.columnsNonEdit', [
            {label: 'Attachment Type', fieldName: 'Attachment_Type__c', type: 'Picklist'}, 
            {label: 'Expiration Date', fieldName: 'Expiration_Date__c', type: 'date-local'},
            {label: 'Status', fieldName: 'Status__c', type: 'Picklist'}
        ]);
        helper.fetchAccountDetails(component, event, helper);
		helper.fetchContentVersions(component, event, helper);
	},
    handleSaveEdition: function (cmp, event, helper) {
        var draftValues = event.getParam('draftValues');
        console.log(draftValues);
        var action = cmp.get("c.updateFiles");
        action.setParams({"cvList" : draftValues});
        action.setCallback(this, function(response) {
            var state = response.getState();
            $A.get('e.force:refreshView').fire();
            
        });
        $A.enqueueAction(action);
        
        document.location.reload(true);
    }
})