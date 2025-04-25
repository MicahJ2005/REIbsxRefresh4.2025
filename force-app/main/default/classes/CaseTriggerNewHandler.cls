/**
    Name        : CaseTriggerNewHandler
    Date        : Jan 3, 2019
    Author      : Shweta Fulara(Cmentor)
    Description : Handler class for CaseTriggerNew.
**/
public class CaseTriggerNewHandler{
    
    //Create Project for Maintenance Case
    public static void onBeforeInsert(List<Case> caseList){
        Set<Id> propertyIds = new Set<Id>();
        for(Case cs: caseList){
            propertyIds.add(cs.Property__c);
        }
        
        Map<Id, House__c> houseMap = new Map<Id, House__c>([SELECT Id, Investor__c, Name FROM House__c WHERE Id IN: propertyIds]);
        
        Map<Id, List<Opportunity>> oppMap = new Map<Id, List<Opportunity>>();
        String investorRecType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Investor').getRecordTypeId();
        for(Opportunity opp : [SELECT Id, Name, Closing_Date__c, AccountId, RecordTypeId FROM Opportunity 
                               WHERE RecordTypeId =: investorRecType ORDER BY Closing_Date__c DESC]){
            List<Opportunity> oppList = new List<Opportunity>();
            if(!oppMap.containsKey(opp.AccountId)){
                if(opp.Name.length() >= 7){
                    oppList.add(opp);
                    oppMap.put(opp.AccountId, oppList);
                }
            }else{
                if(opp.Name.length() >= 7){
                    oppList = oppMap.get(opp.AccountId);
                    oppList.add(opp);
                    oppMap.put(opp.AccountId, oppList);
                }                
            }
        }
        
        for(Case cs: caseList){
            if(!houseMap.isEmpty()){
                if(houseMap.containsKey(cs.Property__c)){
                    cs.Investor__c = houseMap.get(cs.Property__c).Investor__c;
                }
            }
            if(cs.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId()){
                if(cs.Property__c != NULL && cs.Investor__c != NULL){                    
                    if(oppMap.size() > 0 && oppMap.containsKey(cs.Investor__c) && houseMap.containsKey(cs.Property__c)){
                        for(Opportunity oppObj : oppMap.get(cs.Investor__c)){
                            if(houseMap.get(cs.Property__c).Name.substring(0,7) == oppObj.Name.substring(0,7)){
                                cs.Owner_Closing_Date_New__c = oppObj.Closing_Date__c;
                                break;
                            }
                        }
                    }                                        
                }                
            }
        }
    }
    
    public static void onBeforeUpdate(List<Case> caseList){
        Set<Id> propertyIds = new Set<Id>();
        for(Case cs: caseList){
            propertyIds.add(cs.Property__c);
        }
        
        Map<Id, House__c> houseMap = new Map<Id, House__c>([SELECT Id, Investor__c, Name FROM House__c WHERE Id IN: propertyIds]);
        System.debug(houseMap);
        
        Map<Id, List<Opportunity>> oppMap = new Map<Id, List<Opportunity>>();
        Map<String, List<Opportunity>> oppNameMap = new Map<String, List<Opportunity>>();
        String investorRecType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Investor').getRecordTypeId();
        for(Opportunity opp : [SELECT Id, Name, Closing_Date__c, AccountId, RecordTypeId FROM Opportunity 
                               WHERE RecordTypeId =: investorRecType ORDER BY Closing_Date__c DESC]){
            // to get opportunity by Id
            List<Opportunity> oppList = new List<Opportunity>();
            if(!oppMap.containsKey(opp.AccountId)){
                if(opp.Name.length() >= 7){
                    oppList.add(opp);
                    oppMap.put(opp.AccountId, oppList);
                }
            }else{
                if(opp.Name.length() >= 7){
                    oppList = oppMap.get(opp.AccountId);
                    oppList.add(opp);
                    oppMap.put(opp.AccountId, oppList); 
                }                
            }            			
        }
        
        for(Case cs: caseList){
            if(cs.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId()){
                if(cs.Property__c != NULL && cs.Investor__c != NULL){                   
                    if(oppMap.size() > 0 && oppMap.containsKey(cs.Investor__c) && houseMap.containsKey(cs.Property__c)){
                        for(Opportunity oppObj : oppMap.get(cs.Investor__c)){
                            if(houseMap.get(cs.Property__c).Name.substring(0,7) == oppObj.Name.substring(0,7)){
                                cs.Owner_Closing_Date_New__c = oppObj.Closing_Date__c;
                                break;
                            } 
                        }                        
                    }                                        
                }
            }
        }
    }
    //DEPRECATED: As now we have new screen to create PI
    /*
    //Create Project for Maintenance Case
    public static void onAfterUpdate(List<Case> caseList, Map<Id, Case> oldMap){
        createProject(caseList, oldMap);
    }
    
    //Create Project from Case of Record Type Maintenance
    public static void createProject(List<Case> caseList, Map<Id, Case> oldMap){
        //Create Project using case 
        Map<Id, Project__c> caseProjectMap = new Map<Id, Project__c>();
        Map<Id, Project_Item__c> caseProjectItemMap = new Map<Id, Project_Item__c>();
        Id maintenanceCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
        Id maintenanceProjectRecTypeId = Schema.SObjectType.Project__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
        
        for(Case cs: caseList)
        {
            if(cs.RecordTypeId == maintenanceCaseRecTypeId && cs.Property__c != NULL && cs.Status == 'Create Project' && cs.Status != oldMap.get(cs.Id).Status){
                Project__c project = new Project__c(House__c=cs.Property__c, CategoryGlobal__c=cs.CategoryGlobal__c,
                                                   Description__c=cs.Description, Account__c= cs.AccountId, Work_Order_Number__c=cs.Work_Order_Number__c,
                                                   Case__c=cs.Id, RecordTypeId=maintenanceProjectRecTypeId, 
                                                  
                                                   Case_Status__c=cs.Status);
                if(cs.ClosedDate != null){
                    project.Date_Closed__c=cs.ClosedDate.date();
                }
                if(cs.CreatedDate != null){
                    project.Date_Created__c=cs.CreatedDate.date();
                }
                caseProjectMap.put(cs.Id, project);
                
                Project_Item__c projectItem = new Project_Item__c(CategoryGlobal__c=cs.CategoryGlobal__c, Description__c=cs.Description, Status__c='Active');
                caseProjectItemMap.put(cs.Id, projectItem);
            }
        }
        
        if(!caseProjectMap.isEmpty()){
            insert caseProjectMap.values();
            if(!caseProjectItemMap.isEmpty()){
                List<Project_Item__c> projectItemList= new List<Project_Item__c>();
                for(Id caseId: caseProjectMap.keySet()){
                    caseProjectItemMap.get(caseId).Project__c = caseProjectMap.get(caseId).Id;
                    projectItemList.add(caseProjectItemMap.get(caseId));
                }
                if(!projectItemList.isEmpty()){
                    insert projectItemList;
                }
            }    
        }
    }
    */
    
}