@isTest
public class OpportunityTriggerHandlerTest {
    @testSetup
    static void testData(){
        
        Trigger_Switch__c setting = new Trigger_Switch__c();
        setting.Name = 'Opportunity';
        setting.Is_Enabled__c =  true;
        insert setting;
        
        List<Account> accList = new List<Account>();
        accList.add(
            new Account(
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Vendor - Pro Serv').getRecordTypeId(),
                Name = 'Test Account',
                Vendor_Email__c = 'test2@cmentor.com',
                Market__c = 'MEM',
                Status__c = 'Active',
                Type = 'Lender'                
            )
        );
        accList.add(
            new Account(
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Affiliates').getRecordTypeId(),
                Name = 'Client Referral',
                Vendor_Email__c = 'test3@cmentor.com',
                Market__c = 'MEM',
                Status__c = 'Active',
                Type = 'Lender',
                Standard_Referral_Fee__c = 100,
                X2nd_Layer_Referral_Fee__c = 100                
            )
        );
        accList.add(
            new Account(
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Investor Owner').getRecordTypeId(),
                Name = 'Investor Owner',
                Vendor_Email__c = 'test4@cmentor.com',
                Market__c = 'MEM',
                Status__c = 'Active',
                Type = 'Lender',
                Standard_Referral_Fee__c = 100,
                X2nd_Layer_Referral_Fee__c = 100                
            )
        );
        accList.add(
            new Account(
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Investor Prospect').getRecordTypeId(),
                Name = 'Investor Prospect',
                Vendor_Email__c = 'test5@cmentor.com',
                Market__c = 'MEM',
                Status__c = 'Active',
                Type = 'Lender',
                Standard_Referral_Fee__c = 100,
                X2nd_Layer_Referral_Fee__c = 100                
            )
        );
        insert accList;
        
        List<Contact> listCon = new List<Contact>();
        listCon.add(
            new Contact(
                RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Vendor').getRecordTypeId(),
                FirstName = 'Test',
                LastName='Con',
                Email = 'test@cmentor.com',
                Account = accList[0],
                AccountId = accList[0].Id,
                Is_Primary__c = TRUE                
            )
        );
        listCon.add(
            new Contact(
                RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Vendor').getRecordTypeId(),
                FirstName = 'Test2',
                LastName='Con',
                Email = 'test@cmentor.com',
                Account = accList[0],
                AccountId = accList[0].Id
            )
        );
        Insert listCon;
        List<Assessment__c> asmtList = new List<Assessment__c>();
        // 0
        asmtList.add(
            new Assessment__c(
                Name = 'Asmt-0',
                Market__c = 'MEM',
                Bedrooms__c = '2',
                Bathrooms__c = '2',
                Car_Storage_Parking__c = '2GD',
                Year_Built__c = '1962',
                Square_Ft__c = 100,
                Status__c = 'Completed'
            )
        );
        insert asmtList;
        
        List<House__c> houseList = new List<House__c>();
        houseList.add(
            new House__c(
                Name = 'Test House',
                City__c = 'Test City',
                State__c = 'MS',
                Zip_Code__c = '12345',
                Street_Address__c = 'Test Street Address'
            )
        );
        houseList.add(
            new House__c(
                Name = 'Test House1',
                City__c = 'Test City',
                State__c = 'OK',
                Zip_Code__c = '12345',
                Street_Address__c = 'Test Street Address'
            )
        );
        houseList.add(
            new House__c(
                Name = 'Test House2',
                City__c = 'Test City',
                State__c = 'MO',
                Zip_Code__c = '12345',
                Street_Address__c = 'Test Street Address'
            )
        );
        insert houseList;
        
        ID RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Investor Prospect').getRecordTypeId();
        ID buyRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Buy').getRecordTypeId();
        List<opportunity> oppList = new List<Opportunity>();
        
        // 0
        oppList.add(
            new opportunity(
                Name = 'Opp 0',
                RecordTypeId = RecordTypeId,
                Lender_Name__c = listCon[0].Id,
                Lender_Approval__c = 'Y',
                CloseDate = date.today(),
                House__c = houseList[0].id,
                StageName = 'RecordTypeId = RecordTypeId',
                Assessment__c = asmtList[0].id,
                Bathrooms__c = '1',
                Bedrooms__c = '1',
                Square_Ft__c = 200,
                Car_Storage__c = '1GD',
                Year_Built__c = '2010',
                Appraised__c = 2000,
                Loan_Type__c = 'CV',
                Market__c = 'MEM',
                Initial_Offer__c = 200,                
                Initial_List_Price__c = 200,
                Info_Source__c = 'MLS',
                LeadSource = 'WEB'
            )
        );
        
        // 1
        oppList.add(
            new opportunity(
                Name = 'Opp 1',
                RecordTypeId = RecordTypeId,
                CloseDate = date.today(),
                House__c = houseList[0].id,
                StageName = 'RecordTypeId = RecordTypeId',
                Assessment__c = asmtList[0].id,
                Bathrooms__c = '1',
                Bedrooms__c = '1',
                Square_Ft__c = 200,
                Car_Storage__c = '1GD',
                Year_Built__c = '2010',
                Appraised__c = 2000,
                Loan_Type__c = 'CV',
                Market__c = 'MEM',
                Initial_Offer__c = 200,
                Initial_List_Price__c = 200,
                Info_Source__c = 'MLS'
                
            )
        );
        
        // 2
        oppList.add(
            new opportunity(
                Name = 'Opp 2',
                RecordTypeId = RecordTypeId,
                CloseDate = date.today(),
                House__c = houseList[0].id,
                StageName = 'RecordTypeId = RecordTypeId',
                Assessment__c = asmtList[0].id,
                Bathrooms__c = '1',
                Initial_Offer__c = 200,
                Bedrooms__c = '1',
                Square_Ft__c = 200,
                Car_Storage__c = '1GD',
                Year_Built__c = '2010',
                Appraised__c = 2000,
                Loan_Type__c = 'CV',
                Market__c = 'MEM',
                Initial_List_Price__c = 200,
                Info_Source__c = 'MLS'
            )
        );
        
        // 3
        oppList.add(
            new opportunity(
                Name = 'Opp 3',
                RecordTypeId = RecordTypeId,
                CloseDate = date.today(),
                House__c = houseList[0].id,
                StageName = 'RecordTypeId = RecordTypeId',
                Assessment__c = asmtList[0].id,
                Bathrooms__c = '1',
                Initial_Offer__c = 200,
                Bedrooms__c = '1',
                Square_Ft__c = 200,
                Car_Storage__c = '1GD',
                Year_Built__c = '2010',
                Appraised__c = 2000,
                Loan_Type__c = 'CV',
                Market__c = 'MEM',
                Initial_List_Price__c = 200,
                Info_Source__c = 'MLS'
            )
        );
        
        
        // 4
        oppList.add(
            new opportunity(
                Name = 'Opp 4',
                RecordTypeId = RecordTypeId,
                Initial_Offer__c = 200,
                CloseDate = date.today(),
                House__c = houseList[0].id,
                StageName = 'RecordTypeId = RecordTypeId',
                Assessment__c = asmtList[0].id,
                Bathrooms__c = '1',
                Bedrooms__c = '1',
                Square_Ft__c = 200,
                Car_Storage__c = '1GD',
                Year_Built__c = '2010',
                Appraised__c = 2000,
                Loan_Type__c = 'CV',
                Market__c = 'MEM',
                Initial_List_Price__c = 200,
                Info_Source__c = 'MLS'
                
            )
        );
        
        // 5
        oppList.add(
            new opportunity(
                Name = 'Opp 5',
                RecordTypeId = RecordTypeId,
                CloseDate = date.today(),
                House__c = houseList[0].id,
                StageName = 'RecordTypeId = RecordTypeId',
                Assessment__c = asmtList[0].id,
                Bathrooms__c = '1',
                Bedrooms__c = '1',
                Initial_Offer__c = 200,
                Square_Ft__c = 200,
                Car_Storage__c = '1GD',
                Year_Built__c = '2010',
                Appraised__c = 2000,
                Loan_Type__c = 'CV',
                Market__c = 'MEM',
                Initial_List_Price__c = 200,
                Info_Source__c = 'MLS'
            )
        );
        
        // 6
        oppList.add(
            new opportunity(
                Name = 'Opp 6',
                RecordTypeId = RecordTypeId,
                CloseDate = date.today(),
                House__c = houseList[0].id,
                StageName = 'RecordTypeId = RecordTypeId',
                Assessment__c = asmtList[0].id,
                Bathrooms__c = '1',
                Bedrooms__c = '1',
                Square_Ft__c = 200,
                Initial_Offer__c = 200,
                Car_Storage__c = '1GD',
                Initial_List_Price__c = 200,
                Year_Built__c = '2010',
                Appraised__c = 2000,
                Loan_Type__c = 'CV',
                Market__c = 'MEM',
                Info_Source__c = 'MLS'
            )
        );
        
        // 7
        oppList.add(
            new opportunity(
                Name = 'Opp 7',
                RecordTypeId = RecordTypeId,
                CloseDate = date.today(),
                House__c = houseList[0].id,
                StageName = 'RecordTypeId = RecordTypeId',
                Assessment__c = asmtList[0].id,
                Bathrooms__c = '1',
                Initial_Offer__c = 200,
                Bedrooms__c = '1',
                Square_Ft__c = 200,
                Car_Storage__c = '1GD',
                Year_Built__c = '2010',
                Appraised__c = 2000,
                Loan_Type__c = 'CV',
                Market__c = 'MEM',
                Info_Source__c = 'MLS',
                Initial_List_Price__c = 200,
                AccountId = accList[0].id
            )
        );
        
        // 8
        oppList.add(
            new opportunity(
                Name = 'Opp 8',
                RecordTypeId = RecordTypeId,
                CloseDate = date.today(),
                House__c = houseList[0].id,
                StageName = 'RecordTypeId = RecordTypeId',
                Assessment__c = asmtList[0].id,
                Bathrooms__c = '1',
                Initial_Offer__c = 200,
                Bedrooms__c = '1',
                Square_Ft__c = 200,
                Car_Storage__c = '1GD',
                Year_Built__c = '2010',
                Appraised__c = 2000,
                Loan_Type__c = 'CV',
                Market__c = 'MEM',
                Info_Source__c = 'MLS',
                Initial_List_Price__c = 200,
                AccountId = accList[0].id
            )
        );
        
        // 9
        oppList.add(
            new opportunity(
                Name = 'Opp 9',
                RecordTypeId = RecordTypeId,
                CloseDate = date.today(),
                House__c = houseList[0].id,
                StageName = 'RecordTypeId = RecordTypeId',
                Assessment__c = asmtList[0].id,
                Bathrooms__c = '1',
                Bedrooms__c = '1',
                Initial_Offer__c = 200,
                Square_Ft__c = 200,
                Car_Storage__c = '1GD',
                Year_Built__c = '2010',
                Appraised__c = 2000,
                Loan_Type__c = 'CV',
                Market__c = 'MEM',
                Info_Source__c = 'MLS',
                Initial_List_Price__c = 200,
                AccountId = accList[0].id
            )
        );
        
        // 10
        oppList.add(
            new opportunity(
                Name = 'Opp 9',
                RecordTypeId = buyRecordTypeId,
                CloseDate = date.today(),
                House__c = houseList[0].id,
                StageName = 'RecordTypeId = RecordTypeId',
                Assessment__c = asmtList[0].id,
                Bathrooms__c = '1',
                Bedrooms__c = '1',
                Initial_Offer__c = 200,
                Square_Ft__c = 200,
                Car_Storage__c = '1GD',
                Year_Built__c = '2010',
                Appraised__c = 2000,
                Loan_Type__c = 'CV',
                Market__c = 'MEM',
                Info_Source__c = 'MLS',
                Initial_List_Price__c = 200,
                AccountId = accList[0].id,
                LeadSource = 'Other',
                Listing_Date__c = date.today()
            )
        );
        
        insert oppList;
        
        
        Id renovationRecordTypeId = Schema.SObjectType.Project__c.getRecordTypeInfosByName().get('Renovation').getRecordTypeId();
        
        List<Project__c> projectList = new List<Project__c>();
        // 0
        projectList.add(
            new Project__c(
                Opportunity__c = oppList[7].id,
                House__c = houseList[0].id,
                Pay_Account__c='New DFW'
            )
        );
        
        // 1
        projectList.add(
            new Project__c(
                RecordTypeId = renovationRecordTypeId,
                House__c = houseList[0].id,
                Pay_Account__c='New DFW'
            )
        );
        // 2
        projectList.add(
            new Project__c(
                RecordTypeId = renovationRecordTypeId,
                House__c = houseList[0].id,
                Pay_Account__c='New DFW'
            )
        );
        
        insert projectList;
        
    }
    @isTest
    static void Test_1(){
        
        Trigger_Switch__c setting = new Trigger_Switch__c();
        setting.Name = 'Opportunity';
        setting.Is_Enabled__c =  true;
        insert setting;
        
        Test.startTest();
        List<Account> accList = [SELECT Id,RecordTypeId,Name,Vendor_Email__c,Market__c,Status__c FROM Account];
        List<Contact> conList = [SELECT Id FROM Contact LIMIT 1];
        List<House__c> house = [SELECT Id FROM House__c];
        Opportunity opp = new Opportunity();
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Buy').getRecordTypeId();
        opp.Name = 'Opp 0';
        opp.Title_Verification_Email__c = TRUE;
        opp.CloseDate = date.today();
        opp.StageName = 'RecordTypeId = RecordTypeId';
        opp.Bathrooms__c = '1';
        opp.Bedrooms__c = '1';
        opp.Square_Ft__c = 200;
        opp.Car_Storage__c = '1GD';
        opp.Year_Built__c = '2010';
        opp.Appraised__c = 2000;
        opp.Loan_Type__c = 'CV';
        opp.Market__c = 'MEM';
        opp.Initial_Offer__c = 200;
        opp.Initial_List_Price__c = 200;
        opp.Info_Source__c = 'MLS';
        opp.LeadSource = 'Client Referral';
        opp.Listing_Date__c = System.today() - 10;
        opp.Source_Contact__c = conList[0].Id;
        opp.House__c = house[0].Id;
        opp.AccountId = accList[0].Id;
        insert opp;
        Test.stopTest();
        // OpportunityTriggerHandler.fillHouseNameToBuyOppNameAfterInsert();
    }
    @isTest
    static void Test_2(){
        
        Trigger_Switch__c setting = new Trigger_Switch__c();
        setting.Name = 'Opportunity';
        setting.Is_Enabled__c =  true;
        insert setting;
        
        test.startTest();
        Opportunity opp = [SELECT Id, RecordTypeId, House__c FROM Opportunity LIMIT 1];
        List<Account> accList = [SELECT Id,RecordTypeId,Name,Vendor_Email__c,Market__c,Status__c FROM Account];
        List<Contact> conList = [SELECT Id FROM Contact LIMIT 1];
        List<House__c> house = [SELECT Id FROM House__c];
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Buy').getRecordTypeId();
        opp.LeadSource = 'Client Referral';
        opp.Title_Verification_Email__c = FALSE;
        opp.Listing_Date__c = System.today() - 10;
        opp.Source_Contact__c = conList[0].Id;
        opp.House__c = house[0].Id;
        opp.AccountId = accList[0].Id;
        update opp;
        opp.House__c = house[1].Id;
        opp.Title_Verification_Email__c = TRUE;
        update opp;
        OpportunityTriggerHandler.fillHouseNameToBuyOppNameBeforeUpdate();
        test.stopTest();
    }
    @isTest
    static void Test_3(){
        
        Trigger_Switch__c setting = new Trigger_Switch__c();
        setting.Name = 'Opportunity';
        setting.Is_Enabled__c =  true;
        insert setting;
        
        Test.startTest();
        List<Account> accList = [SELECT Id,RecordTypeId,Name,Vendor_Email__c,Market__c,Status__c FROM Account];
        List<Contact> conList = [SELECT Id FROM Contact];
        
        Opportunity opp = new Opportunity();
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Investor Prospect').getRecordTypeId();
        opp.Name = 'Opp Name';
        opp.AccountId = accList[0].Id;
        opp.Title_Verification_Email__c = TRUE;
        opp.Purchase_Method__c = 'Conventional';
        opp.Title_Name_Type__c = 'Trust';
        opp.Down_payment_for_investor__c = '20%';
        opp.Intro_Lender_1__c = conList[0].Id;
        opp.Intro_Lender_1_Intro_Email__c = TRUE;
        //opp.Owner_Account_1_Signer_1__c = conList[1].Id;
        opp.Intro_Lender_2__c = conList[1].Id;
        opp.Intro_Lender_2_Intro_Email__c = TRUE;
        opp.Intro_Lender_1_Account__c = 'test';
        opp.Intro_Lender_2_Account__c = 'test';
        opp.StageName = 'Pre-Qual';
        opp.CloseDate = System.today()+10;
        insert opp;
        Test.stopTest();
    }   
    @isTest
    static void Test_4(){
        
        Trigger_Switch__c setting = new Trigger_Switch__c();
        setting.Name = 'Opportunity';
        setting.Is_Enabled__c =  true;
        insert setting;
        
        Test.startTest();
        List<Account> accList = [SELECT Id,RecordTypeId,Name,Vendor_Email__c,Market__c,Status__c FROM Account];
        List<Contact> conList = [SELECT Id FROM Contact];
        List<Opportunity> oppList = [SELECT Id,State__c FROM Opportunity Where Name = 'Opp 8' Limit 1];
        oppList[0].Intro_Lender_1__c = conList[0].Id;
        oppList[0].Purchase_Method__c = 'Conventional';
        oppList[0].Title_Name_Type__c = 'Trust';
        oppList[0].Down_payment_for_investor__c = '20%';
        oppList[0].Title_Verification_Email__c = TRUE;
        oppList[0].Intro_Lender_1_Intro_Email__c = FALSE;
        //oppList[0].Owner_Account_1_Signer_1__c = conList[1].Id;
        oppList[0].Intro_Lender_2__c = conList[1].Id;
        oppList[0].Intro_Lender_2_Intro_Email__c = FALSE;
        oppList[0].Intro_Lender_1_Account__c = 'test';
        oppList[0].Intro_Lender_2_Account__c = 'test';
        
        update oppList;
        
        oppList[0].Intro_Lender_1_Intro_Email__c = TRUE;
        oppList[0].Intro_Lender_2_Intro_Email__c = TRUE;
        update oppList;
        Test.stopTest();
        
    }
    @isTest
    static void Test_5_1(){
        
        Trigger_Switch__c setting = new Trigger_Switch__c();
        setting.Name = 'Opportunity';
        setting.Is_Enabled__c =  true;
        insert setting;
        
        Test.startTest();
        
        List<Opportunity> oppList = [SELECT Id,State__c FROM Opportunity];
        List<Project__c> prolist = [SELECT Id, Name FROM Project__c];
        oppList[6].Project_Evaluation_1__c = prolist[0].Id;
        oppList[6].Project_Evaluation_2__c = prolist[1].Id;
        oppList[6].Project_Evaluation_3__c = prolist[2].Id;
        update oppList[6];
        
        oppList[6].Project_Evaluation_1_Status__c = 'SELECTED';
        update oppList[6];
        /*
oppList[6].StageName = 'Cancelled';
update oppList[6];
*/
        Test.stopTest();
    }
    @isTest
    static void Test_5(){
        
        Trigger_Switch__c setting = new Trigger_Switch__c();
        setting.Name = 'Opportunity';
        setting.Is_Enabled__c =  true;
        insert setting;
        
        Test.startTest();
        
        List<Opportunity> oppList = [SELECT Id,State__c FROM Opportunity];
        List<Project__c> prolist = [SELECT Id, Name FROM Project__c];
        oppList[6].Project_Evaluation_1__c = prolist[0].Id;
        oppList[6].Project_Evaluation_2__c = prolist[1].Id;
        oppList[6].Project_Evaluation_3__c = prolist[2].Id;
        update oppList[6];
        
        oppList[6].Project_Evaluation_2_Status__c = 'SELECTED';
        update oppList[6];
        /*
oppList[6].StageName = 'Cancelled';
update oppList[6];
*/
        Test.stopTest();
    }
    @isTest
    static void Test_6(){
        
        Trigger_Switch__c setting = new Trigger_Switch__c();
        setting.Name = 'Opportunity';
        setting.Is_Enabled__c =  true;
        insert setting;
        
        Test.startTest();
        
        List<Opportunity> oppList = [SELECT Id,State__c FROM Opportunity];
        List<Project__c> prolist = [SELECT Id, Name FROM Project__c];
        oppList[6].Project_Evaluation_1__c = prolist[0].Id;
        oppList[6].Project_Evaluation_2__c = prolist[1].Id;
        oppList[6].Project_Evaluation_3__c = prolist[2].Id;
        update oppList[6];
        
        oppList[6].Project_Evaluation_3_Status__c = 'SELECTED';
        update oppList[6];
        /*
oppList[6].StageName = 'Cancelled';
update oppList[6];
*/
        Test.stopTest();
    }
    /*
@isTest
static void Test_7(){

Test.startTest();

List<Opportunity> oppList = [SELECT Id,State__c FROM Opportunity];
List<Project__c> prolist = [SELECT Id, Name FROM Project__c];
oppList[6].Project_Evaluation_1__c = prolist[0].Id;
oppList[6].Project_Evaluation_2__c = prolist[1].Id;
oppList[6].Project_Evaluation_3__c = prolist[2].Id;
update oppList[6];

oppList[6].Project_Evaluation_1_Status__c = 'SELECTED';
update oppList[6];

//oppList[6].StageName = 'Cancelled';
//update oppList[6];

try{
oppList[7].Project_Evaluation_1__c = prolist[1].Id;
oppList[7].Project_Evaluation_1_Status__c = 'SELECTED';
update oppList[7];

}catch(Exception ex){
Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
System.assertEquals(expectedExceptionThrown, true);
}

Test.stopTest();
}
*/
    @isTest
    static void Test_8(){
        
        Trigger_Switch__c setting = new Trigger_Switch__c();
        setting.Name = 'Opportunity';
        setting.Is_Enabled__c =  true;
        insert setting;
        
        Test.startTest();
        List<Project__c> projectList = [SELECT ID FROM Project__c WHERE RecordType.Name = 'Renovation'];
        List<Opportunity> oppList = [SELECT Id,State__c FROM Opportunity Where Name = 'Opp 7' Limit 1];
        List<House__c> houseLst  = [SELECT Id,Name FROM House__c];
        oppList[0].project__c = projectList[0].id;
        update oppList[0];
        Test.stopTest();
    }    
    @isTest
    static void Test_9(){
        
        Trigger_Switch__c setting = new Trigger_Switch__c();
        setting.Name = 'Opportunity';
        setting.Is_Enabled__c =  true;
        insert setting;
        
        Test.startTest();
        List<Opportunity> oppList = [SELECT Id,State__c FROM Opportunity Where Name = 'Opp 8' Limit 1];
        update oppList[0];
        Test.stopTest();
    }   
    @isTest
    static void Test_10(){
        
        Trigger_Switch__c setting = new Trigger_Switch__c();
        setting.Name = 'Opportunity';
        setting.Is_Enabled__c =  true;
        insert setting;
        
        Test.startTest();
        ID InvestorProspectRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Investor Prospect').getRecordTypeId();
        Id BuyRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Buy').getRecordTypeId();
        System.debug(InvestorProspectRecordTypeId+'<==Investor==ID==buy==>'+BuyRecordType);
        List<Project__c> projectList = [SELECT ID FROM Project__c WHERE RecordType.Name = 'Renovation'];
        List<House__c> houseList =[Select id,Name from House__c];
        
        
        System.debug('houseList=Opportunities2__r==>'+houseList[0]);
        List<Account> listAcc=  [Select id from Account];
        List<Contact> listCon=  [Select id from Contact];
        List<Opportunity> oppList = [SELECT Id,State__c FROM Opportunity];
        for(Opportunity opp : oppList){
            opp.AccountId=listAcc[0].id;
            opp.Source_Contact__c=listCon[0].Id;
            opp.House__c=houseList[0].id;
            opp.Follow_Up_Sold_Date__c=System.today();
            opp.LeadSource='DSM';
            opp.Listing_Date__c=System.today();
            opp.RecordTypeId=BuyRecordType;
            opp.Sale_Comp_1__c=houseList[0].id;
            opp.Sale_Comp_2__c=houseList[1].id;
            opp.Sale_Comp_3__c=houseList[2].id;
            opp.Rent_Comp_1__c=houseList[0].id;
            opp.Rent_Comp_2__c=houseList[1].id;
            opp.Rent_Comp_3__c=houseList[2].id;
        }
        update oppList;
        System.debug('oppList==>'+oppList[0].RecordTypeId);
        Test.stopTest();
    }   
    @isTest
    static void Test_11(){
        
        Trigger_Switch__c setting = new Trigger_Switch__c();
        setting.Name = 'Opportunity';
        setting.Is_Enabled__c =  true;
        insert setting;
        
        Test.startTest();
        ID InvestorProspectRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Investor Prospect').getRecordTypeId();
        Id BuyRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Buy').getRecordTypeId();
        System.debug(InvestorProspectRecordTypeId+'<==Investor==ID==buy==>'+BuyRecordType);
        List<Project__c> projectList = [SELECT ID FROM Project__c WHERE RecordType.Name = 'Renovation'];
        List<House__c> houseList =[Select id,Name from House__c];
        
        
        System.debug('houseList=Opportunities2__r==>'+houseList[0]);
        List<Account> listAcc=  [Select id from Account];
        List<Contact> listCon=  [Select id from Contact];
        List<Opportunity> oppList = [SELECT Id,State__c FROM Opportunity];
        integer i=0;
        for(Opportunity opp : oppList){
            i++;
            if(i==2){
                opp.AccountId=listAcc[0].id;
                opp.Source_Contact__c=listCon[0].Id;
                opp.House__c=houseList[0].id;
                opp.Follow_Up_Sold_Date__c=System.today();
                opp.LeadSource='DSM';
                opp.Listing_Date__c=System.today();
                opp.RecordTypeId=InvestorProspectRecordTypeId;
                opp.Sale_Comp_1__c=houseList[0].id;
                opp.Sale_Comp_2__c=houseList[1].id;
                opp.Sale_Comp_3__c=houseList[2].id;
                opp.Rent_Comp_1__c=houseList[0].id;
                opp.Rent_Comp_2__c=houseList[1].id;
                opp.Rent_Comp_3__c=houseList[2].id;
            }
            else{
                opp.AccountId=listAcc[0].id;
                opp.Source_Contact__c=listCon[0].Id;
                opp.House__c=houseList[0].id;
                opp.Follow_Up_Sold_Date__c=System.today();
                opp.LeadSource='DSM';
                opp.Listing_Date__c=System.today();
                opp.RecordTypeId=BuyRecordType;
                opp.Sale_Comp_1__c=houseList[0].id;
                opp.Sale_Comp_2__c=houseList[1].id;
                opp.Sale_Comp_3__c=houseList[2].id;
                opp.Rent_Comp_1__c=houseList[0].id;
                opp.Rent_Comp_2__c=houseList[1].id;
                opp.Rent_Comp_3__c=houseList[2].id;     
            }
            
        }
        update oppList;
        System.debug('oppList==>'+oppList[0].RecordTypeId);
        Test.stopTest();
    }
    @isTest
    static void Test_12(){
        
        Trigger_Switch__c setting = new Trigger_Switch__c();
        setting.Name = 'Opportunity';
        setting.Is_Enabled__c =  true;
        insert setting;
        
        Test.startTest();
        ID InvestorProspectRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Investor Prospect').getRecordTypeId();
        List<Project__c> projectList = [SELECT ID FROM Project__c WHERE RecordType.Name = 'Renovation'];
        System.debug('projectList==>'+projectList[0]);
        List<Account> accList = [SELECT Id FROM Account Limit 1];
        List<House__c> houseList = [SELECT Id FROM House__c Limit 1];
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(
            new Opportunity(
                Name = 'Insert Opp',
                RecordTypeId = InvestorProspectRecordTypeId,
                CloseDate = date.today(),
                StageName = 'Pre-Assessment',
                House__c = houseList[0].id,
                AccountId = accList[0].id,
                LeadSource = 'BiggerPockets',
                Initial_Offer__c = 200,
                Listing_Date__c = date.today(),
                Initial_List_Price__c = 200,
                Follow_Up_Sold_Date__c = date.today(),
                Project__c=projectList[0].Id
            )
        );
        
        oppList.add(
            new Opportunity(
                Name = 'Insert Opp',
                RecordTypeId = InvestorProspectRecordTypeId,
                CloseDate = date.today(),
                StageName = 'Pre-Assessment',
                House__c = houseList[0].id,
                AccountId = accList[0].id,
                Initial_Offer__c = 200,
                LeadSource = 'BiggerPockets',
                Listing_Date__c = date.today(),
                Initial_List_Price__c = 200,
                Follow_Up_Sold_Date__c = date.today(),
                Project__c=projectList[0].Id
            )
        );
        
        oppList.add(
            new Opportunity(
                Name = 'Insert Opp',
                RecordTypeId = InvestorProspectRecordTypeId,
                CloseDate = date.today(),
                StageName = 'Pre-Assessment',
                House__c = houseList[0].id,
                AccountId = accList[0].id,
                LeadSource = 'BiggerPockets',
                Initial_Offer__c = 200,
                Listing_Date__c = date.today(),
                Initial_List_Price__c = 200,
                Follow_Up_Sold_Date__c = date.today(),
                Project__c=projectList[0].Id
            )
        );
        insert oppList;
        System.debug('oppList==>'+oppList[0]);
        for(Opportunity opp :oppList){
            opp.RecordTypeId=InvestorProspectRecordTypeId;
        }
        Update oppList;
        Test.stopTest();
    }    
    @isTest
    static void Test_13(){
        
        Trigger_Switch__c setting = new Trigger_Switch__c();
        setting.Name = 'Opportunity';
        setting.Is_Enabled__c =  true;
        insert setting;
        
        Test.startTest();
        ID BuyRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Buy').getRecordTypeId();
        List<Account> accList = [SELECT Id FROM Account Limit 1];
        List<House__c> houseList = [SELECT Id FROM House__c Limit 1];
        List<Assessment__c> amntList = [SELECT Id FROM Assessment__c Limit 1];
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(
            new Opportunity(
                Name = 'Insert Opp',
                RecordTypeId = BuyRecordTypeId,
                CloseDate = date.today(),
                StageName = 'Pre-Assessment',
                House__c = houseList[0].id,
                AccountId = accList[0].id,
                LeadSource = 'BiggerPockets',
                Listing_Date__c = date.today(),
                Initial_Offer__c = 200,
                Initial_List_Price__c = 200,
                Follow_Up_Sold_Date__c = date.today()
            )
        );
        
        oppList.add(
            new Opportunity(
                Name = 'Insert Opp',
                RecordTypeId = BuyRecordTypeId,
                CloseDate = date.today(),
                StageName = 'Pre-Assessment',
                House__c = houseList[0].id,
                AccountId = accList[0].id,
                LeadSource = 'BiggerPockets',
                Initial_Offer__c = 200,
                Listing_Date__c = date.today(),
                Follow_Up_Sold_Date__c = date.today(),
                Initial_List_Price__c = 200,
                Assessment__c = amntList[0].id
            )
        );
        
        oppList.add(
            new Opportunity(
                Name = 'Insert Opp',
                RecordTypeId = BuyRecordTypeId,
                CloseDate = date.today(),
                StageName = 'Pre-Assessment',
                House__c = houseList[0].id,
                AccountId = accList[0].id,
                LeadSource = 'BiggerPockets',
                Listing_Date__c = date.today(),
                Initial_Offer__c = 200,
                Follow_Up_Sold_Date__c = date.today(),
                Initial_List_Price__c = 200,
                Assessment__c = amntList[0].id
            )
        );
        
        oppList.add(
            new Opportunity(
                Name = 'Insert Opp',
                RecordTypeId = BuyRecordTypeId,
                CloseDate = date.today(),
                StageName = 'Pre-Assessment',
                House__c = houseList[0].id,
                AccountId = accList[0].id,
                LeadSource = 'BiggerPockets',
                Initial_Offer__c = 200,
                Listing_Date__c = date.today(),
                Initial_List_Price__c = 200,
                Follow_Up_Sold_Date__c = date.today()
            )
        );
        
        oppList.add(
            new Opportunity(
                Name = 'Insert Opp',
                RecordTypeId = BuyRecordTypeId,
                CloseDate = date.today(),
                StageName = 'Pre-Assessment',
                House__c = houseList[0].id,
                AccountId = accList[0].id,
                LeadSource = 'BiggerPockets',
                Initial_Offer__c = 200,
                Listing_Date__c = date.today(),
                Initial_List_Price__c = 200,
                Follow_Up_Sold_Date__c = date.today()
            )
        );
        
        
        oppList.add(
            new Opportunity(
                Name = 'Insert Opp',
                RecordTypeId = BuyRecordTypeId,
                CloseDate = date.today(),
                StageName = 'Pre-Assessment',
                House__c = houseList[0].id,
                AccountId = accList[0].id,
                LeadSource = 'BiggerPockets',
                Initial_Offer__c = 200,
                Listing_Date__c = date.today(),
                Initial_List_Price__c = 200,
                Follow_Up_Sold_Date__c = date.today()
            )
        );
        insert oppList;
        Test.stopTest();
    }
    
    @isTest
    static void Test_14(){
        
        Trigger_Switch__c setting = new Trigger_Switch__c();
        setting.Name = 'Opportunity';
        setting.Is_Enabled__c =  true;
        insert setting;
        
        Test.startTest();
        
        List<Opportunity> oppList = [SELECT Id FROM Opportunity WHERE RecordType.Name = 'Buy' Limit 1];
        oppList[0].AccountId = Null;
        Database.SaveResult result = Database.update(oppList[0], false);
        //System.assertEquals('These required fields must be completed: Account Name',result.getErrors()[0].getMessage());
        
        Test.stopTest();
    }
    
    @isTest
    static void Test_15(){
        
        Trigger_Switch__c setting = new Trigger_Switch__c();
        setting.Name = 'Opportunity';
        setting.Is_Enabled__c =  true;
        insert setting;
        
        Test.startTest();
        
        List<Opportunity> oppList = [SELECT Id FROM Opportunity WHERE RecordType.Name = 'Buy' Limit 1];
        oppList[0].LeadSource = Null;
        Database.SaveResult result = Database.update(oppList[0], false);
        //System.assertEquals('These required fields must be completed: Lead Source',result.getErrors()[0].getMessage());
        
        Test.stopTest();
    }
    
    @isTest
    static void Test_16(){
        
        Trigger_Switch__c setting = new Trigger_Switch__c();
        setting.Name = 'Opportunity';
        setting.Is_Enabled__c =  true;
        insert setting;
        
        Test.startTest();
        
        List<Opportunity> oppList = [SELECT Id FROM Opportunity WHERE RecordType.Name = 'Buy' Limit 1];
        oppList[0].Listing_Date__c = Null;
        Database.SaveResult result = Database.update(oppList[0], false);
        //System.assertEquals('These required fields must be completed: Listing Date',result.getErrors()[0].getMessage());
        
        Test.stopTest();
    }
    
    @isTest
    static void Test_17(){
        
        Trigger_Switch__c setting = new Trigger_Switch__c();
        setting.Name = 'Opportunity';
        setting.Is_Enabled__c =  true;
        insert setting;
        
        Test.startTest();
        
        List<Opportunity> oppList = [SELECT Id FROM Opportunity WHERE RecordType.Name = 'Buy' Limit 1];
        oppList[0].StageName = 'Assessment Requested';
        oppList[0].Assessment__c = null;
        Database.SaveResult result = Database.update(oppList[0], false);
        //System.assertEquals('These required fields must be completed: Assessment',result.getErrors()[0].getMessage());
        
        Test.stopTest();
    }
    
    @isTest
    static void Test_18(){
        
        Trigger_Switch__c setting = new Trigger_Switch__c();
        setting.Name = 'Opportunity';
        setting.Is_Enabled__c =  true;
        insert setting;
        
        Test.startTest();
        
        List<Opportunity> oppList = [SELECT Id FROM Opportunity WHERE RecordType.Name = 'Buy' Limit 1];
        oppList[0].StageName = 'Offer Sheet Submit';
        oppList[0].Initial_List_Price__c = null;
        Database.SaveResult result = Database.update(oppList[0], false);
        //System.assertEquals('These required fields must be completed: Initial List Price',result.getErrors()[0].getMessage());
        
        Test.stopTest();
    }
    
    @isTest
    static void Test_19(){
        
        Trigger_Switch__c setting = new Trigger_Switch__c();
        setting.Name = 'Opportunity';
        setting.Is_Enabled__c =  true;
        insert setting;
        
        Test.startTest();
        
        List<Opportunity> oppList = [SELECT Id FROM Opportunity WHERE RecordType.Name = 'Buy' Limit 1];
        oppList[0].StageName = 'Offer Sheet Submit';
        oppList[0].Initial_Offer__c = null;
        Database.SaveResult result = Database.update(oppList[0], false);
        //System.assertEquals('These required fields must be completed: Initial Offer',result.getErrors()[0].getMessage());
        
        Test.stopTest();
    }
    
    @isTest
    static void Test_20(){
        
        Trigger_Switch__c setting = new Trigger_Switch__c();
        setting.Name = 'Opportunity';
        setting.Is_Enabled__c =  true;
        insert setting;
        
        Test.startTest();
        
        List<Opportunity> oppList = [SELECT Id FROM Opportunity WHERE RecordType.Name = 'Buy' Limit 1];
        oppList[0].StageName = 'Offer Sheet Submit';
        oppList[0].Current_List_Price__c = null;
        Database.SaveResult result = Database.update(oppList[0], false);
        //System.assertEquals('These required fields must be completed: Current List Price',result.getErrors()[0].getMessage());
        
        Test.stopTest();
    }
    
    @isTest
    static void Test_21(){
        
        Trigger_Switch__c setting = new Trigger_Switch__c();
        setting.Name = 'Opportunity';
        setting.Is_Enabled__c =  true;
        insert setting;
        
        Test.startTest();
        
        List<Opportunity> oppList = [SELECT Id FROM Opportunity WHERE RecordType.Name = 'Buy' Limit 1];
        oppList[0].StageName = 'Offer Sheet Approved';
        oppList[0].Initial_List_Price__c = null;
        Database.SaveResult result = Database.update(oppList[0], false);
        //System.assertEquals('These required fields must be completed: Initial List Price',result.getErrors()[0].getMessage());
        
        Test.stopTest();
    }
    
    @isTest
    static void Test_22(){
        
        Trigger_Switch__c setting = new Trigger_Switch__c();
        setting.Name = 'Opportunity';
        setting.Is_Enabled__c =  true;
        insert setting;
        
        Test.startTest();
        
        List<Opportunity> oppList = [SELECT Id FROM Opportunity WHERE RecordType.Name = 'Buy' Limit 1];
        oppList[0].StageName = 'Verbal';
        oppList[0].Initial_List_Price__c = null;
        Database.SaveResult result = Database.update(oppList[0], false);
        //System.assertEquals('These required fields must be completed: Initial List Price',result.getErrors()[0].getMessage());
        
        Test.stopTest();
    }
    @isTest
    static void Test_23(){
        Test.startTest();
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        List<Contact> conList = [SELECT Id FROM Contact LIMIT 2];
        
        Opportunity opp = new Opportunity();
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Investor').getRecordTypeId();
        opp.Name = 'Opp';
        opp.Lender_Name__c = conList[0].Id;
        opp.Lender_Approval__c = 'Y';
        opp.CloseDate = System.today();
        insert opp;
        
        opp.Lender_Name__c = conList[1].Id;
        update opp;
        
        opp.Lender_Name__c = NULL;
        opp.Lender_Approval__c = 'N';
        update opp;
        Test.stopTest();
    }
    
    
}