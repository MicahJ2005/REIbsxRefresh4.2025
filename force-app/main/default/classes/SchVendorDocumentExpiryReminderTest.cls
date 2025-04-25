@istest
private class SchVendorDocumentExpiryReminderTest{
    @isTest
    static void  testMethod1() {
    
    Test.StartTest();
        SchVendorDocumentExpiryReminder sh1 = new SchVendorDocumentExpiryReminder();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test VendorDocumentExpiryReminder', sch, sh1);
        Test.stopTest();
    }
}