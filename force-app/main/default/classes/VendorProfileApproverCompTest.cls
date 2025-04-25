@isTest
private class VendorProfileApproverCompTest {
    @testSetup static void setup(){
        List<Account> accList = new List<Account>();
        accList.add(
            new Account(
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(label.AccVendorRecType).getRecordTypeId(),
                Name = 'Test',
                Market__c = 'MEM',
                Status__c = 'Active',
                Temp_Market__c = 'MEM',
                Maint_Category_1__c = 'Cages',
                Property_Maintenance_Trade_s__c = 'Carpet',
                Category_1__c = 'Cleaning',
                Rehab_Contractor_Trade_s__c = 'Electrical'
            ));
        accList.add(
            new Account(
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(label.AccVendorRecType).getRecordTypeId(),
                Name = 'Test1',
                Market__c = 'MEM',
                Status__c = 'Active',
                Temp_Market__c = 'MEM',
                Maint_Category_1__c = 'Cleaning',
                Property_Maintenance_Trade_s__c = 'Cages',
                Category_1__c = 'Cleaning',
                Rehab_Contractor_Trade_s__c = 'Electrical',
                Account_Number__c = '1090'
            ));
        insert accList;        
    }
    @isTest static void method1(){
        List<Account> accList = [SELECT Id, Market__c, Temp_Market__c, Maint_Category_1__c, Property_Maintenance_Trade_s__c, 
                Category_1__c, Rehab_Contractor_Trade_s__c
                FROM Account ];
        system.assertEquals(2, accList.size());
        accList[0].Market__c = 'DFW';
        accList[0].Billing_Email__c = 'test@gmail.com';
        accList[1].Account_Number__c = '9999999';
        accList[1].Billing_Email__c = 'test1@gmail.com';
        update accList;
        
        
        VendorProfileApproverCompController cMethod = new VendorProfileApproverCompController ();
        cMethod.recordId = accList[0].Id;
        cMethod.isPrimary = true;
        cMethod.getAccHistory();
        
    }
}