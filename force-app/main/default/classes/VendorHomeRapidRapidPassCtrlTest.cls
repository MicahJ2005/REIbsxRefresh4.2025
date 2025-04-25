/**
    Name        : VendorHomeRapidRapidPassCtrlTest
    Date        : August 21, 2019
    Author      : Shweta Fulara
    Description : This test class is used to cover VendorHomeRapidRapidPassCtrl class
**/
@isTest
private class VendorHomeRapidRapidPassCtrlTest {

     //This method cover project item object and Accounting seed object 
    @isTest
    static void testMethod1() {
        UserRole userRole_1 = [Select Id From UserRole Where DeveloperName = 'Executives' Limit 1];
        Profile communityProfile = [SELECT Id FROM Profile where Name= 'Vendor Community Login' Limit 1];
        
        User admin = [SELECT Id, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId=: userRole_1.Id AND IsActive = true LIMIT 1];
        
        User usr;
        
        Portal_Message__c msg = new Portal_Message__c(Message__c='test Home Depot', Notify__c='Community', 
            Start_Date__c=System.today(), End_Date__c=System.today().addYears(55), Portal__c='Vendor'
        );
        insert msg;
        
        System.RunAs(admin) {
        
            Account acc1 = new Account(Name ='Test acc');
            insert acc1;
            
            Contact con1 = new Contact(AccountId=acc1.Id, FirstName='Test',LastName='Tester', Phone='9879654321', Email='testsf@tester.com');
            insert con1;
            
            usr = new User(
            Username = System.now().millisecond() + 'test12345@test.com',
            ContactId = con1.Id,
            ProfileId = communityProfile.Id,
            //UserRoleId = portalRole.id,
            Alias = 'test123',
            Email = 'test12345@test.com',
            EmailEncodingKey = 'UTF-8',
            Firstname = 'Test',
            LastName = 'McTesty',
            CommunityNickname = 'test12345',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            IsActive = TRUE
            );
            Database.insert(usr);
        
        }
        
         System.runAs(usr){
             PageReference pageRef = Page.VendorHomeDepotRapidPass; // Add your VF page Name here        
             Test.setCurrentPage(pageRef);
             VendorHomeRapidRapidPassCtrl vendorRapidPass= new VendorHomeRapidRapidPassCtrl();        
         }
    }
}