Public with sharing class LeadTriggerHandler{
    
    public static void onAfterUpdate(list<Lead> leadNewList,Map<Id,Lead> oldLeadMap){
        map<id,lead> oppIdWithLeadObjMap = new map<id,lead>();
        map<id,id> leadIdWithHouseIdMap = new map<id,id>();
        set<string> citySet = new set<string>();
        set<string> streetSet = new set<string>();
        set<string> stateSet = new set<string>();
        set<string> zipSet = new set<string>();
        set<string> countrySet = new set<string>();
        Set<String> StreetNameStrSet = new Set<String>();
        
        
        Id InvestorProspectRecordType = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Investor Prospect').getRecordTypeId();
        /* for(Lead obj : leadNewList){
            
            if((obj.Status == 'Qualified' || obj.Status == 'Converted') && (oldLeadMap.get(obj.Id).Status == 'Dead')){
                obj.addError('Dead Lead cannot be converted');
            }
            
            if(obj.RecordTypeId == InvestorProspectRecordType && obj.Status == 'Converted'){
                System.debug('Condition True');
                if(String.isBlank(obj.Timeline_of_Investment_life__c) || 
                   String.isBlank(obj.Timeframe_to_transact_on_a_property__c) || 
                   String.isBlank(obj.Who_are_you_investing_with_if_anyone__c) || 
                   String.isBlank(obj.The_Why__c) || 
                   String.isBlank(obj.Expecations_as_property_owner__c) || 
                   String.isBlank(obj.Experience_as_an_investor__c) ||
                   obj.How_much_are_you_looking_to_invest__c == Null || 
                   String.isBlank(obj.Purchase_Method__c) || 
                   String.isBlank(obj.Time_Zone__c)){
                       obj.addError('Please fill required fields before converting it.');
                   }
            }
          }
        */
        
        List<Opportunity> oUpdList = new List<Opportunity> ();
        for (Lead l : leadNewList) {
            if (l.IsConverted && 
                l.convertedOpportunityId != null && 
                Schema.SObjectType.Lead.getRecordTypeInfosByName().get(label.Buyer_RecordType_On_Lead).getRecordTypeId() == l.recordTypeId){
                    StreetNameStrSet.add(l.Street);    
                }
        }
        Map<String,Id> houseNameVsIdMap = new Map<String,Id>();
        
        for(House__c houseObj : [SELECT Id, Name FROM House__c WHERE Name IN: StreetNameStrSet]){
            houseNameVsIdMap.put(houseObj.Name,houseObj.id);
        }
        for (Lead l : leadNewList) {
            if (l.IsConverted && 
                l.convertedOpportunityId != null && 
                houseNameVsIdMap.containskey(l.Street) && 
                Schema.SObjectType.Lead.getRecordTypeInfosByName().get(label.Buyer_RecordType_On_Lead).getRecordTypeId() == l.recordTypeId){
                    oUpdList.add(new Opportunity(id = l.convertedOpportunityId,
                                                 House__c = houseNameVsIdMap.get(l.Street), 
                                                 Follow_Up_Sold_Date__c = date.today(),
                                                 Source_Contact__c = l.convertedContactId)
                                 
                                );
                }
            
        }
        update oUpdList; 
        
        for(Lead lead : leadNewList){
            if(lead.isConverted && lead.ConvertedOpportunityId != null && Schema.SObjectType.Lead.getRecordTypeInfosByName().get(label.Buyer_RecordType_On_Lead).getRecordTypeId() == lead.recordTypeId){
                oppIdWithLeadObjMap.put(lead.ConvertedOpportunityId,lead);
                citySet.add(lead.city);
                streetSet.add(lead.street);
                stateSet.add(lead.state);
                zipSet.add(lead.postalCode);
                countrySet.add(lead.country);
            }
        }
        
        if(!citySet.isEmpty() || !streetSet.isEmpty() || !stateSet.isEmpty() || !zipSet.isEmpty() || !countrySet.isEmpty()){
            for(House__c house : [SELECT id,City__c,Country__c,State__c,Zip_Code__c,Street_Address__c FROM House__c WHERE Street_Address__c IN: streetSet]){
                                      for(lead lead : oppIdWithLeadObjMap.values()){
                                          if(lead.city == house.City__c && lead.country == house.Country__c && lead.state == house.State__c && lead.postalCode == house.Zip_Code__c && lead.street == house.Street_Address__c){
                                              leadIdWithHouseIdMap.put(lead.id,house.id);
                                              break;
                                          }
                                      }
                                  }
        }
        
        Map<Id, House__c> oppToHouseMap = new Map<Id, House__c>();  
        Map<Id, Opportunity> idOppMap = new Map<Id, Opportunity>();
        List<House__c> lstHouseInsert = new List<House__c>();
        for(id oppId : oppIdWithLeadObjMap.keySet()){
            opportunity opp = new opportunity();
            opp.Id = oppId;
            opp.Name = oppIdWithLeadObjMap.get(oppId).Street;
            opp.Info_Source__c = oppIdWithLeadObjMap.get(oppId).LeadSource;
            
            if(!leadIdWithHouseIdMap.isEmpty() && leadIdWithHouseIdMap.containsKey(oppIdWithLeadObjMap.get(oppId).id)){
                opp.Leased_Property__c = leadIdWithHouseIdMap.get(oppIdWithLeadObjMap.get(oppId).id);
            }
            else{
                if(!oppIdWithLeadObjMap.isEmpty() && oppIdWithLeadObjMap.containsKey(oppId)){
                    Lead ld = new Lead();
                    ld = oppIdWithLeadObjMap.get(oppId);
                }
            }
            idOppMap.put(opp.Id, opp);    
        }
        
        if(!lstHouseInsert.isEmpty()){
            insert lstHouseInsert;
        }
        
        if(!idOppMap.Values().isEmpty()){
            update idOppMap.Values();
        }                      
    }
    
    public static void onBeforeUpdate(List<Lead> newLeadList, Map<Id,Lead> oldLeadMap){
        Id InvestorsRecordType = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Investor Prospect').getRecordTypeId();
        for(Lead obj: newLeadList){
            system.debug(' :: ::  ' + obj.Status);
            if((obj.Status == 'Qualified' || obj.Status == 'Converted') && (oldLeadMap.get(obj.Id).Status == 'Dead') )
            {
                obj.addError('Dead Lead cannot be converted');
            }
        }
    }
    
    public static void onBeforeInsert(List<Lead> newLeadList){
       
        for(Lead ld : newLeadList){
            if(UserInfo.getName() == 'Hubspot Admin'){
                ld.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Investor Prospect').getRecordTypeId();
            }
            if(UserInfo.getName() != 'Hubspot Admin' && ld.RecordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Investor Prospect').getRecordTypeId()){
                if(ld.Original_Source_Data_3__c == NULL){
                    ld.addError('Please fill Original Source Data 3');
                }else if(ld.Original_Source_Data_4__c == NULL){
                    ld.addError('Please fill Original Source Data 4');
                }
            }
        }
        //update custObj;

    }
    
    public static void onAfterInsert(List<Lead> newLeadList){
        
        Set<String> StreetNameStrSet = new Set<String>();
        Set<String> houseNameStrSet = new Set<String>();
        
        for(Lead objLead : newLeadList){
            if(Schema.SObjectType.Lead.getRecordTypeInfosByName().get(label.Buyer_RecordType_On_Lead).getRecordTypeId() == objLead.recordTypeId){
                StreetNameStrSet.add(objLead.Street);
            }
        }
        
        for(House__c houseObj : [SELECT Id, Name FROM House__c WHERE Name IN: StreetNameStrSet]){
            houseNameStrSet.add(houseObj.Name);
        }
        
        List<House__c> houseList = new List<House__c>();
        for(Lead ld : newLeadList){
            if(Schema.SObjectType.Lead.getRecordTypeInfosByName().get(label.Buyer_RecordType_On_Lead).getRecordTypeId() == ld.recordTypeId){
                if(houseNameStrSet.contains(ld.Street)){
                    ld.addError('House with this information is already present in the system');
                }else{
                    House__c houseObj = new House__c(Name = ld.Street, Street_Address__c=ld.Street,
                                                     City__c=ld.City, State__c=ld.State,Zip_Code__c=ld.PostalCode,
                                                     Country__c=ld.Country,Market__c=ld.Market__c,
                                                     Bathrooms__c=ld.Bathrooms__c,Lead_Details__c=ld.Lead_Details__c,
                                                     List_Price__c=ld.List_Price__c, Bedrooms__c=ld.Bedrooms__c,House_Type__c=ld.House_Type__c,                                                  
                                                     Car_Storage_Parking__c=ld.Car_Storage__c,Sq_Feet__c=ld.Square_Feet__c,
                                                     Year_Built__c=ld.Year_Built__c
                                                    );
                    houseList.add(houseObj);
                }
            }
            
        }
        
        if(houseList.size() > 0){
            insert houseList;    
        }
        
    }
    
    
    public static void updateOpportunity(List<Lead> LeadList, Map<Id,Lead> oldMap){
        System.debug('Inside updateOpportunity');
        String ownerName;
        Set<id> oppIdSet = new Set<id>();
        set<id> accIdSet = new set<id>();
        set<id> conIdSet = new set<id>();
        Map<Id,String> convOppIdToLeadEmailMap = new Map<Id,String>();
        Map<Id, Lead> convertedLeadMap = new Map<Id, Lead>();
        //Map<Id, Lead> convertedLeadMapOpp = new Map<Id, Lead>();
        Map<String, Account> accMap = new Map<String, Account>();
        for(Account acc : [SELECT Id, Name FROM Account WHERE RecordType.Name = 'Affiliates']){ 
            accMap.put(acc.Name, acc);
        }

        Id InvestorsRecordType = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Investor Prospect').getRecordTypeId();
        for(Lead ld : [SELECT Id, OwnerId, Owner.Name, IsConverted, ConvertedOpportunityId, ConvertedAccountId, ConvertedContactId, RecordTypeId, Email, Original_Source_Data_1__c, Original_Source_Data_4__c, Original_Source_Type__c,Client_Referral__c FROM Lead WHERE Id IN: LeadList]){ //LeadList
            if(ld.IsConverted && !oldMap.get(ld.id).IsConverted && ld.RecordTypeId == InvestorsRecordType){
                ownerName = ld.Owner.Name;
                System.debug('Lead Owner Name '+ld.Owner.Name);
                System.debug('Owner Name '+ownerName);
                oppIdSet.add(ld.ConvertedOpportunityId);
                accIdSet.add(ld.ConvertedAccountId);
                conIdSet.add(ld.ConvertedContactId);
                convertedLeadMap.put(ld.ConvertedAccountId, ld);
                System.debug(accIdSet);
                System.debug(accMap);
                //convertedLeadMapOpp.put(ld.ConvertedOpportunityId, ld);
                if(!convOppIdToLeadEmailMap.containskey(ld.id)){
                    if(String.isNotBlank(ld.Email)){
                        convOppIdToLeadEmailMap.put(ld.ConvertedOpportunityId,ld.Email);
                    }
                }
            }
        }
        
        // Update contact record type of converted contact
        if(conIdSet.size() > 0){
            Id InvestorRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Investor').getRecordTypeId();
            List<Contact> conList =  new List<Contact>();
            for(Contact con : [SELECT Id,RecordTypeId FROM Contact WHERE Id IN : conIdSet]){
                if(con.RecordTypeId != InvestorRecordType){
                    Contact newCon = new Contact();
                    newCon.id = con.id;
                    newCon.RecordTypeId = InvestorRecordType;
                    conList.add(newCon);
                }
            }
            if(!conList.isEmpty()){
                update conList;
            }
        }
        
        if(oppIdSet.size() > 0){
            Id InvestorRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Investor').getRecordTypeId();
            List<Opportunity> oppList =  new List<Opportunity>();
            for(Opportunity opp : [SELECT Id,RecordTypeId FROM Opportunity WHERE Id IN : oppIdSet]){
                if(opp.RecordTypeId != InvestorRecordType){
                    Opportunity newopp = new Opportunity();
                    newopp.id = opp.id;
                    newopp.RecordTypeId = InvestorRecordType;
                    newopp.StageName = 'Pre-Qual';
                    if(convOppIdToLeadEmailMap.containskey(opp.id)){
                        newopp.Lead_Email__c = convOppIdToLeadEmailMap.get(opp.id);
                    }
                    oppList.add(newopp);
                }
            }
            if(!oppList.isEmpty()){
                update oppList;
            }
        }
        
        if(accIdSet.size() > 0){
            Id InvestorRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Investor Prospect').getRecordTypeId();
            List<Account> accList =  new List<Account>();
            for(Account acc : [SELECT Id,RecordTypeId FROM Account WHERE Id IN : accIdSet]){
                System.debug('Inside loop');
                //if(acc.RecordTypeId != InvestorRecordType){
                    Account newAcc = new Account();
                    newAcc.id = acc.id;
                    newAcc.RecordTypeId = InvestorRecordType;
                    newAcc.Type = 'Investor';
                    if(convertedLeadMap.get(acc.Id).Original_Source_Data_4__c != NULL){
                        newAcc.Referred_By_Detail__c = convertedLeadMap.get(acc.Id).Original_Source_Data_4__c;
                    }else if(convertedLeadMap.get(acc.Id).Original_Source_Data_1__c != NULL){
                        newAcc.Referred_By_Detail__c = convertedLeadMap.get(acc.Id).Original_Source_Data_1__c;
                    }
                    if(convertedLeadMap.get(acc.Id).Client_Referral__c != NULL){
                        newAcc.Referred_by__c = convertedLeadMap.get(acc.Id).Client_Referral__c;
                    }else if(convertedLeadMap.get(acc.Id).Original_Source_Type__c != NULL){
                        if(accMap.get(convertedLeadMap.get(acc.Id).Original_Source_Type__c) != NULL){
                            newAcc.Referred_by__c = accMap.get(convertedLeadMap.get(acc.Id).Original_Source_Type__c).Id;
                        } 
                    }
                    newAcc.Set_By_New__c = convertedLeadMap.get(acc.Id).Owner.Name;
                    accList.add(newAcc);
                    System.debug(newAcc);
                    System.debug(convertedLeadMap.get(acc.Id).Original_Source_Data_4__c);
                    System.debug(convertedLeadMap.get(acc.Id).Client_Referral__c);
                    System.debug(convertedLeadMap.get(acc.Id).Owner.Name);
                    System.debug('Referred By '+newAcc.Referred_by__c);
                    System.debug('Referred By Detail '+newAcc.Referred_By_Detail__c);
                    System.debug('Set By New '+newAcc.Set_By_New__c);
                //}                
            }
            if(!accList.isEmpty()){
                update accList;
            }            
        }
    } 
}