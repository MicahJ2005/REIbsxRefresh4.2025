({
    openPop : function(component, event, helper) {
        var cmpTarget = component.find('pop');
        $A.util.addClass(cmpTarget, 'slds-show');
        $A.util.removeClass(cmpTarget, 'slds-hide');
        
    },
    
    closePop : function(component, event, helper) {
        var cmpTarget = component.find('pop');
        $A.util.addClass(cmpTarget, 'slds-hide');
        $A.util.removeClass(cmpTarget, 'slds-show');
        
    }
})