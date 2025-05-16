public with sharing class PropertyWareLeaseAPIMemphisScheduler implements Schedulable, Database.AllowsCallouts{
    public void execute(SchedulableContext sc) {
        System.enqueueJob(new PropertyWareLeaseAPIMemphis());
    }
}