@isTest
private class LeadTriggerTest{
     @testSetup
    public static void TestData(){
        Trigger_Switch__c setting = new Trigger_Switch__c();
        setting.Name = 'Opportunity';
        setting.Is_Enabled__c =  true;
        insert setting;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System administrator']; 
		User u = new User( FirstName='Hubspot',LastName='Admin', Alias = 'standt', Email='test2@testorg.com', 
                          EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='HubspotAdmin@testorg.com');
        insert u;
        
        insert new One_to_One_Lead_Ref__c(Not_One_to_One__c = 0, One_to_One__c = 5); 
        
        //List<Lead_User__mdt> m1 = [SELECT Id, Reference_Number__c, User_Id__c FROM Lead_User__mdt];
    }
	
    @isTest
    public static void unitTest(){
        Trigger_Switch__c setting = new Trigger_Switch__c();
        setting.Name = 'Opportunity';
        setting.Is_Enabled__c =  true;
        insert setting;
        
       // User u = [SELECT Id FROM User WHERE Name = 'Hubspot Admin' LIMIT 1];
        //System.runAs(u){
            Lead ld = new Lead();
            ld.recordTypeId = Schema.sObjectType.Lead.getRecordTypeInfosByName().get(label.Buyer_RecordType_On_Lead).getRecordTypeId();
            ld.FirstName = 'First';
            ld.LastName = 'Last';
            ld.Email = 'test@email.com';
            ld.Phone = '9998887771';
            ld.MobilePhone = '9879879871';
            ld.Status = 'Open';
            ld.Street = 'Test Street';
            ld.City = 'Test City';
            ld.State = 'MS';
            ld.postalCode = '12345';
            ld.Country = 'Test Country';
            ld.Company = 'Test Company';
            ld.Market__c = 'MEM';
            ld.lead_details__c = 'Test Company';
            ld.Original_Source_Data_3__c = 'Front Desk Email Lead';
            ld.Original_Source_Data_4__c = 'Fortune Builders Client';
            ld.Listing_Date__c = date.today();
            ld.LeadSource = 'MLS';
            ld.One_to_One_Lead__c = TRUE;
            Insert ld;
            
            Lead ld2 = new Lead();
            ld2.recordTypeId = Schema.sObjectType.Lead.getRecordTypeInfosByName().get('Investor Prospect').getRecordTypeId(); //
            ld2.FirstName = 'First2';
            ld2.LastName = 'Last2';
            ld2.Email = 'test2@email.com';
            ld2.Phone = '9998887772';
            ld2.MobilePhone = '9879879872';
            ld2.Status = 'Qualified';
            ld2.Street = 'Test Street 2';
            ld2.City = 'Test City 2';
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
            ld2.LeadSource = 'MLS';
            ld2.One_to_One_Lead__c = FALSE;
            ld2.Original_Source_Data_3__c = 'Front Desk Email Lead';
            ld2.Original_Source_Data_4__c = 'Fortune Builders Client';
            Insert ld2;
           
            LeadStatus convertStatus = [SELECT Id, MasterLabel, IsConverted FROM LeadStatus WHERE IsConverted=true and Masterlabel != 'Qualified' limit 1];
            Test.startTest();
        	Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(ld.Id);
            lc.setConvertedStatus(convertStatus.MasterLabel);
             
            Database.LeadConvertResult lcResults = Database.convertLead(lc);
            Id opportunityId = lcResults.getOpportunityId();
			
            LeadStatus convertStatus2 = [SELECT Id, MasterLabel, IsConverted FROM LeadStatus WHERE IsConverted=true and Masterlabel != 'Qualified' limit 1];
            Database.LeadConvert lc2 = new Database.LeadConvert();
            lc2.setLeadId(ld2.Id);
            lc2.setConvertedStatus(convertStatus2.MasterLabel);
            //Database.LeadConvertResult lcResults2 = Database.convertLead(lc2);
            //Id opportunityId2 = lcResults2.getOpportunityId();
            
            ld2.Status = 'Converted';
            update ld2;
        	Test.stopTest();
            
       // }
    }
    @isTest
    public static void unitTest2(){
        
        Trigger_Switch__c setting = new Trigger_Switch__c();
        setting.Name = 'Opportunity';
        setting.Is_Enabled__c =  true;
        insert setting;
        User u = [SELECT Id FROM User WHERE Name = 'Hubspot Admin' LIMIT 1];
        Test.startTest();
        System.runAs(u){
            Lead ld = new Lead();
            ld.recordTypeId = Schema.sObjectType.Lead.getRecordTypeInfosByName().get('Investor Prospect').getRecordTypeId();
            ld.FirstName = 'First3';
            ld.LastName = 'Last3';
            ld.Email = 'test3@email.com';
            ld.Phone = '9998887773';
            ld.MobilePhone = '9879879873';
            ld.Status = 'Open';
            ld.Street = 'Test Street';
            ld.City = 'Test City';
            ld.State = 'MS';
            ld.postalCode = '12345';
            ld.Country = 'Test Country';
            ld.Company = 'Test Company';
            ld.Market__c = 'MEM';
            ld.lead_details__c = 'Test Company';
            ld.Original_Source_Data_3__c = 'Front Desk Email Lead';
            ld.Original_Source_Data_4__c = 'Fortune Builders Client';
            ld.Listing_Date__c = date.today();
            ld.LeadSource = 'Wholesaler';
            ld.One_to_One_Lead__c = TRUE;
            Insert ld;
            
            Lead ld2 = new Lead();
            ld2.recordTypeId = Schema.sObjectType.Lead.getRecordTypeInfosByName().get('Investor Prospect').getRecordTypeId();
            ld2.FirstName = 'First4';
            ld2.LastName = 'Last4';
            ld2.Email = 'test4@email.com';
            ld2.Phone = '9998887774';
            ld2.MobilePhone = '9879879874';
            ld2.Status = 'Open';
            ld2.Street = 'Test Street24';
            ld2.City = 'Test City';
            ld2.State = 'MS';
            ld2.postalCode = '12345';
            ld2.Country = 'Test Country';
            ld2.Company = 'Test Company';
            ld2.Market__c = 'MEM';
            ld2.lead_details__c = 'Test Company';
            ld2.Original_Source_Data_3__c = 'Front Desk Email Lead';
            ld2.Original_Source_Data_4__c = 'Fortune Builders Client';
            ld2.Listing_Date__c = date.today();
            ld2.LeadSource = 'Wholesaler';
            ld2.One_to_One_Lead__c = TRUE;
            Insert ld2;
            
            Lead ld3 = new Lead();
            ld3.recordTypeId = Schema.sObjectType.Lead.getRecordTypeInfosByName().get('Investor Prospect').getRecordTypeId();
            ld3.FirstName = 'First5';
            ld3.LastName = 'Last5';
            ld3.Email = 'test5@email.com';
            ld3.Phone = '9998887775';
            ld3.MobilePhone = '9879879875';
            ld3.Status = 'Open';
            ld3.Street = 'Test Street23';
            ld3.City = 'Test City';
            ld3.State = 'MS';
            ld3.postalCode = '12345';
            ld3.Country = 'Test Country';
            ld3.Company = 'Test Company';
            ld3.Market__c = 'MEM';
            ld3.lead_details__c = 'Test Company';
            ld3.Original_Source_Data_3__c = 'Front Desk Email Lead';
            ld3.Original_Source_Data_4__c = 'Fortune Builders Client';
            ld3.Listing_Date__c = date.today();
            ld3.LeadSource = 'Wholesaler';
            ld3.One_to_One_Lead__c = TRUE;
            Insert ld3;
            
            Lead ld4 = new Lead();
            ld4.recordTypeId = Schema.sObjectType.Lead.getRecordTypeInfosByName().get('Investor Prospect').getRecordTypeId();
            ld4.FirstName = 'First6';
            ld4.LastName = 'Last6';
            ld4.Email = 'test6@email.com';
            ld4.Phone = '9998887776';
            ld4.MobilePhone = '9879879876';
            ld4.Status = 'Open';
            ld4.Street = 'Test Street23';
            ld4.City = 'Test City';
            ld4.State = 'MS';
            ld4.postalCode = '12345';
            ld4.Country = 'Test Country';
            ld4.Company = 'Test Company';
            ld4.Market__c = 'MEM';
            ld4.lead_details__c = 'Test Company';
            ld4.Original_Source_Data_3__c = 'Front Desk Email Lead';
            ld4.Original_Source_Data_4__c = 'Fortune Builders Client';
            ld4.Listing_Date__c = date.today();
            ld4.LeadSource = 'Wholesaler';
            ld4.Schedule_1_to_1__c = 'Yes';
            Insert ld4;
            
            Lead ld5 = new Lead();
            ld5.recordTypeId = Schema.sObjectType.Lead.getRecordTypeInfosByName().get('Investor Prospect').getRecordTypeId();
            ld5.FirstName = 'First7';
            ld5.LastName = 'Last7';
            ld5.Email = 'test7@email.com';
            ld5.Phone = '9998887777';
            ld5.MobilePhone = '9879879877';
            ld5.Status = 'Open';
            ld5.Street = 'Test Street23';
            ld5.City = 'Test City';
            ld5.State = 'MS';
            ld5.postalCode = '12345';
            ld5.Country = 'Test Country';
            ld5.Company = 'Test Company';
            ld5.Market__c = 'MEM';
            ld5.lead_details__c = 'Test Company';
            ld5.Original_Source_Data_3__c = 'Front Desk Email Lead';
            ld5.Original_Source_Data_4__c = 'Fortune Builders Client';
            ld5.Listing_Date__c = date.today();
            ld5.LeadSource = 'Wholesaler';
            ld5.Schedule_1_to_1__c = 'Yes';
            Insert ld5;
            
            Lead ld6 = new Lead();
            ld6.recordTypeId = Schema.sObjectType.Lead.getRecordTypeInfosByName().get('Investor Prospect').getRecordTypeId();
            ld6.FirstName = 'First8';
            ld6.LastName = 'Last8';
            ld6.Email = 'test8@email.com';
            ld6.Phone = '9998887778';
            ld6.MobilePhone = '9879879878';
            ld6.Status = 'Open';
            ld6.Street = 'Test Street23';
            ld6.City = 'Test City';
            ld6.State = 'MS';
            ld6.postalCode = '12345';
            ld6.Country = 'Test Country';
            ld6.Company = 'Test Company';
            ld6.Market__c = 'MEM';
            ld6.lead_details__c = 'Test Company';
            ld6.Original_Source_Data_3__c = 'Front Desk Email Lead';
            ld6.Original_Source_Data_4__c = 'Fortune Builders Client';
            ld6.Listing_Date__c = date.today();
            ld6.LeadSource = 'Wholesaler';
            ld6.Schedule_1_to_1__c = 'Yes';
            Insert ld6;
            
            Test.stopTest();
        }
    }
    
    
    @isTest
    public static void unitTest_3(){
        Trigger_Switch__c setting = new Trigger_Switch__c();
        setting.Name = 'Opportunity';
        setting.Is_Enabled__c =  true;
        insert setting;
        User u = [SELECT Id FROM User WHERE Name = 'Hubspot Admin' LIMIT 1];
        System.runAs(u){
           
            Lead ld2 = new Lead();
            ld2.recordTypeId = Schema.sObjectType.Lead.getRecordTypeInfosByName().get('Investor Prospect').getRecordTypeId(); //
            ld2.FirstName = 'First9';
            ld2.LastName = 'Last9';
            ld2.Email = 'test9@email.com';
            ld2.Phone = '9998887779';
            ld2.MobilePhone = '9879879879';
            ld2.Status = 'Qualified';
            ld2.Street = 'Test Street 2';
            ld2.City = 'Test City 2';
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
            ld2.LeadSource = 'MLS';
            ld2.One_to_One_Lead__c = FALSE;
            ld2.Original_Source_Data_3__c = 'Front Desk Email Lead';
            ld2.Original_Source_Data_4__c = 'Fortune Builders Client';
            Insert ld2;
            
            LeadStatus convertStatus = [SELECT Id, MasterLabel, IsConverted FROM LeadStatus WHERE IsConverted=true and Masterlabel != 'Qualified' limit 1];
            
            Test.startTest();
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(ld2.Id);
            lc.setConvertedStatus(convertStatus.MasterLabel);
            Database.LeadConvertResult lcResults = Database.convertLead(lc);
            Id opportunityId = lcResults.getOpportunityId();

	
            ld2.Status = 'Converted';
            update ld2;
            Test.stopTest();
            
        }
        
    }

}