public class OpportunityHouseDetailsController {
    
    
    @AuraEnabled
    public static House__c getHouse(String opportunityId){
        System.debug('opportunityId--'+opportunityId);
        if(String.isNotBlank(opportunityId)){
            String HouseId;
            List<Opportunity> opportunityList = [SELECT Id,Project_Evaluation_1__c,Project_Evaluation_2__c,Project_Evaluation_3__c,
                                                 Project_Evaluation_1_Status__c,Project_Evaluation_2_Status__c,Project_Evaluation_3_Status__c,
                                                 Project_Evaluation_1__r.House__c,Project_Evaluation_2__r.House__c,Project_Evaluation_3__r.House__c
                                                 FROM Opportunity WHERE Id=:opportunityId];
            
            for(Opportunity opp : opportunityList){
                if(opp.Project_Evaluation_1__c != null && opp.Project_Evaluation_1_Status__c == 'Selected'){
                    HouseId = opp.Project_Evaluation_1__r.House__c;
                }else if(opp.Project_Evaluation_2__c != null && opp.Project_Evaluation_2_Status__c == 'Selected'){
                    HouseId = opp.Project_Evaluation_2__r.House__c;
                }else if(opp.Project_Evaluation_3__c != null && opp.Project_Evaluation_3_Status__c == 'Selected'){
                    HouseId = opp.Project_Evaluation_3__r.House__c;
                }
            }
            System.debug('HouseId--'+HouseId);
            return returnHouseDetails(HouseId);
        }
        return null;
    }
    
    @AuraEnabled
    public static House__c returnHouseDetails(String HouseId){
        if(String.isNotBlank(HouseId)){
            return [SELECT Id, Name,Bathrooms__c,Bedrooms__c,Year_Built__c,Sq_Feet__c FROM House__c WHERE Id=: HouseId];
        }
        return null;
    }
    
}