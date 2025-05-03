public with sharing class PropertyWareAPIUtilityScheduler implements Schedulable, Database.AllowsCallouts{
    public void execute(SchedulableContext sc) {
        System.enqueueJob(new PropertyWareAPIUtility());
    }
}