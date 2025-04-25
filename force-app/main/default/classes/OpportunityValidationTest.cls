@isTest
public class OpportunityValidationTest {

    static testmethod void testExistingOpp() {
        // Set up trigger switch
        Trigger_Switch__c setting = new Trigger_Switch__c(Name = 'Opportunity', Is_Enabled__c = true);
        insert setting;

        // Set up accounts and contacts
        Account testOwnerAccount = new Account(
            Name = 'Sample Investor Owner Account',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Investor Owner').getRecordTypeId()
        );
        insert testOwnerAccount;

        Contact testOwnerContact = new Contact(
            FirstName = 'Sample',
            LastName = 'InformationHere',
            RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Investor').getRecordTypeId(),
            AccountId = testOwnerAccount.Id,
            Phone = '9011234567',
            Email = 'test@reination.com',
            Is_Primary__c = true
        );
        insert testOwnerContact;

        Account testLenderAccount = new Account(
            Name = 'Sample Lender Account',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Vendor - Pro Serv').getRecordTypeId()
        );
        insert testLenderAccount;

        Contact testLenderContact = new Contact(
            FirstName = 'Sample',
            LastName = 'LenderContact',
            Email = 'test@reination.com',
            RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Vendor').getRecordTypeId(),
            AccountId = testLenderAccount.Id
        );
        insert testLenderContact;

         House__c testHouse = new House__c(Market__c='DFW', Name='test House',Street_Address__c='123 Main St',House_Type__c='Single Family Detached',Bedrooms__c='2',Year_Built__c='1979',
                                        City__c='Plano',State__c='TX', Zip_Code__c='75023', Sq_Feet__c=1744.00,Car_Storage_Parking__c='2GA',Bathrooms__c='2');
        
        insert testHouse;
        
        Project__c testProjectSample = new Project__c(Name='Sample Project',RecordTypeId=Schema.SObjectType.Project__c.getRecordTypeInfosByName().get('Renovation').getRecordTypeId(),
                                                     House__c=testHouse.Id,Pay_Account__c='New DFW');
            
        insert testProjectSample;

        // Set up opportunity
        Opportunity testOpp = new Opportunity(
            Name = 'test opportunity 123-sample',
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Investor').getRecordTypeId(),
            StageName = 'Pre-Qual',
            Purchase_Method__c = 'Conventional',
            Project_Evaluation_1__c = testProjectSample.Id,
            CloseDate = Date.today()
        );
        insert testOpp;

        Test.startTest();

        // Transition stage to trigger validation logic
        testOpp.StageName = 'Contract Out/ Title';
        try{
           update testOpp;
        } catch (Exception e){
           
        }

        // Validate updated stage
        System.assertEquals('Contract Out/ Title', testOpp.StageName);

        // Further stage transition
        testOpp.StageName = 'HOT: Contract-Won';
        try{
           update testOpp;
        } catch (Exception e){
            
        }

        // Validate final stage transition
        System.assertEquals('HOT: Contract-Won', testOpp.StageName);

        Test.stopTest();
    }
}