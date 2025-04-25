public class ChildAccountsWithPropertyOwnerCtrl {
    
    
    @AuraEnabled
    public static Map<String,List<Property_Owner__c>> getChildAccountsWithPropertyOwner(String recordId,String status){
        
        String sObjName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
        Id ownerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Owner').getRecordTypeId();
        Id investorOwnerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Investor Owner').getRecordTypeId();
        
        if(String.isNotBlank(recordId) && status == 'Active'){
            if(sObjName == 'Account'){
                Map<String,List<Property_Owner__c>> accIdWithListOfPropertyOwnerMap = new Map<String,List<Property_Owner__c>>();
                for(Account acc : [SELECT Id,Name,(SELECT Id,Property__c,Property__r.Name,Share__c FROM Property_Owners__r WHERE Status__c = 'Active') FROM Account WHERE ParentId =:recordId 
                                   AND RecordTypeId=: ownerRecordTypeId AND Parent.RecordTypeId != null 
                                   AND Parent.RecordTypeId =: investorOwnerRecordTypeId]){
                                       for(Property_Owner__c prtyOwner : acc.Property_Owners__r){
                                           if(!accIdWithListOfPropertyOwnerMap.containsKey(acc.id +'-'+acc.Name)){
                                               accIdWithListOfPropertyOwnerMap.put(acc.id +'-'+ acc.Name , new List<Property_Owner__c>{prtyOwner});
                                           }else{
                                               accIdWithListOfPropertyOwnerMap.get(acc.id +'-'+ acc.Name).add(prtyOwner);
                                           }
                                       }                    
                                   }
                System.debug('accIdWithListOfPropertyOwnerMap'+accIdWithListOfPropertyOwnerMap);
                return accIdWithListOfPropertyOwnerMap;
            }
        }else if(String.isNotBlank(recordId) && status == 'All'){
            if(sObjName == 'Account'){
                Map<String,List<Property_Owner__c>> accIdWithListOfPropertyOwnerMap = new Map<String,List<Property_Owner__c>>();
                for(Account acc : [SELECT Id,Name,(SELECT Id,Property__c,Property__r.Name,Share__c FROM Property_Owners__r) FROM Account WHERE ParentId =:recordId 
                                   AND RecordTypeId=: ownerRecordTypeId AND Parent.RecordTypeId != null 
                                   AND Parent.RecordTypeId =: investorOwnerRecordTypeId]){
                                       for(Property_Owner__c prtyOwner : acc.Property_Owners__r){
                                           if(!accIdWithListOfPropertyOwnerMap.containsKey(acc.id +'-'+acc.Name)){
                                               accIdWithListOfPropertyOwnerMap.put(acc.id +'-'+ acc.Name , new List<Property_Owner__c>{prtyOwner});
                                           }else{
                                               accIdWithListOfPropertyOwnerMap.get(acc.id +'-'+ acc.Name).add(prtyOwner);
                                           }
                                       }                    
                                   }
                System.debug('accIdWithListOfPropertyOwnerMap'+accIdWithListOfPropertyOwnerMap);
                return accIdWithListOfPropertyOwnerMap;
            }
        }
        return null;
    } 
}