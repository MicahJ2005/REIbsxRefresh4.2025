/**
 * @description       : 
 * @author            : Michael Lloyd (Demand Chain)
 * @group             : 
 * @last modified on  : 01-27-2022
 * @last modified by  : Michael Lloyd (Demand Chain)
**/
@isTest
private class VendorPortalHeaderControllerTest {
    @isTest(SeeAllData=true) static void test(){
        UserRole userRole_1 = [Select Id From UserRole Where DeveloperName = 'Executives' Limit 1];
        Profile communityProfile = [SELECT Id FROM Profile where Name= 'Vendor Community Login' Limit 1];
        
        User admin = [SELECT Id, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId=: userRole_1.Id AND IsActive = true LIMIT 1];
        
        User usr;        
        
        System.RunAs(admin) {       
            
            List<Account> accList = new List<Account>();
            accList.add(new Account(Name ='Test acc',Type = 'Rehab & Maintenance',            
                                    Temp_Market__c ='MEM; DFW;',Website = 'test',ShippingStreet = 'Memphis', ShippingCity = 'test', ShippingState = 'TN', ShippingPostalCode = '38115',                            
                                    Approval_Status__c = 'In Process',Vendor_Email__c = 'test@gmail.com',Phone = '1234567890', Market__c = 'MEM;STL',SSN__c = '123456',
                                    Category_1__c = 'Cages;Carpet', Rehab_Contractor_Trade_s__c = 'Cages;Carpet', Maint_Category_1__c = 'Cages;Carpet', Property_Maintenance_Trade_s__c = 'Cages', 
                                    Temp_DL_Exp_Date__c = system.today(), DL_Exp_Date__c = system.today(), Temp_Liab_Exp_Date__c = system.today(), Liab_Exp_Date__c = system.today(), 
                                    Temp_Wk_Comp_Exp_Date__c = system.today(),Wk_Comp_Exp_Date__c = system.today(),                           
                                    Home_Depot_Rapid_Pass_Acknowledgement__c=true,Legal_Acknowledgment__c=true,
                                    RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.AccVendorRecType).getRecordTypeId()
                                   ));            
            insert accList;
            
            Contact con1 = new Contact(AccountId=accList[0].Id, FirstName='Test',LastName='Tester',Is_Primary__c = true, Phone='9879654321', Email='testsf@tester.com',
                                       SSN__c = '12345678',Department__c = 'Administration',HomePhone = '1234567890',MobilePhone = '1234567890',
                                       MailingStreet = 'test',MailingCity = 'test', MailingState = 'test',MailingPostalCode = 'test',MailingCountry = 'test'
                                      );
            insert con1;
            
            Contact con2 = new Contact(AccountId=accList[0].Id, FirstName='Test',LastName='Tester1', Phone='9879654351', Email='test1sf@tester.com',
                                       Department__c = 'Administration'
                                      );
            insert con2;
            
            usr = new User(
                Username = System.now().millisecond() + 'test12345@test.com',
                ContactId = con1.Id,
                ProfileId = communityProfile.Id,
                //AccountId__c = acc1.id,
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
            test.setCurrentPage(Page.VendorPortalPayable);
            VendorPortalHeaderController cMethod = new VendorPortalHeaderController();
            cMethod.file = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAAdCAIAAADkY5E+AAAAD0lEQVR42mNg0AthoDMGAE1BDruZMRqXAAAAAElFTkSuQmCC';
            cMethod.displayPopup = true;
            cMethod.upload();
        }
    }
}