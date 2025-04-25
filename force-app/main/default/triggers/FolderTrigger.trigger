/*
*   Executed:   Before insert
*   Purpose:    Set file department using parent folder department
*/
trigger FolderTrigger on NEILON__Folder__c (before insert) {
	FolderTriggerHandler objFolderTriggerHandler = new FolderTriggerHandler();
    if (Trigger.isInsert && Trigger.isBefore) {
        objFolderTriggerHandler.onBeforeInsert(Trigger.new);
    }
}