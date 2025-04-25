/*
*   Executed:   Before insert
*   Purpose:    Set file department using folder department
*/
trigger FileTrigger on NEILON__File__c (before insert) {

    FileTriggerHandler objFileTriggerHandler = new FileTriggerHandler();
    if (Trigger.isInsert && Trigger.isBefore) {
        objFileTriggerHandler.onBeforeInsert(Trigger.new);
    }
}