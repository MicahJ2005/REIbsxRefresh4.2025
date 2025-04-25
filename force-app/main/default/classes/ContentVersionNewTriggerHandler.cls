public class ContentVersionNewTriggerHandler{
    
    public static void afterUpdate(List<ContentVersion> cvList, Map<Id, ContentVersion> oldCvMap){
        Map<Id, Id> cvDocIdMap = new Map<Id, Id>();
        Map<Id, Id> cvDocUploadedIdMap = new Map<Id, Id>();
        Map<Id, Id> cvDocRejectedIdMap = new Map<Id, Id>();
        Map<Id, Id> cvDocApprovedIdMap = new Map<Id, Id>();
        Map<Id, ContentVersion> iDContentVersionMap = new Map<Id, ContentVersion>();
        
        for(ContentVersion cv: cvList){
            if(cv.Status__c == 'Uploaded' && cv.Status__c != oldCvMap.get(cv.Id).Status__c){
                cvDocUploadedIdMap.put(cv.ContentDocumentID, cv.Id);
            }
            if((cv.Status__c == 'Rejected' || cv.Status__c == 'Expired') && cv.Status__c != oldCvMap.get(cv.Id).Status__c){
                cvDocRejectedIdMap.put(cv.ContentDocumentID, cv.Id);
                cvDocIdMap.put(cv.ContentDocumentID, cv.Id);
                iDContentVersionMap.put(cv.ContentDocumentID, cv);
            }
            if(cv.Status__c == 'Approved / Filed' && cv.Status__c != oldCvMap.get(cv.Id).Status__c){
                cvDocApprovedIdMap.put(cv.ContentDocumentID, cv.Id);
                cvDocIdMap.put(cv.ContentDocumentID, cv.Id);
            }
        }
        
        if(!cvDocUploadedIdMap.isEmpty()){
            Set<Id> accountIds = new Set<Id>();
            for(ContentDocumentLink cdl: [SELECT ContentDocumentID, LinkedEntity.type, LinkedEntityId 
                                        FROM ContentDocumentLink WHERE ContentDocumentID IN: cvDocUploadedIdMap.keySet()])
            {
                if(cdl.LinkedEntity.type == 'Account'){
                    accountIds.add(cdl.LinkedEntityId);
                }                            
            }
            
            List<Account> uploadedAccounts = [SELECT Id, Status__c FROM Account WHERE Id IN: accountIds 
                                                AND Is_Uploaded__c = false];
            
            if(!uploadedAccounts.isEmpty()){
                for(Account acc: uploadedAccounts){
                    acc.Is_Uploaded__c = true;
                }
            
                update uploadedAccounts;
            }
        }
       
        if(!cvDocRejectedIdMap.isEmpty()){
            Set<Id> accountIds = new Set<Id>();
            Map<Id,Id> accountContentDocumentIdMap = new Map<Id,Id>();
            for(ContentDocumentLink cdl: [SELECT ContentDocumentID, LinkedEntity.type, LinkedEntityId 
                                        FROM ContentDocumentLink WHERE ContentDocumentID IN: cvDocRejectedIdMap.keySet()])
            {
                if(cdl.LinkedEntity.type == 'Account'){
                    accountIds.add(cdl.LinkedEntityId);
                    accountContentDocumentIdMap.put(cdl.LinkedEntityId, cdl.ContentDocumentID);
                }                            
            }
            
            if(!accountIds.isEmpty()){
                List<Account> onHoldAccounts = [SELECT Id, Status__c FROM Account WHERE Id IN: accountIds
                                                AND Status__c != 'On Hold'];
                
                if(!onHoldAccounts.isEmpty()){
                    for(Account acc: onHoldAccounts){
                        acc.Expiration_Date__c = iDContentVersionMap.get(accountContentDocumentIdMap.get(acc.Id)).Expiration_Date__c;
                        if(acc.Status__c!= 'Onboarding'){
                            acc.Status__c = 'On Hold';
                        } 
                        acc.Attachment_Type__c = iDContentVersionMap.get(accountContentDocumentIdMap.get(acc.Id)).Attachment_Type__c;
                    }
                    update onHoldAccounts;
                }
            }
        }
        
        if(!cvDocApprovedIdMap.isEmpty()){
            Set<Id> accountIds = new Set<Id>();
            Map<Id, Id> accountCdActualIdMap = new Map<Id, Id>();
            Map<Id, Id> accountCdIdMap = new Map<Id, Id>();
            for(ContentDocumentLink cdl: [SELECT ContentDocumentId, LinkedEntity.type, LinkedEntityId 
                                        FROM ContentDocumentLink WHERE ContentDocumentID IN: cvDocApprovedIdMap.keySet()])
            {
                if(cdl.LinkedEntity.type == 'Account'){
                    accountCdIdMap.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
                }                            
            }
            
            if(!accountCdIdMap.isEmpty()){
                Set<Id> contentDocumentIds = new Set<Id>(); 
                for(ContentDocumentLink cdl : [SELECT id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN: accountCdIdMap.values()]) { 
                    contentDocumentIds.add(cdl.ContentDocumentId); 
                    accountCdActualIdMap.put(cdl.ContentDocumentId, cdl.LinkedEntityId);              
                }  
                
                accountIds.addAll(accountCdIdMap.values());
                
                System.debug('accountIds------'+accountIds);
                 System.debug('accountCdIdMap------'+accountCdIdMap);
                
                Set<Id> set_accountRejectedIds = new Set<Id>();
                Set<String> statusSet = new Set<String>{'Rejected', 'Expired'};
                for(ContentVersion cv: [SELECT Id, ContentDocumentId, Status__c FROM ContentVersion 
                                                WHERE ContentDocumentId IN: contentDocumentIds 
                                                AND Id NOT In: cvDocApprovedIdMap.values() 
                                                AND Status__c IN: statusSet AND IsLatest = true])
                {
                    System.debug('cv------'+cv);
                    if(!accountIds.isEmpty() && accountCdActualIdMap.containsKey(cv.ContentDocumentId)){
                        System.debug('map------'+accountCdActualIdMap.get(cv.ContentDocumentId));
                        if(accountIds.contains(accountCdActualIdMap.get(cv.ContentDocumentId))){
                            System.debug('map1------'+accountCdActualIdMap.get(cv.ContentDocumentId));
                            accountIds.remove(accountCdActualIdMap.get(cv.ContentDocumentId));   
                        }                 
                    }
                }
                System.debug('accountIds------'+accountIds);
                
                List<Account> onHoldAccounts = [SELECT Id, Status__c FROM Account WHERE Id IN: accountIds AND Status__c = 'On Hold'];
                System.debug('onHoldAccounts------'+onHoldAccounts);
                for(Account acc: onHoldAccounts){
                    acc.Status__c = 'Active';
                }
                
                if(!onHoldAccounts.isEmpty()){
                    update onHoldAccounts;
                }
            }
        }
        
        System.debug('cvDocIdMap------'+cvDocIdMap);
        if(!cvDocIdMap.isEmpty()){
            Set<Id> accountIds = new Set<Id>();
            Map<Id, Id> accountCdActualIdMap = new Map<Id, Id>();
            Map<Id, Id> accountCdIdMap = new Map<Id, Id>();
            for(ContentDocumentLink cdl: [SELECT ContentDocumentId, LinkedEntity.type, LinkedEntityId 
                                        FROM ContentDocumentLink WHERE ContentDocumentID IN: cvDocIdMap.keySet()])
            {
                if(cdl.LinkedEntity.type == 'Account'){
                    accountCdIdMap.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
                }                            
            }
            System.debug('accountCdIdMap------'+accountCdIdMap);
            
            if(!accountCdIdMap.isEmpty()){
                Set<Id> contentDocumentIds = new Set<Id>(); 
                for(ContentDocumentLink cdl : [SELECT id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN: accountCdIdMap.values()]) { 
                    contentDocumentIds.add(cdl.ContentDocumentId); 
                    accountCdActualIdMap.put(cdl.ContentDocumentId, cdl.LinkedEntityId);              
                }  
                
                accountIds.addAll(accountCdIdMap.values());
                System.debug('accountIds------'+accountIds);
                
                
                Set<Id> set_accountRejectedIds = new Set<Id>();
                for(ContentVersion cv: [SELECT Id, ContentDocumentId, Status__c FROM ContentVersion 
                                                WHERE ContentDocumentId IN: contentDocumentIds 
                                                AND Id NOT IN: cvDocIdMap.values() AND Status__c ='Uploaded' 
                                                AND IsLatest = true])
                {
                    System.debug('cv------'+cv);
                    if(!accountIds.isEmpty() && accountCdActualIdMap.containsKey(cv.ContentDocumentId)){
                        System.debug('map------'+accountCdActualIdMap.get(cv.ContentDocumentId));
                        if(accountIds.contains(accountCdActualIdMap.get(cv.ContentDocumentId))){
                            System.debug('map1------'+accountCdActualIdMap.get(cv.ContentDocumentId));
                            accountIds.remove(accountCdActualIdMap.get(cv.ContentDocumentId));   
                        }                 
                    }
                }
                System.debug('accountIds------'+accountIds);
                
                List<Account> uploadedAccounts = [SELECT Id, Status__c FROM Account WHERE Id IN: accountIds AND Is_Uploaded__c= true];
                System.debug('uploadedAccounts------'+uploadedAccounts);
                for(Account acc: uploadedAccounts){
                    acc.Is_Uploaded__c = false;
                }
                
                if(!uploadedAccounts.isEmpty()){
                    update uploadedAccounts;
                }
            }
        }
    }
}