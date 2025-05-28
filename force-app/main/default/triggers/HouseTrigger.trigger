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
        // GooglePlacesService.getPlaceIdFromHouseRecordId(Trigger.newMap, );
        if(!Test.isRunningTest()){
            System.enqueueJob(new HouseCalloutQueueable(Trigger.newMap.keySet(), new set<Id>()));
        }
    }
    if (Trigger.isUpdate && Trigger.isBefore){
        objHouseTriggerHandler.onBeforeUpdate(Trigger.new,Trigger.oldMap);
    }
    if (Trigger.isUpdate && Trigger.isAfter){
        objHouseTriggerHandler.updateAccountInformation(Trigger.newMap, Trigger.oldMap);
        // GooglePlacesService.getPlaceIdFromHouseRecordId(Trigger.newMap, Trigger.oldMap);
        set<Id> IdsToSend = new set<Id>();
        for(House__c house : Trigger.newMap.values()){
            if(Trigger.oldMap.get(house.id).Google_Place_ID__c == null && house.Google_Place_ID__c == null){
                IdsToSend.add(house.id);
            }
        }
        if(IdsToSend.size() > 0){
            if(!Test.isRunningTest()){
                System.enqueueJob(new HouseCalloutQueueable(IdsToSend, Trigger.oldMap.keySet()));
            }
        }
    }
}