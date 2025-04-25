/*
    Name             : VendorDocumentExpiryReminder
    Author           : Shweta F.
    Date             : 07/31/2019
    Description      : This class is used for vendor document expiry reminder.
*/
global class VendorDocumentExpiryReminder implements Database.Batchable<sObject> {

    //Start Method
    global Database.QueryLocator start(Database.BatchableContext bc) { 
        //Return vendor list where record type equal to vendor.  
        String vendorLabel = label.AccVendorRecType;
        String vendorFieldServiceLabel = label.AccountVendorFieldServiceRecordType;
        String Squery = 'SELECT Id,Name,Primary_Contact_Email__c FROM Account WHERE RecordType.Name =: vendorLabel OR RecordType.Name =: vendorFieldServiceLabel';
        return Database.getQueryLocator(Squery);
    }
       
    //Execute Method   
    global void execute(Database.BatchableContext bc, List<Account> accountList) {
		system.debug(':: ' + accountList);
        //Get Email content through Metadata        
        String VendorMetaEmailContent = [Select Email_Content__c From Vendor_Email_Content__mdt limit 1].Email_Content__c;                       
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        
        Map<Id,Account> accountMap = new Map<Id,Account>();                
        for(Account acc: accountList) {            
            accountMap.put(acc.id,acc);            
        }  
        Set<Id> newAccountSet = new Set<Id>();
        newAccountSet = accountMap.keySet();
        system.debug('newAccountSet :: ' + newAccountSet);
        //Get content document id through content document link where linkedentityid in account id.        
        Set<Id> contentDocumentIds = new Set<Id>(); 
        
        if(!newAccountSet.isEmpty()){
            for(ContentDocumentLink cdl : [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink 
                                           WHERE LinkedEntityId IN: newAccountSet]) { 
                                               contentDocumentIds.add(cdl.ContentDocumentId);    
                                           }
            system.debug('contentDocumentIds :: ' + contentDocumentIds);
            //Get content version record with account id where expiration date not equal to null and date next 30 days and attachment type not equal to null.       
            Map<Id,List<ContentVersion>> accountIdsWithContentVersionMap = new Map<Id,List<ContentVersion>>();
            for(ContentVersion cv: [SELECT Expiration_Date__c,Attachment_Type__c,FirstPublishLocationId,Title,ContentDocumentId 
                                    FROM ContentVersion WHERE Expiration_Date__c != Null AND Attachment_Type__c != Null AND IsLatest= true
                                    AND ContentDocumentId IN: contentDocumentIds ]) {
                System.debug('cv------'+cv);
                //Put account id with list of content version title in map.
                system.debug('cv.Expiration_Date__c :: ' + cv.Expiration_Date__c);
                system.debug('cv.FirstPublishLocationId :: ' + cv.FirstPublishLocationId);
                if(cv.Expiration_Date__c == System.today().addDays(15) && cv.FirstPublishLocationId != null) {
                    system.debug('System.today().addDays(15) :: ' + System.today().addDays(15));
                    if(accountIdsWithContentVersionMap.containsKey(cv.FirstPublishLocationId)) {  
                        accountIdsWithContentVersionMap.get(cv.FirstPublishLocationId).add(cv);                                  
                    }else {            
                       accountIdsWithContentVersionMap.put(cv.FirstPublishLocationId,new list<ContentVersion>{cv});
                    }            
                }
                if(cv.Expiration_Date__c == System.today().addDays(30) && cv.FirstPublishLocationId != null) {
                    system.debug('System.today().addDays(30) :: ' + System.today().addDays(30));
                    if(accountIdsWithContentVersionMap.containsKey(cv.FirstPublishLocationId)) {  
                        accountIdsWithContentVersionMap.get(cv.FirstPublishLocationId).add(cv);                                  
                    }else {            
                       accountIdsWithContentVersionMap.put(cv.FirstPublishLocationId,new list<ContentVersion>{cv});
                    }   
                     System.debug('accountIdsWithContentVersionMap------'+accountIdsWithContentVersionMap);         
                }
                if(cv.Expiration_Date__c == System.today().addDays(45) && cv.FirstPublishLocationId != null) {
                    system.debug('System.today().addDays(45) :: ' + System.today().addDays(45));
                    if(accountIdsWithContentVersionMap.containsKey(cv.FirstPublishLocationId)) {  
                        accountIdsWithContentVersionMap.get(cv.FirstPublishLocationId).add(cv);                                  
                    }else {            
                       accountIdsWithContentVersionMap.put(cv.FirstPublishLocationId,new list<ContentVersion>{cv});
                    }            
                }
                
            }
            //Iterate loop with account id.         
			//List<OrgWideEmailAddress> owea = [select Id from OrgWideEmailAddress where Address = 'manish@cmentor.com'];
			List<OrgWideEmailAddress> owea = [select Id from OrgWideEmailAddress where Address = 'suzi@reination.com'];
            for(id accId : accountIdsWithContentVersionMap.keySet()){
                List<String> toAddresses = new List<String>();                       
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                Messaging.SingleEmailMessage mail30 = new Messaging.SingleEmailMessage();
                Messaging.SingleEmailMessage mail45 = new Messaging.SingleEmailMessage();
                if ( owea.size() > 0 ) {
    				mail.setOrgWideEmailAddressId(owea.get(0).Id);
                    mail30.setOrgWideEmailAddressId(owea.get(0).Id);
                    mail45.setOrgWideEmailAddressId(owea.get(0).Id);
				}
                //Add vendor email in list.
                System.debug('accId-------'+accId);
                System.debug('accountMap-------'+accountMap);
                toAddresses.add(accountMap.get(accId).Primary_Contact_Email__c);
                system.debug('toAddresses ::: ' + toAddresses);
                mail.setToAddresses(toAddresses);
                mail30.setToAddresses(toAddresses);
                mail45.setToAddresses(toAddresses);
                //Email subject.
                mail.setSubject('Vendor Portal : Document Expiring Soon'); 
                mail30.setSubject('Vendor Portal : Document Expiring Soon'); 
                mail45.setSubject('Vendor Portal : Document Expiring Soon'); 
                //Return list of content version title.           
                // String CV_title = string.join(accountIdsWithContentVersionMap.get(accId).Attachment_Type__c,'<br/>');
                String messageBody = '';  
                String messageBody30 = '';  
                String messageBody45 = '';  
                
                String cvAttachType = '';    
                String cvAttachType30 = '';    
                String cvAttachType45 = '';    
                for(ContentVersion cv: accountIdsWithContentVersionMap.get(accId)) {
                    if(cv.Expiration_Date__c == System.today().addDays(15)) {
                        system.debug('System.today().addDays(15) ;; ' + System.today().addDays(15));
                        String str = VendorMetaEmailContent.replace('[','fifteen (15) days');
                        
                        messageBody = '<html><body>Hi ' + accountMap.get(accId).Name + ',<br/><br/>'+ str +'<br/><br/></body></html>';
                        if(cv.Attachment_Type__c == 'License'){
                            cvAttachType += cvAttachType == '' ? '<li>Business License</li>' : '<li>Business License</li>';
                        }else{
                            cvAttachType += cvAttachType == '' ? '<li>'+cv.Attachment_Type__c+'</li>' : '<li>'+cv.Attachment_Type__c+'</li>';
                        }                        
                    }
                    if(cv.Expiration_Date__c == System.today().addDays(30)) {
                        system.debug('System.today().addDays(30) ;; ' + System.today().addDays(30));
                        String str = VendorMetaEmailContent.replace('[','thirty (30) days');
                        messageBody30 = '<html><body>Hi ' + accountMap.get(accId).Name + ',<br/><br/>'+ str +'<br/><br/></body></html>';
                        if(cv.Attachment_Type__c == 'License'){
                            cvAttachType30 += cvAttachType30 == '' ? '<li>Business License</li>' : '<li>Business License</li>';
                        }else{
                            cvAttachType30 += cvAttachType30 == '' ? '<li>'+cv.Attachment_Type__c+'</li>' : '<li>'+cv.Attachment_Type__c+'</li>';  
                        }
                        
                    }
                    if(cv.Expiration_Date__c == System.today().addDays(45)) {
                        system.debug('System.today().addDays(45) ;; ' + System.today().addDays(45));
                        String str = VendorMetaEmailContent.replace('[','forty five (45) days');
                        messageBody45 = '<html><body>Hi ' + accountMap.get(accId).Name + ',<br/><br/>'+ str +'<br/><br/></body></html>';
                        if(cv.Attachment_Type__c == 'License'){
                            cvAttachType45 += cvAttachType45 == '' ? '<li>Business License</li>' : '<li>Business License</li>';
                        }else{
                            cvAttachType45 += cvAttachType45 == '' ? '<li>'+cv.Attachment_Type__c+'</li>' : '<li>'+cv.Attachment_Type__c+'</li>';
                        }                      
                    }   
                }
                
                /*     
                for(ContentVersion cv: accountIdsWithContentVersionMap.get(accId)) {
                    if(cv.Expiration_Date__c == System.today().addDays(15)) {
                        String str = VendorMetaEmailContent.replace('[','(fifteen (15)) days');
                        messageBody = '<html><body>Hi ' + accountMap.get(accId).Name + ',<br/><br/>'+ str.replace('{',cv.Attachment_Type__c)+'<br/><br/><b>Regards,</b><br/></body></html>';
                    }
                    if(cv.Expiration_Date__c == System.today().addDays(30)) {
                        String str = VendorMetaEmailContent.replace('[','(thirty (30)) days');
                        messageBody = '<html><body>Hi ' + accountMap.get(accId).Name + ',<br/><br/>'+ str.replace('{',cv.Attachment_Type__c)+'<br/><br/><b>Regards,</b><br/></body></html>';
                    }
                    if(cv.Expiration_Date__c == System.today().addDays(45)) {
                        String str = VendorMetaEmailContent.replace('[','(forty five (45)) days');
                        messageBody = '<html><body>Hi ' + accountMap.get(accId).Name + ',<br/><br/>'+ str.replace('{',cv.Attachment_Type__c)+'<br/><br/><b>Regards,</b><br/></body></html>';
                    }                
                }
                */
                
                messageBody = messageBody.replace('{','<ul>'+cvAttachType+'</ul>');
                messageBody30 = messageBody30.replace('{','<ul>'+cvAttachType30+'</ul>');
                messageBody45 = messageBody45.replace('{','<ul>'+cvAttachType45+'</ul>');
                
                //Email content body.                                                
                mail.setHtmlBody(messageBody); 
                mail30.setHtmlBody(messageBody30); 
                mail45.setHtmlBody(messageBody45); 
                if(messageBody.length() > 0){
                    mailList.add(mail); 
                }
                if(messageBody30.length() > 0){
                    mailList.add(mail30); 
                }
                if(messageBody45.length() > 0){
                    mailList.add(mail45); 
                }
            }
            //Send email when list greater than zero.            
            if(mailList.size()>0)
                Messaging.sendEmail(mailList);
        }
    }
   
    //Finish Method 
    global void finish(Database.BatchableContext bc) {
    }
    
}