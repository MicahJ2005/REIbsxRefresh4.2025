/*
    Name             : VendorDocumentExpiredBatch
    Author           : Shweta F.
    Date             : 08/06/2019
    Description      : This class is used for vendor document expired batch .
*/
global class VendorDocumentExpiredBatch implements Database.Batchable<sObject> {

    //Start Method
    global Database.QueryLocator start(Database.BatchableContext bc) {
    
        //Return vendor list where record type equal to vendor. 
        String vendorLabel = label.AccVendorRecType;
        String vendorFieldServiceLabel = label.AccountVendorFieldServiceRecordType;
        String Squery = 'SELECT id,Name,Vendor_Email__c FROM Account WHERE RecordType.Name =: vendorLabel OR RecordType.Name =: vendorFieldServiceLabel';                           
        return Database.getQueryLocator(Squery); 
    }
    
    //Execute Method
    global void execute(Database.BatchableContext BC, List<Account> accountList) {

        Set<Id> accountIdsSet = new Set<Id>();                
        for(Account acc: accountList) {                        
            accountIdsSet.add(acc.id);                          
        }
        
        If(!accountIdsSet.isEmpty()) {  
            //Get content document id through content document link where linkedentityid in account id.        
            Set<Id> contentDocumentIds = new Set<Id>(); 
            for(ContentDocumentLink cdl : [SELECT id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN: accountIdsSet]) { 
                contentDocumentIds.add(cdl.ContentDocumentId);               
            } 
                   
            List<ContentVersion> contentVersionList = [SELECT Expiration_Date__c,Status__c,ContentDocumentId FROM ContentVersion WHERE Status__c != 'Expired' AND Expiration_Date__c =: System.today() AND Expiration_Date__c != Null AND ContentDocumentId IN: contentDocumentIds ]; 
            //Iterate content version loop.
            for(ContentVersion cv: contentVersionList) {                                    
                cv.Status__c = 'Expired';                       
            }
            
            try {
                update contentVersionList;
                System.debug(contentVersionList);        
            } catch(Exception ex) {
                system.debug('======error====='+ex.getMessage()+'======Line No====='+ ex.getLineNumber());
            } 
        }       
    } 
      
    //Finish Method 
    global void finish(Database.BatchableContext BC) {
    }
}