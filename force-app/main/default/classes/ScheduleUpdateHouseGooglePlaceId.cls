global class ScheduleUpdateHouseGooglePlaceId implements Schedulable {
    global void execute(SchedulableContext sc) {
        BatchUpdateHouseGooglePlaceId batch = new BatchUpdateHouseGooglePlaceId();
        Database.executeBatch(batch, 10); // 10 per batch to stay well under the 100-callout limit
    }
}