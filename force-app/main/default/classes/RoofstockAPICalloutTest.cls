@isTest
private class RoofstockAPICalloutTest {
    
    @testSetup
    static void create_testData() {
        RoofstockRestAPI__c cs = new RoofstockRestAPI__c();
        cs.Name = 'Roofstock';
        cs.End_Point__c = 'https://staging-api.roofstock.com';
        cs.Password__c = 'Rstest123$';
        cs.Username__c = 'mcarmichael@reination.com';
        Insert cs;
    }
    
    @isTest
    static void test_getJwtTocket() {
        Test.startTest();
        RoofstockAPICallout.supply();
        Test.stopTest();
    }
}