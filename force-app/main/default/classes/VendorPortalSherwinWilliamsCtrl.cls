public class VendorPortalSherwinWilliamsCtrl{  
    public List<Portal_Message__c> portalMessages {get; set;}
    
    public VendorPortalSherwinWilliamsCtrl(){
        portalMessages = new List<Portal_Message__c>();
        Date today = System.today();      
        portalMessages = [SELECT  Id, Message__c FROM Portal_Message__c WHERE (Notify__c = 'Community' OR (Notify__c = 'User' AND User__c =: UserInfo.getUserId())) AND Tab__c = 'Sherwin Williams' AND Start_Date__c <=: today AND End_Date__c >=: today ORDER BY Name];
    }
}