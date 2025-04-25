@istest
private class SchVendorDocumentExpiredBatchTest{
    @isTest
    static void  testMethod1() {
    
    Test.StartTest();
        SchVendorDocumentExpiredBatch sh1 = new SchVendorDocumentExpiredBatch();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test VendorDocumentExpiredBatch', sch, sh1);
        Test.stopTest();
    }
}