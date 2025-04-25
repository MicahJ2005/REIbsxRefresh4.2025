/**
Name        : VendorPortalAccountProfileControllerTest
Date        : July 17, 2019
Author      : Shweta Fulara
Description : This test class is used to cover VendorPortalAccountProfileController class
**/
@isTest
private class VendorPortalAccountProfileControllerTest {
    
    @isTest
    static void testMethod1() {
        
        
        UserRole userRole_1 = [Select Id From UserRole Where DeveloperName = 'Executives' Limit 1];
        Profile communityProfile = [SELECT Id FROM Profile where Name= 'Vendor Community Login' Limit 1];
        
        User admin = [SELECT Id, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId=: userRole_1.Id AND IsActive= true LIMIT 1];
        
        User usr;        
        
        System.RunAs(admin) {       
            Address_Verifier__c addrVerify = new Address_Verifier__c(City__c='Memphis', Abbreviation__c='TN', Zip_Code__c='38115');
            insert addrVerify;
            
            List<Account> accList = new List<Account>();
            accList.add(new Account(Name ='Test acc',Type = 'Rehab & Maintenance',            
                                    Temp_Market__c ='TUL; TUL;',Website = 'test',ShippingStreet = 'MemphisTest', ShippingCity = 'Memphis', ShippingState = 'TN1', ShippingPostalCode = '381151',                            
                                    Approval_Status__c = 'In Process',Vendor_Email__c = 'test@gmail.com',Phone = '(123) 456-7890', Market__c = 'MEM;STL',SSN__c = '1234567',
                                    Category_1__c = 'Windows;Foundation;Chimneys;Insulation', Rehab_Contractor_Trade_s__c = 'Windows;Windows', Maint_Category_1__c = 'Windows;Windows', Property_Maintenance_Trade_s__c = 'Windows', 
                                    Temp_DL_Exp_Date__c = system.today(), DL_Exp_Date__c = system.today(), Temp_Liab_Exp_Date__c = system.today(), Liab_Exp_Date__c = system.today(), 
                                    Temp_Wk_Comp_Exp_Date__c = system.today(),Wk_Comp_Exp_Date__c = system.today(),/*AcctSeed__Taxpayer_Identification_Number__c = '1234567',*/                            
                                    Home_Depot_Rapid_Pass_Acknowledgement__c=true,Legal_Acknowledgment__c=true,Is_Uploaded__c=true,
                                    RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.AccVendorRecType).getRecordTypeId()
                                   ));            
            insert accList;
            
            Contact con1 = new Contact(AccountId=accList[0].Id, FirstName='Test',LastName='Tester',Is_Primary__c = true, Phone='(987) 965-4321', Email='testsf@tester.com',
                                       SSN__c = '12345678',Department__c = 'Administration',HomePhone = '(123) 456-7890',MobilePhone = '(123) 456-7890',
                                       MailingStreet = 'test',MailingCity = 'test', MailingState = 'test',MailingPostalCode = 'test',MailingCountry = 'test'
                                      );
            insert con1;
            
            Contact con2 = new Contact(AccountId=accList[0].Id, FirstName='Test',LastName='Tester1', Phone='(987) 965-4321', Email='test1sf@tester.com',
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
            
            List<ContentVersion> cvList = new List<ContentVersion>();
            cvList.add(new ContentVersion(Title='Test', PathOnClient ='testing',VersionData=EncodingUtil.base64Decode('Unit Test Attachment Body'),
                                          FirstPublishLocationId=accList[0].Id,Attachment_Type__c = 'Direct Deposit Agreement',OwnerId=usr.Id,
                                          Expiration_Date__c = Date.today().addDays(45),Status__c= 'Uploaded'
                                         ));
            cvList.add(new ContentVersion(Title='Test2', PathOnClient ='testing2',VersionData=EncodingUtil.base64Decode('Unit Test Attachment Body1'),
                                          FirstPublishLocationId=accList[0].Id,Attachment_Type__c = 'Voided Check',OwnerId=usr.Id,
                                          Expiration_Date__c = Date.today().addDays(15),Status__c= 'Uploaded'
                                         ));
            cvList.add(new ContentVersion(Title='Test3', PathOnClient ='testing3',VersionData=EncodingUtil.base64Decode('Unit Test Attachment Body1'),
                                          FirstPublishLocationId=accList[0].Id,Attachment_Type__c = 'Certificate of Insurance - General Liability',
                                          Expiration_Date__c = Date.today().addDays(30),Status__c= 'Uploaded',OwnerId=usr.Id
                                         ));
            
            cvList.add(new ContentVersion(Title='Test4', PathOnClient ='testing4',VersionData=EncodingUtil.base64Decode('Unit Test Attachment Body1'),
                                          FirstPublishLocationId=accList[0].Id,Attachment_Type__c = 'Driver’s License/Photo Id',
                                          Expiration_Date__c = Date.today().addDays(45),Status__c= 'Uploaded',OwnerId=usr.Id
                                         )); 
            cvList.add(new ContentVersion(Title='Test5', PathOnClient ='testing5',VersionData=EncodingUtil.base64Decode('Unit Test Attachment Body1'),
                                          FirstPublishLocationId=accList[0].Id,Attachment_Type__c = 'Employment Visa',
                                          Expiration_Date__c = Date.today().addDays(45),Status__c= 'Uploaded',OwnerId=usr.Id
                                         )); 
            insert cvList;      
        }
        
        System.runAs(usr){
            
            User usr1 = [SELECT Id, AccountId__c FROM User WHERE Id =: usr.Id];
            
            Account acc1 = [SELECT Id, Bank_Name__c, Account_Type__c, Account_Number__c, Routing_Number__c,
                            BillingStreet, BillingCity, BillingState,BillingPostalCode, Billing_Email__c, Type
                            FROM Account LIMIT 1];
            
            List<Contact> conList = [SELECT Id, FirstName, LastName FROM Contact];
            List<ContentVersion> cvListNew = [SELECT Id, ContentDocumentId FROM ContentVersion];
            
            PageReference pageRef = Page.VendorPortalAccountProfile; // Add your VF page Name here        
            Test.setCurrentPage(pageRef);  
            ApexPages.currentPage().getParameters().put('listIndex' , '1');                  
            VendorPortalAccountProfileController vendorProfile = new VendorPortalAccountProfileController();
            vendorProfile.currentUserContactId = conList[0].Id;
            vendorProfile.currentUserAccountId = acc1.Id;
            vendorProfile.contactRollId = conList[0].Id;
            VendorPortalAccountProfileController.ContactWrapper vendorContactwrp = new VendorPortalAccountProfileController.ContactWrapper();
            VendorPortalAccountProfileController.ContentWrapper vendorContentwrp = new VendorPortalAccountProfileController.ContentWrapper();
            VendorPortalAccountProfileController.MarketWrapper vendorMarketwrp = new VendorPortalAccountProfileController.MarketWrapper(true, 'MEM', 'MEM');
            VendorPortalAccountProfileController.RehabTradeWrapper vendorRehabTradewrp = new VendorPortalAccountProfileController.RehabTradeWrapper(true, 'Cages', 'Cages');
            
            vendorProfile.langRehabContractorCheck = true;                                         
            vendorProfile.attachTypeVal = 'Voided Check';
            vendorProfile.expirationDate = String.valueOf(system.today());
            vendorProfile.marketString = '';
            vendorProfile.rehabCatString = '';
            vendorProfile.maintCatString = '';
            vendorProfile.error = 'test erroe';
            vendorProfile.noerror='noerror test';
            vendorProfile.attachId = cvListNew[1].Id;
            vendorProfile.attachFileFunction();
            vendorProfile.selectedContentId = cvListNew[1].ContentDocumentId;
            
            vendorProfile.addWrapperRow();
            vendorProfile.SpanishLangChange();
            vendorProfile.getDepartment();            
            vendorProfile.marketValues();
            vendorProfile.getattachmentTypes();
            vendorProfile.doCancel();            
            vendorProfile.callMethod();
            vendorProfile.callMethodNew(); 
            vendorProfile.doUpdateVendorProfile();                   
            vendorProfile.langRehabContractorCheck = false;
            vendorProfile.getDepartment();
            vendorProfile.doSubmitVendorProfile(); 
            vendorProfile.shippingAddressCheck = true;
            vendorProfile.shippingAddressCopy();
            vendorProfile.shippingAddressCheck = false;
            vendorProfile.shippingAddressCopy();
            
            
            vendorProfile.wrapperObj.accWrap.ShippingCity = 'MemphisABC';
            vendorProfile.doUpdateVendorProfile();   
            vendorProfile.doSubmitVendorProfile(); 
            
            vendorProfile.wrapperObj.accWrap.ShippingCity = 'Memphis';
            vendorProfile.wrapperObj.accWrap.ShippingState = '';  
            vendorProfile.wrapperObj.accWrap.ShippingPostalCode = '381151';
            vendorProfile.doUpdateVendorProfile();   
            vendorProfile.doSubmitVendorProfile(); 
            
            vendorProfile.wrapperObj.accWrap.ShippingCity = 'Memphis';
            vendorProfile.wrapperObj.accWrap.ShippingState = 'TN'; 
            vendorProfile.wrapperObj.accWrap.ShippingPostalCode = '381151';
            vendorProfile.doUpdateVendorProfile();   
            vendorProfile.doSubmitVendorProfile(); 
            
            vendorProfile.wrapperObj.accWrap.ShippingPostalCode = '38115';
            vendorProfile.wrapperObj.accWrap.BillingStreet = '';
            vendorProfile.wrapperObj.accWrap.BillingCity = 'Memphis1';
            vendorProfile.wrapperObj.accWrap.BillingState = 'TN1'; 
            vendorProfile.wrapperObj.accWrap.BillingPostalCode = '381151';
            vendorProfile.wrapperObj.accWrap.Billing_Email__c = 'test@test.com';
            vendorProfile.wrapperObj.primaryConWrap.LastName = 'Test';
            vendorProfile.wrapperObj.primaryConWrap.Email = '';
            vendorProfile.doUpdateVendorProfile();   
            vendorProfile.doSubmitVendorProfile(); 
            vendorProfile.bypassValidation=True;
            
            vendorProfile.wrapperObj.accWrap.Bank_Name__c = 'RBL';
            vendorProfile.wrapperObj.accWrap.Account_Type__c = 'Savings';
            vendorProfile.wrapperObj.accWrap.Routing_Number__c = '12345678';
            vendorProfile.wrapperObj.accWrap.Account_Number__c = '124612378234';
            vendorProfile.doUpdateVendorProfile();   
            vendorProfile.doSubmitVendorProfile(); 
            vendorProfile.submitForm();
            
            vendorProfile.wrapperObj.accWrap.Routing_Number__c = '123456789';
            vendorProfile.doUpdateVendorProfile();   
            vendorProfile.doSubmitVendorProfile(); 
            
            vendorProfile.wrapperObj.accWrap.BillingStreet = 'Test street';
            vendorProfile.doUpdateVendorProfile();   
            vendorProfile.doSubmitVendorProfile(); 
            
            vendorProfile.wrapperObj.accWrap.BillingCity = 'Memphis';
            vendorProfile.wrapperObj.accWrap.BillingState = 'TN1';
            vendorProfile.wrapperObj.accWrap.BillingPostalCode = '381151';
            Test.startTest();
            vendorProfile.doUpdateVendorProfile();   
            vendorProfile.doSubmitVendorProfile(); 
            
            vendorProfile.wrapperObj.accWrap.BillingState = '';
            vendorProfile.wrapperObj.accWrap.BillingPostalCode = '381151';
            vendorProfile.doUpdateVendorProfile();   
            vendorProfile.doSubmitVendorProfile(); 
            
            vendorProfile.wrapperObj.accWrap.BillingState = 'TN';
            vendorProfile.wrapperObj.accWrap.BillingPostalCode = '38115';
            vendorProfile.doUpdateVendorProfile();   

            vendorProfile.doSubmitVendorProfile(); 
            
            
            vendorProfile.wrapperObj.primaryConWrap.LastName = 'Tester';
            vendorProfile.doUpdateVendorProfile();
            
            vendorProfile.wrapperObj.primaryConWrap.Email = 'testing1@test.com';
            vendorProfile.doUpdateVendorProfile();  
            vendorProfile.wrapperObj.accWrap.Home_Depot_Rapid_Pass_Acknowledgement__c = false;
            vendorProfile.doSubmitVendorProfile(); 
            
            
            vendorProfile.attachId = cvListNew[0].Id;
            vendorProfile.attachFileFunction();
            vendorProfile.doUpdateVendorProfile();  
            vendorProfile.wrapperObj.accWrap.Home_Depot_Rapid_Pass_Acknowledgement__c = true;
            vendorProfile.doSubmitVendorProfile(); 
            
            vendorProfile.wrapperObj.conListWrap[0].LastName = '';
            vendorProfile.wrapperObj.conListWrap[0].Email = '';
            vendorProfile.doUpdateVendorProfile();   
            vendorProfile.doSubmitVendorProfile(); 
            
            vendorProfile.wrapperObj.conListWrap[0].Email = 'testing@test.com';
            vendorProfile.doUpdateVendorProfile();  
            vendorProfile.doSubmitVendorProfile(); 
            
            vendorProfile.wrapperObj.conListWrap[0].LastName = 'Testing';
            vendorProfile.doUpdateVendorProfile();  
            vendorProfile.doSubmitVendorProfile(); 
            
            for(VendorPortalAccountProfileController.ContentWrapper contver: vendorProfile.cvWrapList){
                contver.status = 'Uploaded';
            }
            
            vendorProfile.doUpdateVendorProfile();  
            
            vendorProfile.wrapperObj.accWrap.Legal_Acknowledgment__c=true;
            vendorProfile.doSubmitVendorProfile(); 
            
            vendorProfile.wrapperObj.accWrap.Type = 'Rehab';
            vendorProfile.callMethodNew(); 
            Test.StopTest();  
            vendorProfile.wrapperObj.accWrap.Type = 'Maintenance';
            vendorProfile.callMethodNew(); 
            
            ApexPages.currentPage().getParameters().put('listIndex', '0');
            vendorProfile.removeWrapperRow(); 
            
            vendorProfile.createReqDocTable();
            
            
        }
    }   
}