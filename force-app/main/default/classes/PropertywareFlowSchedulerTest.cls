@isTest
private class PropertywareFlowSchedulerTest {
    @isTest
    static void testSchedulerScheduling() {
        Test.startTest();

        String jobId = System.schedule('Test Propertyware Job 0', '0 0 * * * ?', new PropertywareFlowScheduler());  // Minute 0

        Test.stopTest();
    }
}