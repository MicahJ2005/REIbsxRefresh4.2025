public class OpportunityBuyHouseDetailsCtrl {
    
    @AuraEnabled
    public static List<House__c> getHouse(String opportunityId){
        
        if(String.isNotBlank(opportunityId)){
            
            Set<Id> HouseIdSet = new Set<Id>();
            List<Opportunity> opportunityList = [SELECT Id,Sale_Comp_1__c,Sale_Comp_2__c,Sale_Comp_3__c,Rent_Comp_1__c,Rent_Comp_2__c,Rent_Comp_3__c 
                                                 FROM Opportunity WHERE Id=:opportunityId];
            
            for(Opportunity opp : opportunityList){
                if(opp.Sale_Comp_1__c != null){
                    HouseIdSet.add(opp.Sale_Comp_1__c);
                }
                if(opp.Sale_Comp_2__c != null){
                    HouseIdSet.add(opp.Sale_Comp_2__c);
                }
                if(opp.Sale_Comp_3__c != null){
                    HouseIdSet.add(opp.Sale_Comp_3__c);
                }
                if(opp.Rent_Comp_1__c != null){
                    HouseIdSet.add(opp.Rent_Comp_1__c);
                }
                if(opp.Rent_Comp_2__c != null){
                    HouseIdSet.add(opp.Rent_Comp_2__c);
                }
                if(opp.Rent_Comp_3__c != null){
                    HouseIdSet.add(opp.Rent_Comp_3__c);
                }
                
            }
            if(HouseIdSet.size() > 0){
                System.debug('HouseIdSet--'+HouseIdSet);
                return [SELECT Id, Name, Appraised_SqFt__c, Appraised_Amount__c, Appraised_Date__c, Lease_Closing_Date__c, Rent_SqFt__c,
                        Rent_Year_1__c, Sale_Amount__c, Sale_Amount_SqFt__c, Source__c,Sales_Date__c,
                        Bedrooms__c, Bathrooms__c, Car_Storage_Parking__c, Year_Built__c, Sq_Feet__c
                        FROM House__c WHERE Id IN : HouseIdSet];
                
            }
        }
        return null;
    }   
}