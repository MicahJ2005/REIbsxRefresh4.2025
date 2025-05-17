@isTest
public class EmailMessageHandlerTest {
    @isTest
    static void testProcessEmailMessages() {
        // Create test Account
        Account acct = new Account(Name = 'Test Account', Customer_Service_Assignment__c = UserInfo.getUserId());
        insert acct;

        // Create test Contact with type 'Investor' and email
        Contact investor = new Contact(
            FirstName = 'Test',
            LastName = 'Investor',
            Email = 'investor@example.com',
            // Type__c = 'Investor',
            AccountId = acct.Id
        );
        insert investor;

        // Create test Case
        Case c = new Case(Status = 'New', Origin = 'Email');
        insert c;

        // Create test EmailMessage
        EmailMessage em = new EmailMessage(
            ParentId = c.Id,  // Linking to the Case
            ToAddress = 'investor@example.com',
            CcAddress = null,
            Subject = 'Test Subject',
            FromAddress = 'sender@example.com',
            Incoming = true,
            Status = '3',  // Draft
            TextBody = 'Test email body'
        );
        insert em;

        // Call method under test
        Test.startTest();
        EmailMessageHandler.processEmailMessages(new List<EmailMessage>{ em });
        Test.stopTest();

        // Retrieve the updated Case
        Case updatedCase = [SELECT Id, ContactId, AccountId, OwnerId FROM Case WHERE Id = :c.Id];

        // Assertions
        System.assertEquals(investor.Id, updatedCase.ContactId, 'Contact should be linked');
        System.assertEquals(acct.Id, updatedCase.AccountId, 'Account should be linked');
        System.assertEquals(acct.Customer_Service_Assignment__c, updatedCase.OwnerId, 'Owner should be assigned from account');
    }

    @isTest
    static void testNoMatchingContacts() {
        // Create Case
        Case c = new Case(Status = 'New', Origin = 'Email');
        insert c;

        // Email address not in any Contact
        EmailMessage em = new EmailMessage(
            ParentId = c.Id,
            ToAddress = 'nonexistent@example.com',
            CcAddress = null,
            Subject = 'Test',
            FromAddress = 'sender@example.com',
            Incoming = true,
            Status = '3',
            TextBody = 'Test email body'
        );
        insert em;

        // Call method under test
        Test.startTest();
        EmailMessageHandler.processEmailMessages(new List<EmailMessage>{ em });
        Test.stopTest();

        // Case should not be updated
        Case result = [SELECT ContactId, AccountId, OwnerId FROM Case WHERE Id = :c.Id];
        System.assertEquals(null, result.ContactId);
        System.assertEquals(null, result.AccountId);
        System.assertEquals(null, result.OwnerId);
    }
}
