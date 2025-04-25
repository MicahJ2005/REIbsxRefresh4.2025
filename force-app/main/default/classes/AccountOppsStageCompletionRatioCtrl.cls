public class AccountOppsStageCompletionRatioCtrl {
    
    @AuraEnabled
    public static wrapper getRelatedOpportunities(String recordId) {
        
        if(String.isNotBlank(recordId)){
            List<Account> accList = [SELECT Id FROM Account WHERE Id =: recordId AND RecordType.Name =: 'Vendor - Pro Serv' AND Type =: 'Agent/Wholesaler'];
            if(!accList.isEmpty()){
                List<Opportunity> oppList = [SELECT Id, CreatedDate, Name, StageName, Market__c, Contract_Closing_Date__c, Date_Visited__c, Contract_Accepted_Date__c
                                             FROM Opportunity WHERE AccountId =: recordId ORDER By CreatedDate DESC];
                if(!oppList.isEmpty()){
                    Decimal noOfPurchasedOpp = 0;
                    Decimal noOfAssessmentOpp = 0;
                    Decimal noOfContractedOpp = 0;
                    wrapper newWrap = new wrapper();
                    for(Opportunity opp : oppList){
                        if(opp.Contract_Closing_Date__c != null){
                            noOfPurchasedOpp ++;
                        }
                        if(opp.Date_Visited__c != null){
                            noOfAssessmentOpp ++;
                        }
                        if(opp.Contract_Accepted_Date__c != null){
                            noOfContractedOpp ++;
                        }
                    }
                    newWrap.oppList = oppList;
                    newWrap.totalOpportunities = oppList.size();
                    newWrap.totalAssessmentOpportunities = Integer.valueOf(noOfAssessmentOpp);
                    newWrap.assessmentByTotalOpp = ((noOfAssessmentOpp * 100) / oppList.size()).setScale(2);
                    newWrap.totalContractedOpportunities = Integer.valueof(noOfContractedOpp);
                    newWrap.contractByAssessments = noOfAssessmentOpp > 0 ? ((noOfContractedOpp / noOfAssessmentOpp) * 100).setScale(2) : 0;
                    newWrap.contractByOpportunities = ((noOfContractedOpp / oppList.size()) * 100).setScale(2);
                    newWrap.totalPurchasedOpportunities = Integer.valueof(noOfPurchasedOpp);
                    newWrap.contractedRatePurchase = ((noOfPurchasedOpp * 100) / oppList.size()).setScale(2);
                    return newWrap;
                }
            }
        }
        return null;
    }

    public class wrapper {
        @AuraEnabled
        public List<Opportunity> oppList {get;set;}
        @AuraEnabled
        public Integer totalOpportunities {get;set;}
        @AuraEnabled
        public Integer totalAssessmentOpportunities {get;set;}
        @AuraEnabled
        public Decimal assessmentByTotalOpp {get;set;}
        @AuraEnabled
        public Integer totalContractedOpportunities {get;set;}
        @AuraEnabled
        public Decimal contractByAssessments {get;set;}
        @AuraEnabled
        public Decimal contractByOpportunities {get;set;}
        @AuraEnabled
        public Integer totalPurchasedOpportunities {get;set;}
        @AuraEnabled
        public Decimal contractedRatePurchase {get;set;}
    }  
}