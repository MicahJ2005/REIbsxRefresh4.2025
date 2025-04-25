public class AccountRelatedOpportunitiesCtrl {
    
    
    @AuraEnabled
    public static List<Opportunity> getAccountRelatedOpporunities(String opportunityId){
        if(String.isNotBlank(opportunityId)){
            List<Opportunity> oppList = [SELECT Id,AccountId FROM Opportunity WHERE Id=: opportunityId Limit 1];
            if(oppList[0] != null && oppList[0].AccountId != null){
                return returnAccountRelatedOppotunities(oppList[0].AccountId);
            }
           /* if(oppList[0] != null && oppList[0].AccountId != null 
                 && oppList[0].RecordType.id==Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Investor').getRecordTypeId()){
                return returnInvestorAccountRelatedOpportunities(oppList[0].AccountId);
            } */
        }
        return null;
    }
    
    @AuraEnabled
    public static List<Opportunity> returnAccountRelatedOppotunities(String accountId){
        if(String.isNotBlank(accountId)){
            return [SELECT Id,Name,Market__c,StageName,LeadSource,Listing_Date__c,Current_List_Price__c,Current_Offer__c,
                    Closing_Concessions__c,Additional_Purchase_Costs__c,MI_Purchase_Date__c FROM Opportunity WHERE AccountId=:accountId Limit 10];
        }
        return null;
    }
    
    @AuraEnabled
    public static list<Opportunity> returnInvestorAccountRelatedOpportunities(String opportunityId){
        List<Opportunity> oppList = [SELECT Id,AccountId FROM Opportunity WHERE Id=: opportunityId Limit 1];
        if(oppList[0] != null && oppList[0].AccountId != null && String.isNotBlank(oppList[0].AccountId)){
            return [SELECT Id,Name,Market__c,StageName,Asking_Price__c,Owner_Account__c,Owner_Account__r.Name,
                    Purchase_Method__c,Closing_Date__c,Contract_Titling__c,Lender__c FROM Opportunity WHERE AccountId=:oppList[0].AccountId Limit 10];
        }
        return null;
    }
}