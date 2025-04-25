public class AccountsWithDocsExpirationInfoHandler {
    
    @AuraEnabled
    public static accwithDocWrapperMain getaccountsWithDocsExpirationInfo() {
        
        Map<Id,Account> accountMap = new Map<Id,Account>([SELECT Id,Name FROM Account WHERE RecordType.Name =: 'Vendor - Field Service']);
        Map<Id,Id> contentDocsWithAccIdMap = new Map<Id,Id>();
        Map<Id,List<String>> accIdWithTypeofListMap = new Map<Id,List<String>>();
        
        if(!accountMap.isEmpty()){
            for(ContentDocumentLink cdLink: [SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN : accountMap.keySet()]){
                if(cdLink.ContentDocumentId != null){
                    contentDocsWithAccIdMap.put(cdLink.ContentDocumentId,cdLink.LinkedEntityId);
                }
            }
        }
        
        List<accwithDocWrapper> wrapperList15 = new List<accwithDocWrapper>();
        List<accwithDocWrapper> wrapperList30 = new List<accwithDocWrapper>();
        List<accwithDocWrapper> wrapperList45 = new List<accwithDocWrapper>();
        
        if(!contentDocsWithAccIdMap.isEmpty()){
            for(ContentVersion cv : [SELECT Id,CreatedDate, ContentDocumentId, Attachment_Type__c, Expiration_Date__c, Title, Status__c 
                                     FROM ContentVersion WHERE ContentDocumentId =: contentDocsWithAccIdMap.keySet() AND Expiration_Date__c != null AND Expiration_Date__c >= today order by Expiration_Date__c DESC])
            {
                System.debug('cv'+cv);
                if(cv.ContentDocumentId !=  null){
                    if(contentDocsWithAccIdMap.containskey(cv.ContentDocumentId)){
                        if(!accIdWithTypeofListMap.containskey(contentDocsWithAccIdMap.get(cv.ContentDocumentId))){
                            System.debug('cv,date.today().daysBetween(cv.Expiration_Date__c)'+date.today().daysBetween(cv.Expiration_Date__c));
                            if(cv.Expiration_Date__c >= date.today() && cv.Expiration_Date__c <= date.today().addDays(15)){
                                wrapperList15.add(new accwithDocWrapper(accountMap.get(contentDocsWithAccIdMap.get(cv.ContentDocumentId)),cv,date.today().daysBetween(cv.Expiration_Date__c)));
                            }else if(cv.Expiration_Date__c > date.today().addDays(15) && cv.Expiration_Date__c <= date.today().addDays(30)){
                                wrapperList30.add(new accwithDocWrapper(accountMap.get(contentDocsWithAccIdMap.get(cv.ContentDocumentId)),cv,date.today().daysBetween(cv.Expiration_Date__c)));
                            }else if(cv.Expiration_Date__c > date.today().addDays(30) && cv.Expiration_Date__c <= date.today().addDays(45)){
                                wrapperList45.add(new accwithDocWrapper(accountMap.get(contentDocsWithAccIdMap.get(cv.ContentDocumentId)),cv,date.today().daysBetween(cv.Expiration_Date__c)));
                            }
                            accIdWithTypeofListMap.put(contentDocsWithAccIdMap.get(cv.ContentDocumentId), new List<String>{cv.Attachment_Type__c});
                        }else{
                            List<String> docTypeList = accIdWithTypeofListMap.get(contentDocsWithAccIdMap.get(cv.ContentDocumentId));
                            if(!docTypeList.contains(cv.Attachment_Type__c)){
                                System.debug('cv,date.today().daysBetween(cv.Expiration_Date__c)'+date.today().daysBetween(cv.Expiration_Date__c));
                                if(cv.Expiration_Date__c >= date.today() && cv.Expiration_Date__c <= date.today().addDays(15)){
                                    wrapperList15.add(new accwithDocWrapper(accountMap.get(contentDocsWithAccIdMap.get(cv.ContentDocumentId)),cv,date.today().daysBetween(cv.Expiration_Date__c)));
                                }else if(cv.Expiration_Date__c > date.today().addDays(15) && cv.Expiration_Date__c <= date.today().addDays(30)){
                                    wrapperList30.add(new accwithDocWrapper(accountMap.get(contentDocsWithAccIdMap.get(cv.ContentDocumentId)),cv,date.today().daysBetween(cv.Expiration_Date__c)));
                                }else if(cv.Expiration_Date__c > date.today().addDays(30) && cv.Expiration_Date__c <= date.today().addDays(45)){
                                    wrapperList45.add(new accwithDocWrapper(accountMap.get(contentDocsWithAccIdMap.get(cv.ContentDocumentId)),cv,date.today().daysBetween(cv.Expiration_Date__c)));
                                }
                                docTypeList.add(cv.Attachment_Type__c);
                            }
                            accIdWithTypeofListMap.put(contentDocsWithAccIdMap.get(cv.ContentDocumentId), docTypeList);
                        }
                    }
                }
            }
        }
        
        List<accwithDocWrapper> wrapperList15New = new List<accwithDocWrapper>();
        List<accwithDocWrapper> wrapperList30New = new List<accwithDocWrapper>();
        List<accwithDocWrapper> wrapperList45New = new List<accwithDocWrapper>();
        
        for(Integer i = wrapperList15.size() - 1; i >= 0; i--){
            wrapperList15New.add(wrapperList15[i]);
        }
        for(Integer i = wrapperList30.size() - 1; i >= 0; i--){
            wrapperList30New.add(wrapperList30[i]);
        }
        for(Integer i = wrapperList45.size() - 1; i >= 0; i--){
            wrapperList45New.add(wrapperList45[i]);
        }
        
        return new accwithDocWrapperMain(wrapperList15New,wrapperList30New,wrapperList45New);
    }
    
    public class accwithDocWrapperMain{
        @AuraEnabled
        public List<accwithDocWrapper> days15List {get;set;}
        @AuraEnabled
        public List<accwithDocWrapper> days30List {get;set;}
        @AuraEnabled
        public List<accwithDocWrapper> days45List {get;set;}
        
        public accwithDocWrapperMain(List<accwithDocWrapper> days15List,List<accwithDocWrapper> days30List,List<accwithDocWrapper> days45List){
            this.days15List = days15List;
            this.days30List = days30List;
            this.days45List = days45List;
        }
    }
    
    public class accwithDocWrapper {
        
        @AuraEnabled
        public Account acc {get;set;}
        @AuraEnabled
        public ContentVersion cv {get;set;}
        @AuraEnabled
        public Integer noOfDaysLeft {get;set;}
        
        public accwithDocWrapper (Account acc, ContentVersion cv, Integer noOfDaysLeft){
            this.acc = acc;
            this.cv = cv;
            this.noOfDaysLeft = noOfDaysLeft;
        }
    }
}