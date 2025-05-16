@isTest
public with sharing class PropertyWareLeaseAPISchedulerTest {
     @IsTest
    static void testExecute() {
        // Set up test context
        Test.startTest();

        // Instantiate the scheduler and call execute directly
        PropertyWareLeaseAPITexasScheduler scheduler = new PropertyWareLeaseAPITexasScheduler();
        scheduler.execute(null); // simulate scheduled job firing

        Test.stopTest(); // This will trigger the enqueued Queueable job

        // You can optionally add assertions here if your PropertyWareAPIUtility class does anything observable
        // e.g., check for created records, logs, etc.
    }

    @IsTest
    static void testExecute2() {
        // Set up test context
        Test.startTest();

        // Instantiate the scheduler and call execute directly
        PropertyWareLeaseAPIMemphisScheduler scheduler = new PropertyWareLeaseAPIMemphisScheduler();
        scheduler.execute(null); // simulate scheduled job firing

        Test.stopTest(); // This will trigger the enqueued Queueable job

        // You can optionally add assertions here if your PropertyWareAPIUtility class does anything observable
        // e.g., check for created records, logs, etc.
    }
}