@isTest
public class TaskTriggerHandlerTest {
    
    @testSetup
    public static void TestData(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System administrator']; 
		User u = new User( FirstName='Hubspot',LastName='Admin', Alias = 'standt', Email='test2@testorg.com', 
                          EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='HubspotAdmin@testorg.com');
        insert u;
        
        insert new One_to_One_Lead_Ref__c(Not_One_to_One__c = 0, One_to_One__c = 0); 
    }
    
    @isTest
    public static void Test_1(){
        
        Test.startTest();
        
        List<User> u = [SELECT Id FROM User WHERE Name = 'Hubspot Admin' LIMIT 1];
        
        System.runAs(u[0]){
            Lead ld2 = new Lead();
            ld2.recordTypeId = Schema.sObjectType.Lead.getRecordTypeInfosByName().get('Investor Prospect').getRecordTypeId();
            ld2.FirstName = 'First';
            ld2.LastName = 'Last';
            ld2.Email = 'test@email.com';
            ld2.Phone = '999888777';
            ld2.MobilePhone = '987987987';
            ld2.Status = 'Qualified';
            ld2.Street = 'Test Street';
            ld2.City = 'Test City';
            ld2.State = 'MS';
            ld2.postalCode = '12345';
            ld2.Country = 'Test Country';
            ld2.Company = 'Test Company';
            ld2.Market__c = 'MEM';
            ld2.Status = 'Open';
            ld2.Timeline_of_Investment_life__c = '7-10 yrs';
            ld2.Timeframe_to_transact_on_a_property__c = '30-90 days';
            ld2.Who_are_you_investing_with_if_anyone__c = 'Self';
            ld2.The_Why__c = 'Quit full-time job';
            ld2.Expecations_as_property_owner__c = 'Passive';
            ld2.Experience_as_an_investor__c = 'No current Passive or Active Properties';
            ld2.How_much_are_you_looking_to_invest__c = 1233;
            ld2.Purchase_Method__c = 'Cash';
            ld2.Time_Zone__c = 'Central';
            ld2.lead_details__c = 'Test Company';
            ld2.Listing_Date__c = date.today();
            ld2.LeadSource = 'Wholesaler';
            ld2.Original_Source_Data_3__c = 'Front Desk Email Lead';
            ld2.Original_Source_Data_4__c = 'Fortune Builders Client';
            Insert ld2;
        	System.debug('User'+u[0]);
            Task t = new Task();
            t.OwnerId = u[0].id;
            t.Subject='Submitted Form \'One To One Session Registrations\'';
            t.Status='Completed';
            t.Priority='Normal';
            t.Description = 'Hello this is for testing purpose \n a new line \n address: test@email.com \n address: test2@email.com\n address: test3@email.com';
            t.whoid = ld2.id;
            insert t;
        }
        Test.stopTest();
    }
    @isTest
    public static void Test_2(){
        
        Test.startTest();
        
        List<User> u = [SELECT Id FROM User WHERE Name = 'Hubspot Admin' LIMIT 1];
        
        System.runAs(u[0]){
            Lead ld2 = new Lead();
            ld2.recordTypeId = Schema.sObjectType.Lead.getRecordTypeInfosByName().get('Investor Prospect').getRecordTypeId();
            ld2.FirstName = 'First';
            ld2.LastName = 'Last';
            ld2.Email = 'test@email.com';
            ld2.Phone = '999888777';
            ld2.MobilePhone = '987987987';
            ld2.Status = 'Qualified';
            ld2.Street = 'Test Street';
            ld2.City = 'Test City';
            ld2.State = 'MS';
            ld2.postalCode = '12345';
            ld2.Country = 'Test Country';
            ld2.Company = 'Test Company';
            ld2.Market__c = 'MEM';
            ld2.Status = 'Open';
            ld2.Timeline_of_Investment_life__c = '7-10 yrs';
            ld2.Timeframe_to_transact_on_a_property__c = '30-90 days';
            ld2.Who_are_you_investing_with_if_anyone__c = 'Self';
            ld2.The_Why__c = 'Quit full-time job';
            ld2.Expecations_as_property_owner__c = 'Passive';
            ld2.Experience_as_an_investor__c = 'No current Passive or Active Properties';
            ld2.How_much_are_you_looking_to_invest__c = 1233;
            ld2.Purchase_Method__c = 'Cash';
            ld2.Time_Zone__c = 'Central';
            ld2.lead_details__c = 'Test Company';
            ld2.Listing_Date__c = date.today();
            ld2.LeadSource = 'Wholesaler';
            ld2.Original_Source_Data_3__c = 'Front Desk Email Lead';
            ld2.Original_Source_Data_4__c = 'Fortune Builders Client';
            Insert ld2;
        	System.debug('User'+u[0]);
            Task t = new Task();
            t.OwnerId = u[0].id;
            t.Subject='Submitted Form \'One To One Session Registrations\'';
            t.Status='Completed';
            t.Priority='Normal';
            t.Description = 'First name: Kelcie \n Last name: Raskowsky \n Phone Number: 8087489934 \n Email Address: sumesh@cmentor.com \n Best day for session? (We will follow up to confirm): Monday \n Schedule 1 to 1: Yes \n City: Kailua \n State: Hi \n Zip: 96734';
            t.whoid = ld2.id;
            insert t;
        }
        Test.stopTest();
    }
}