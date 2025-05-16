public with sharing class PropertyWareLeaseAPITexasScheduler implements Schedulable, Database.AllowsCallouts{
    public void execute(SchedulableContext sc) {
        System.enqueueJob(new PropertyWareLeaseAPITexas());
    }
}