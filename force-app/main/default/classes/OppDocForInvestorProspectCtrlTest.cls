@isTest
public class OppDocForInvestorProspectCtrlTest {
    
    @testSetup
    static void testData(){
        
        Id accRec = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Vendor - Pro Serv').getRecordTypeId();
        Account acc = new Account();
        acc.RecordTypeId = accRec;
        acc.Name = 'Test Account';
        acc.Type = 'Custodian';
        Insert acc;
        
        Id conRec = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Vendor').getRecordTypeId();
        Contact con = new Contact();
        con.RecordTypeId = conRec;
        con.LastName = 'TestContact';
        con.FirstName = 'Test';
        con.Email = 'test@abc.com';
        con.AccountId = acc.id;
        Insert con;
        
        Id RecordTypeIdOpp = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Investor Prospect').getRecordTypeId();
        // Opportunity List
        List<Opportunity> oppList = new List<Opportunity>();
        // 0
        oppList.add(
            new Opportunity(
                RecordTypeId = RecordTypeIdOpp,
                Name = 'Opp 0',
                StageName = 'Pre-Assessment',
                AccountId = acc.id,
                LeadSource = 'Facebook',
                CloseDate = date.today() ,
                Custodian_Contact__c = con.id,
                Market__c = 'MEM'
            )
        );
        Insert oppList;
        
        //Create Document
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        //Get Content Version
        List<ContentVersion> cvList = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        System.assertEquals(cvList.size(), 1);
        
        //Get Content Documents
        List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        System.assertEquals(cdList.size(), 1);
        
    }
    
    @isTest static void updateFileType_Test_1(){
        
        Test.startTest();
        List<Opportunity> oppList = [SELECT Id FROM Opportunity];
        List<ContentDocument> conDocList = [SELECT Id FROM ContentDocument];
        OppDocForInvestorProspectCtrl.updateFileType('fileName',conDocList[0].id, 'Contract_Document_1', oppList[0].id);
        OppDocForInvestorProspectCtrl.sendEmailwithAttach(oppList[0]);
        Test.stopTest();
    }
    
    @isTest static void updateFileType_Test_2(){
        
        Test.startTest();
        List<Opportunity> oppList = [SELECT Id FROM Opportunity];
        List<ContentDocument> conDocList = [SELECT Id FROM ContentDocument];
        OppDocForInvestorProspectCtrl.updateFileType('fileName',conDocList[0].id, 'Contract_Document_2', oppList[0].id);
        OppDocForInvestorProspectCtrl.sendEmailwithAttach(oppList[0]);
        Test.stopTest();
    }
    
    @isTest static void updateFileType_Test_3(){
        
        Test.startTest();
        List<Opportunity> oppList = [SELECT Id FROM Opportunity];
        List<ContentDocument> conDocList = [SELECT Id FROM ContentDocument];
        OppDocForInvestorProspectCtrl.updateFileType('fileName',conDocList[0].id, 'Contract_Document_3', oppList[0].id);
        OppDocForInvestorProspectCtrl.sendEmailwithAttach(oppList[0]);
        Test.stopTest();
    }
    
    @isTest static void updateFileType_Test_4(){
        
        Test.startTest();
        List<Opportunity> oppList = [SELECT Id FROM Opportunity];
        List<ContentDocument> conDocList = [SELECT Id FROM ContentDocument];
        OppDocForInvestorProspectCtrl.updateFileType('fileName',conDocList[0].id, 'Contract_Document_4', oppList[0].id);
        OppDocForInvestorProspectCtrl.sendEmailwithAttach(oppList[0]);
        Test.stopTest();
    }
    
    @isTest static void updateFileType_Test_5(){
        
        Test.startTest();
        List<Opportunity> oppList = [SELECT Id FROM Opportunity];
        List<ContentDocument> conDocList = [SELECT Id FROM ContentDocument];
        OppDocForInvestorProspectCtrl.updateFileType('fileName',conDocList[0].id, 'Contract_Document_5', oppList[0].id);
        OppDocForInvestorProspectCtrl.sendEmailwithAttach(oppList[0]);
        Test.stopTest();
    }
    
    @isTest static void updateFileType_Test_6(){
        
        Test.startTest();
        List<Opportunity> oppList = [SELECT Id FROM Opportunity];
        List<ContentDocument> conDocList = [SELECT Id FROM ContentDocument];
        OppDocForInvestorProspectCtrl.updateFileType('fileName',conDocList[0].id, 'Contract_Document_6', oppList[0].id);
        OppDocForInvestorProspectCtrl.sendEmailwithAttach(oppList[0]);
        Test.stopTest();
    }
    
    @isTest static void updateFileType_Test_7(){
        
        Test.startTest();
        List<Opportunity> oppList = [SELECT Id FROM Opportunity];
        List<ContentDocument> conDocList = [SELECT Id FROM ContentDocument];
        OppDocForInvestorProspectCtrl.updateFileType('fileName',conDocList[0].id, 'Contract_Document_7', oppList[0].id);
        OppDocForInvestorProspectCtrl.sendEmailwithAttach(oppList[0]);
        Test.stopTest();
    }
    
    @isTest static void updateFileType_Test_8(){
        
        Test.startTest();
        List<Opportunity> oppList = [SELECT Id FROM Opportunity];
        List<ContentDocument> conDocList = [SELECT Id FROM ContentDocument];
        OppDocForInvestorProspectCtrl.updateFileType('fileName',conDocList[0].id, 'Contract_Document_8', oppList[0].id);
        OppDocForInvestorProspectCtrl.sendEmailwithAttach(oppList[0]);
        Test.stopTest();
    }
    
    @isTest static void updateFileType_Test_9(){
        
        Test.startTest();
        List<Opportunity> oppList = [SELECT Id FROM Opportunity];
        List<ContentDocument> conDocList = [SELECT Id FROM ContentDocument];
        OppDocForInvestorProspectCtrl.updateFileType('fileName',conDocList[0].id, 'Contract_Document_9', oppList[0].id);
        OppDocForInvestorProspectCtrl.sendEmailwithAttach(oppList[0]);
        Test.stopTest();
    }
    
    @isTest static void getOpportunityContractField(){
        
        Test.startTest();
        List<Opportunity> oppList = [SELECT Id FROM Opportunity];
        List<ContentDocument> conDocList = [SELECT Id FROM ContentDocument];
        OppDocForInvestorProspectCtrl.getOpportunityContractField(null);
        Test.stopTest();
    }
    
}