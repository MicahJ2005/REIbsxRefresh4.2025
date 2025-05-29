/*
*   Executed:   After insert
*   Purpose:    Create folder structure
*
* - Modifications:
* - Sophia Murphy (Demand Chain), 04/04/20224
* -			- Change parameters sent into updateAccountInformation
*/
trigger HouseTrigger on House__c (after insert , before Update, after Update) {
	// Start job to create folder strutcure
	HouseTriggerHandler objHouseTriggerHandler = new HouseTriggerHandler();
    
    if (Trigger.isInsert && Trigger.isAfter) {
        objHouseTriggerHandler.onAfterInsert(Trigger.newMap);
        objHouseTriggerHandler.updateAccountInformation(Trigger.newMap, null);
    }
    if (Trigger.isUpdate && Trigger.isBefore){
        objHouseTriggerHandler.onBeforeUpdate(Trigger.new,Trigger.oldMap);
    }
    if (Trigger.isUpdate && Trigger.isAfter){
        objHouseTriggerHandler.updateAccountInformation(Trigger.newMap, Trigger.oldMap);
    }
}