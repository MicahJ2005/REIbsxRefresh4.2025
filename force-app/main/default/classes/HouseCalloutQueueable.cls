public class HouseCalloutQueueable implements Queueable, Database.AllowsCallouts {
    private Set<Id> oldIds;
    private Set<Id> newIds;

    public HouseCalloutQueueable(Set<Id> newIds, Set<Id> oldIds) {
        this.oldIds = oldIds;
        this.newIds = newIds;
    }

    public void execute(QueueableContext context) {
        // Re-query the records as needed
        Map<Id, House__c> oldRecords = new Map<Id, House__c>([
            SELECT Id, Name, House_Complete_Address__c, Google_Place_ID__c FROM House__c WHERE Id IN :oldIds
        ]);
        Map<Id, House__c> newRecords = new Map<Id, House__c>([
            SELECT Id, Name, House_Complete_Address__c, Google_Place_ID__c FROM House__c WHERE Id IN :newIds
        ]);

        GooglePlacesService.getPlaceIdFromHouseRecordId(newRecords, oldRecords);
        
    }
}
