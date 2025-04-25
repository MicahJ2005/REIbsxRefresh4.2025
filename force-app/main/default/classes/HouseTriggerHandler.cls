/* **************************************************************************
*
* Controller Class: HouseTriggerHandler
* Created by Anil Meghnathi: 14/09/2018
*
* - Trigger Handler Class for House Trigger
*
* - Modifications:
* - Anil Meghnathi, 14/09/2018 – Initial Development
* - Sophia Murphy (Demand Chain), 04/04/20224
* -			- Changes to updateAccountInformation
* -			- No queries in loops; only call if "important" changes are made
************************************************************************** */
public class HouseTriggerHandler {
    // Flag to skip trigger
    public static Boolean isSkipTrigger = false;
    
    /*
    *   Executed:   On after insert of houses
    *   Purpose:    Start job to create folder strutcure
    *   Parameters: 
    *   UnitTests:  
    */
    public void onAfterInsert(Map<Id, House__c> newHousesById){
        if(!isSkipTrigger){
            System.enqueueJob(new edCreateHouseFolderStructureQueueable(newHousesById.keySet()));
        }
        map<string,id> oppIdWithHouseIdMap = new map<string,id>();
        
        for(House__c house : newHousesById.values()){
            if(house.Opportunity_ID__c != null){                oppIdWithHouseIdMap.put(house.Opportunity_ID__c,house.id);
            }
        }
        
        if(!oppIdWithHouseIdMap.isEmpty()){            list<opportunity> oppList = new list<opportunity>();
            for(opportunity opp : [SELECT id,Leased_Property__c FROM opportunity WHERE id IN: oppIdWithHouseIdMap.KeySet()]){                opp.Leased_Property__c = oppIdWithHouseIdMap.get(opp.id);
                oppList.add(opp);
            }
            
            if(!oppList.isEmpty())                update oppList;
        }
      
    }
    public void onBeforeUpdate(List<House__c> houseNewList, Map<Id,House__c> houseOldMap){
        for(House__c obj : houseNewList){
        
            if(houseOldMap.get(obj.Id).Bathrooms__c != obj.Bathrooms__c){              obj.Old_Bathrooms_Value__c = houseOldMap.get(obj.Id).Bathrooms__c;  
            }
            if(houseOldMap.get(obj.Id).Bedrooms__c != obj.Bedrooms__c){              obj.Old_Bedrooms_Value__c = houseOldMap.get(obj.Id).Bedrooms__c;  
            }
            if(houseOldMap.get(obj.Id).Car_Storage_Parking__c != obj.Car_Storage_Parking__c){              obj.Old_Car_Storage_Parking_Value__c = string.valueOf(houseOldMap.get(obj.Id).Car_Storage_Parking__c);  
            }
            if(houseOldMap.get(obj.Id).Sq_Feet__c != obj.Sq_Feet__c){              obj.Old_Sq_Feet_Value__c = string.valueOf(houseOldMap.get(obj.Id).Sq_Feet__c);  
            }
            if(houseOldMap.get(obj.Id).Year_Built__c != obj.Year_Built__c){              obj.Old_Year_Built_Value__c = houseOldMap.get(obj.Id).Year_Built__c;  
            }
            if(houseOldMap.get(obj.Id).House_Type__c != obj.House_Type__c){              obj.Old_House_Type_Value__c = houseOldMap.get(obj.Id).House_Type__c;  
            }
        }
    }
    
    //Changed to accept MAPS so we can look for changes
    //public void updateAccountInformation(List<House__c> houseNewList){
    public void updateAccountInformation(Map<Id, House__c> houseNewMap, Map<Id, House__c> houseOldMap) {
        
        List <Account> accountsToUpdate = new List<Account>();
        Set<Id> accountIds = new Set<Id>();
        //for(House__c iterHouse : houseNewList){ 
        //    accountIds.add(iterHouse.Investor__c);
        //}
        
        for(Id houseId : houseNewMap.keySet()) {
            House__c newHouse = houseNewMap.get(houseId);
            House__c oldHouse;
            if(houseOldMap != null) {
                oldHouse = houseOldMap.get(houseId);
            }
            
            //We only want to process this account if it's a NEW house; or the Investor has changed
            if(oldHouse == null || newHouse.Investor__c != oldHouse.Investor__c) {
                accountIds.add(newHouse.Investor__c);
            }
        }
        
        /** Commented out - replaced with the below
         * List<Account> ownerAccounts = [SELECT Id, Name,Outside_Properties_Managed__c,REI_Properties_Managed__c FROM Account WHERE Id IN :accountIds];
        System.debug('Owner List: '+ ownerAccounts);
        for(Account accountIter :ownerAccounts){
            System.debug('the account is '+ accountIter.Id);
            List<House__c> externalProperties = [SELECT Id, Name, Investor__c, Status__c, Outside_Investor__c, Management_Source__c FROM House__c WHERE Investor__r.Id =:accountIter.Id AND (Status__c = 'Managed' AND Management_Source__c = 'Outside')]; 
            List<House__c> reiPurchased = [SELECT Id, Name, Investor__r.Id ,Status__c,Outside_Investor__c,Management_Source__c FROM House__c WHERE Investor__r.Id =:accountIter.Id AND (Status__c = 'Managed' AND Management_Source__c = 'Purchased From REI')]; 
            accountIter.Outside_Properties_Managed__c = externalProperties.size();
            accountIter.REI_Properties_Managed__c = reiPurchased.size();
            accountsToUpdate.add(accountIter);
        }
		*/
        
        if(accountIds.size() > 0) {
           for(Account acct: [SELECT Id, Name, Outside_Properties_Managed__c, REI_Properties_Managed__c 
                    , ( SELECT Id, Name, Investor__c, Status__c, Outside_Investor__c, Management_Source__c 
                        FROM HousesInvestor__r 
                        WHERE Status__c = 'Managed'
                        // cannot follow the same aggregate relationship twice... so - we do the split on Management Source below
                      )
                FROM Account
                WHERE Id IN :accountIds]) {
                    
                    Integer outsideCount = 0;
                    Integer reiCount = 0;
                    
                    for(House__c hse : acct.HousesInvestor__r) {
                        if(hse.Management_Source__c == 'Outside') {
                            outsideCount++;
                        }
                        if(hse.Management_Source__c == 'Purchased From REI') {
                            reiCount++;
                        }
                    } //END: for(House__c hse
                    
                    //Only update the account if there is an actual change!
                    if(acct.Outside_Properties_Managed__c != outsideCount || acct.REI_Properties_Managed__c != reiCount) {
                        Account newAcct = new Account(Id = acct.Id);
                        newAcct.Outside_Properties_Managed__c = outsideCount;
                        newAcct.REI_Properties_Managed__c = reiCount;
                        accountsToUpdate.add(newAcct);
                    }
                                  
           } //END: for(Account acct       
        } //END: if(accountIds.size() > 0) 
        
        System.debug('Final Accounts to update: ' +accountsToUpdate);
        if(accountsToUpdate.size() > 0){
        	update accountsToUpdate;
        }
	}
}