@isTest
public class OpportunityDocumentCtrlTest {
    
    @isTest static void method1(){
        
        Lead objLead = new Lead();
        objLead.Market__c = 'MEM';
        objLead.Bedrooms__c = '2';
        objLead.Car_Storage__c = 'DR';
        objLead.Square_Feet__c = 100;
        objLead.Year_Built__c = '1960';
        objLead.FirstName = 'testing';
        objLead.LastName = 'V1';
        objLead.Lead_Details__c = 'random testing';
        objLead.Street = 'teststreet';
        objLead.State = 'MS';
        objLead.City = 'testCity';
        objLead.Country = 'testCountry';
        objLead.PostalCode = 'test';
        objLead.Company = 'testing';
        objLead.LeadSource = 'Builder';
        objLead.Listing_Date__c = date.today();
        insert objLead;
        
        test.startTest();
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(objLead.Id);
        lc.setDoNotCreateOpportunity(false);
        lc.setConvertedStatus('Converted');
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
        
        Id accId =  lcr.getAccountId();
        Account accObj = new Account();
        accObj.Id = accId;
        accObj.Type = 'Vendor';
        update accObj;
        
        contact objCon1 = new contact();
        objCon1.LastName = 'test';
        objCon1.FirstName = 'First';
        objCon1.Email = 'test@gmail.com';
        objCon1.AccountId = accObj.Id;
        insert objCon1;
        system.debug('objCon1 :: ' +objCon1.Type__c );
        
        Id oppId = lcr.getOpportunityId();
        
        Opportunity oppty = new Opportunity();
        oppty.Id = oppId;
        oppty.Title_Company_Attorney__c = objCon1.Id;
        update oppty;
       
        OpportunityDocumentCtrl.updateFileType('Test1','0692i000000HS3MAAW','Contract_Document_1',oppId);
        OpportunityDocumentCtrl.getOpportunityContractField(oppId);
        OpportunityDocumentCtrl.sendEmailwithAttach(oppty);
        
        test.stopTest();
    }
}