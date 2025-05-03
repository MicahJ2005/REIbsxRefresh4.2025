public with sharing class PropertyWareAPIUtility2Scheduler implements Schedulable, Database.AllowsCallouts{
    public void execute(SchedulableContext sc) {
        System.enqueueJob(new PropertyWareAPIUtility2());
    }
}