trigger ApplicationTrigger on Application__c (before insert, before update) {
    if(trigger.isInsert && trigger.isBefore){
        ApplicationTriggerHandler.beforeInsert(trigger.new);
    }
    
    if(trigger.isUpdate && trigger.isBefore){
        ApplicationTriggerHandler.beforeUpdate(trigger.new);
    }
}