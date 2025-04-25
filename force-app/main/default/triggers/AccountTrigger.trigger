/**
    Name        : AccountTrigger 
    Date        : 
    Author      : Shweta Fulara(Cmentor)
    Description : Trigger on Account.
**/
trigger AccountTrigger on Account (before insert, after insert, before update, after update) {
    
    if(trigger.isBefore && trigger.isInsert){
        AccountTriggerHandler.onBeforeInsert(trigger.new);
    }
    //Set Record Type of Contacts created from Resident Lead
    if(trigger.isAfter && trigger.isInsert){
        AccountTriggerHandler.onAfterInsert(trigger.new);
    }
    
    if(trigger.isBefore && trigger.isUpdate){
        AccountTriggerHandler.onBeforeUpdate(trigger.new, trigger.oldMap);
        AccountTriggerHandler.vendorAccountApprovalRequestEmailAlert(trigger.new, trigger.oldMap);
    }   
    
    
    if(trigger.isAfter && trigger.isUpdate){
        AccountTriggerHandler.onAfterUpdate(trigger.new, trigger.oldMap);
        AccountTriggerHandler.onAfterUpdateAppStatus(Trigger.New, trigger.oldMap);
        AccountTriggerHandler.onAfterInsert(trigger.new);
    }   
    
}