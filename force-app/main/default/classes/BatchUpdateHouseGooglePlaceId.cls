global class BatchUpdateHouseGooglePlaceId implements Database.Batchable<SObject>, Database.AllowsCallouts {

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT Id, Name, PW_ID_Number__c, House_Complete_Address__c, Google_Place_ID__c 
            FROM House__c 
            WHERE Google_Place_ID__c = null
        ]);
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        List<House__c> housesToUpdate = new List<House__c>();

        for (SObject sObj : scope) {
            House__c house = (House__c) sObj;

            // Defensive check for address
            if (String.isNotBlank(house.House_Complete_Address__c)) {
                try {
                    String placeId = GooglePlacesService.getPlaceIdFromAddress(house.House_Complete_Address__c);
                    if (!String.isBlank(placeId)) {
                        house.Google_Place_ID__c = placeId;
                        housesToUpdate.add(house);
                    }
                } catch (Exception e) {
                    // Optional: log the error, or create an Error__c record, etc.
                    System.debug('Error retrieving Place ID: ' + e.getMessage());
                }
            }
        }

        if (!housesToUpdate.isEmpty()) {
            update housesToUpdate;
        }
    }

    global void finish(Database.BatchableContext BC) {
        // Optional: email, log, or notify admin
    }
}
