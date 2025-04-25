({
	doInit : function(component, event, helper) {
        
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                label: "Vendor Accounts With Document Expiring"
            });
        })
        
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
                workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "action:new_account",
                iconAlt: "new_account"
            });
        })
        .catch(function(error) {
            console.log(error);
        });
        
		var action = component.get('c.getaccountsWithDocsExpirationInfo');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS") {
                component.set("v.objWrapper", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	},
    
    recordRedirect : function(component, event, helper) {
        var recordId = event.target.dataset.caseid;
        window.open('/' + recordId);  
    },
    
    handleSectionToggle: function (cmp, event) {
        var openSections = event.getParam('openSections');

        if (openSections.length === 0) {
            cmp.set('v.activeSectionsMessage', "All sections are closed");
        } else {
            cmp.set('v.activeSectionsMessage', "Open sections: " + openSections.join(', '));
        }
    }
})