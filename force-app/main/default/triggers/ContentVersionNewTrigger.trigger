trigger ContentVersionNewTrigger on ContentVersion (after update) {
    if(trigger.isAfter && trigger.isUpdate){
        ContentVersionNewTriggerHandler.afterUpdate(trigger.new, trigger.oldMap);
    }
}