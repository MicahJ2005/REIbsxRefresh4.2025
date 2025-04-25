@isTest
/**
    Name        : ProjectItemFromCaseExtnTest
    Date        : April 12, 2019
    Author      : Shweta Fulara(Cmentor)
    Description : This test class is used for code coverage of ProjectItemFromCaseExtn.
**/
public class ProjectItemFromCaseExtnTest {
    @testSetup 
    static void setup() {
        
        Account accVendor = TestDataFactory.createAccount('Investor acc', Schema.SObjectType.Account.getRecordTypeInfosByName().get('Vendor').getRecordTypeId(), '');
        insert accVendor;
        
        Contact conVendor = TestDataFactory.createContact('Vendor', 'Tester', '9879654321', 'testaccVendorsf@tester.com', accVendor.Id, 
            Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Vendor').getRecordTypeId()
        );
        insert conVendor;
        
        Account accInvestor = TestDataFactory.createAccount('Investor acc', Schema.SObjectType.Account.getRecordTypeInfosByName().get('Investor Prospect').getRecordTypeId(), '');
        insert accInvestor;
        
        Contact conInvestor = TestDataFactory.createContact('Investor', 'Tester', '9879654321', 'testInvestorsf@tester.com', accInvestor.Id, 
            Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Investor').getRecordTypeId()
        );
        insert conInvestor;
        
        House__c house = TestDataFactory.createHouse('Test Property', 'Test Property', 'Test Streeet', 'Memphis', 'TN', '39876', 'US');
        house.Investor__c = accInvestor.Id;
        insert house;
        
        Account acc = TestDataFactory.createAccount('Owner acc', Schema.SObjectType.Account.getRecordTypeInfosByName().get('Resident').getRecordTypeId(), '');
        insert acc;
        
        Contact con = TestDataFactory.createContact('Test', 'Tester', '9879654321', 'testsf@tester.com', acc.Id, 
            Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Resident').getRecordTypeId()
        );
        insert con;
        
        Schema.DescribeFieldResult catGlobal = SObjectType.Case.fields.CategoryGlobal__c;
        List<Schema.PicklistEntry> categoryEntries = catGlobal.getPicklistValues();

        Case cs = TestDataFactory.createCase(Schema.SObjectType.Case.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId(), 'Open', 
            con.Id, house.Id, 'Test desc.', '9998887878', System.now(), false, System.now().addMonths(1), categoryEntries[0].getValue()
        );
        insert cs;
    }
    
    @isTest
    static void testMethod1(){
        
        Case cs = [SELECT Id, Status FROM Case LIMIT 1]; 
        
        PageReference pageRef = Page.ProjectItemFromCase;
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(cs);
        ProjectItemFromCaseExtn projectItemCase = new ProjectItemFromCaseExtn(sc);
        projectItemCase.createProjectItem();
        
        cs.Status = 'Closed';
        update cs;
        
        sc = new ApexPages.StandardController(cs);
        projectItemCase= new ProjectItemFromCaseExtn(sc);
        projectItemCase.createProjectItem();
    }
}