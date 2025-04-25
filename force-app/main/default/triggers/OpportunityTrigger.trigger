trigger OpportunityTrigger on Opportunity (before update, before insert, after Update, after Insert) {
    
    OpportunityTriggerHandler.newList = Trigger.new;
    OpportunityTriggerHandler.oldList = Trigger.old;
    OpportunityTriggerHandler.newMap = Trigger.newMap;
    OpportunityTriggerHandler.oldMap = Trigger.oldMap;
    
    Trigger_Switch__c triggerSwitch = Trigger_Switch__c.getInstance('Opportunity');
    System.debug('triggerSwitch'+triggerSwitch);
    
    if(triggerSwitch.Is_Enabled__c){
        if(Trigger.isBefore){
            if(Trigger.isUpdate){
                OpportunityTriggerHandler.beforeUpdate();
            }else if(Trigger.isInsert){
                OpportunityTriggerHandler.beforeInsert();
            }
            
        }               
        if(Trigger.isAfter){
            if(Trigger.isUpdate){
                OpportunityTriggerHandler.afterUpdate();
            }else if(Trigger.isInsert){
                OpportunityTriggerHandler.afterInsert();
            }
        }
     
		if(Trigger.isUpdate){
			OpportunityTriggerValidationHelper.requiredOppStageValidation(trigger.new);
        }
    }
    
    /* if(Trigger.isBefore && Trigger.isInsert){
OpportunityTriggerHandler.beforeInsert();
}*/
    
}