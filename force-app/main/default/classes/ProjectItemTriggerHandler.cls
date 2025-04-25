public class ProjectItemTriggerHandler{

    public static void onBeforeUpdate(List<Project_Item__c> projectItemList, Map<Id, Project_Item__c> oldMap){
        closeParentCase(projectItemList, oldMap);
    }
    
    public static void onAfterUpdate(List<Project_Item__c> projectItemList, Map<Id, Project_Item__c> oldMap){
        addVendorDetails(projectItemList, oldMap);
    }
    
    public static void closeParentCase(List<Project_Item__c> projectItemList, Map<Id, Project_Item__c> oldMap){
        Set<Id> caseIds = new Set<Id>();
        Set<Id> projectItemIds = new Set<Id>();
        
        for(Project_Item__c projectItem: projectItemList){
            if(projectItem.Case__c != null && (projectItem.Maintenance_Status__c== 'Closed' || projectItem.Maintenance_Status__c == 'Closed - Not Fixing' || projectItem.Maintenance_Status__c == 'Closed - Inactivity') && projectItem.Maintenance_Status__c != oldMap.get(projectItem.Id).Maintenance_Status__c ){
                caseIds.add(projectItem.Case__c);
                projectItemIds.add(projectItem.Id);
            }
        }
        
        if(!projectItemIds.isEmpty()){
            Map<Id, Id> notClosedIdMap = new Map<Id, Id>();
            Set<String> maintenanceStatus = new Set<String>{'Closed', 'Closed - Not Fixing', 'Closed - Inactivity'};
            
            for(Project_Item__c pItem: [SELECT Id, Case__c FROM Project_Item__c WHERE Maintenance_Status__c NOT IN: maintenanceStatus AND Id NOT IN: projectItemIds AND Case__c IN: caseIds]){
                notClosedIdMap.put(pItem.Case__c, pItem.Id);
            }
            System.debug('notClosedIdMap-------'+notClosedIdMap);
            
            List<Case> caseListToUpdate = new List<Case>();
            
            for(Project_Item__c projectItem: projectItemList){
                if(!notClosedIdMap.isEmpty() && notClosedIdMap.containsKey(projectItem.Case__c)){
                }
                else{
                    Case cs = new Case(Id=projectItem.Case__c, Status='Closed');
                    caseListToUpdate.add(cs);
                    System.debug('caseListToUpdate-------'+caseListToUpdate);
                }
            }
            
            if(!caseListToUpdate.isEmpty()){
                update caseListToUpdate;
            }
        }
    }
    
    public static void addVendorDetails(List<Project_Item__c> projectItemList, Map<Id, Project_Item__c> oldMap){
        Set<Id> caseVendorIds = new Set<Id>();
        
        for(Project_Item__c projectItem: projectItemList){
            if(projectItem.Case__c != null && projectItem.Vendor_Acct__c != null && projectItem.Vendor_Acct__c != oldMap.get(projectItem.Id).Vendor_Acct__c){
                caseVendorIds.add(projectItem.Case__c);
            }
            
            if(projectItem.Case__c != null && projectItem.Completed_Date__c != null && projectItem.Completed_Date__c != oldMap.get(projectItem.Id).Completed_Date__c){
                caseVendorIds.add(projectItem.Case__c);
            }
        }
        
        if(!caseVendorIds.isEmpty()){
            Map<Id, Case> caseMapToUpdate = new Map<Id, Case>();
            
            for(Project_Item__c projectItem: [SELECT Id, Case__c, Completed_Date__c, Vendor_Acct__c, Vendor_Acct__r.Name FROM Project_Item__c WHERE Case__c IN: caseVendorIds AND (Vendor_Acct__c != null OR Completed_Date__c != null)]){
                
                if(caseMapToUpdate.containsKey(projectItem.Case__c)){
                    Case cs = caseMapToUpdate.get(projectItem.Case__c);
                    
                    if(projectItem.Vendor_Acct__c != null){
                        if(cs.Vendor_Name__c == ''){
                            cs.Vendor_Name__c = projectItem.Vendor_Acct__r.Name;
                        }
                        else{
                            cs.Vendor_Name__c += '; '+projectItem.Vendor_Acct__r.Name;
                        }
                    }
                    if(projectItem.Completed_Date__c != null){
                        if(cs.Vendor_Date_Closed__c == ''){
                            cs.Vendor_Date_Closed__c = ''+projectItem.Completed_Date__c.format();
                        }
                        else{
                            cs.Vendor_Date_Closed__c += '; '+projectItem.Completed_Date__c.format();
                        }
                    }
                    caseMapToUpdate.put(projectItem.Case__c, cs);
                }
                else{
                    Case cs = new Case(Id=projectItem.Case__c);
                    if(projectItem.Vendor_Acct__c != null){
                        cs.Vendor_Name__c = projectItem.Vendor_Acct__r.Name;
                    }
                    else{
                        cs.Vendor_Name__c = '';
                    }
                    if(projectItem.Completed_Date__c != null){
                        cs.Vendor_Date_Closed__c = ''+projectItem.Completed_Date__c.format();
                    }
                    else{
                        cs.Vendor_Date_Closed__c = '';
                    }
                    caseMapToUpdate.put(projectItem.Case__c, cs);
                }
            }
            
            if(!caseMapToUpdate.isEmpty()){
                update caseMapToUpdate.values();
            }
        }   
    }
}