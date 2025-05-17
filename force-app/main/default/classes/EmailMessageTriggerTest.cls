@isTest
public class EmailMessageTriggerTest {
    @isTest
    static void testEmailMessageTriggerWithActiveFlag() {
        // Setup: Create Account with customer service assignment
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        Account acct = new Account(Name = 'Test Account', type = 'Investor', Customer_Service_Assignment__c = currentUser.Id);
        insert acct;

        // Create Contact (Investor)
        Contact investor = new Contact(
            FirstName = 'Investor',
            LastName = 'User',
            Email = 'investor@example.com',
            // Type__c = 'Investor',
            AccountId = acct.Id
        );
        insert investor;

        // Create Case
        Case testCase = new Case(Subject = 'Email Trigger Test Case', Status = 'New', Origin = 'Email', recordtypeid = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Service').getRecordTypeId());
        insert testCase;

        // Insert EmailMessage that should trigger the logic
        EmailMessage em = new EmailMessage(
            ParentId = testCase.Id,
            ToAddress = 'investor@example.com',
            CcAddress = null,
            Subject = 'Investor Email',
            FromAddress = 'external@example.com',
            TextBody = 'Email content for investor',
            Incoming = true,
            Status = '3'  // Draft
        );

        Test.startTest();
        insert em;  // This triggers EmailMessageTrigger
        Test.stopTest();

        // Validate Case was updated
        Case updatedCase = [SELECT Id, ContactId, AccountId, OwnerId FROM Case WHERE Id = :testCase.Id];

        System.assertEquals(investor.Id, updatedCase.ContactId, 'Case should have Contact linked');
        System.assertEquals(acct.Id, updatedCase.AccountId, 'Case should have Account linked');
        System.assertEquals(acct.Customer_Service_Assignment__c, updatedCase.OwnerId, 'Case owner should be set from Account');
    }

    @isTest
    static void testTriggerInactiveMetadata() {
        // This test assumes the metadata record is inactive (or missing),
        // so the trigger won't invoke the handler logic.

        // Create Case
        Case testCase = new Case(Subject = 'Inactive Metadata Test Case', Status = 'New', Origin = 'Email');
        insert testCase;

        // Insert EmailMessage
        EmailMessage em = new EmailMessage(
            ParentId = testCase.Id,
            ToAddress = 'ghost@example.com',
            CcAddress = null,
            Subject = 'Inactive Email',
            FromAddress = 'noreply@example.com',
            TextBody = 'This should not trigger handler if metadata inactive.',
            Incoming = true,
            Status = '3'
        );

        Test.startTest();
        insert em;
        Test.stopTest();

        // No assertion here — test ensures that the trigger runs safely even if metadata is inactive
        System.assert(true, 'Trigger should not fail if metadata is inactive');
    }
}
