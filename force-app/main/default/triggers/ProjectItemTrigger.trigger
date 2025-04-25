trigger ProjectItemTrigger on Project_Item__c (before update, after update) {
    if(trigger.isBefore && trigger.isUpdate){
        ProjectItemTriggerHandler.onBeforeUpdate(trigger.new, trigger.oldMap);
    }
    if(trigger.isAfter && trigger.isUpdate){
        ProjectItemTriggerHandler.onAfterUpdate(trigger.new, trigger.oldMap);
    }
}