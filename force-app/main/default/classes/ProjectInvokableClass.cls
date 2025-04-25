public class ProjectInvokableClass {
    
    @InvocableMethod
    public static void setProjectId(List<Id> projectIds){
        updateProjectOpportunityRecord(projectIds);
    }
    
    @future
    public static void updateProjectOpportunityRecord(List<Id> projectIds){
        
        if(projectIds.size() > 0){
            Map<id,id> oppProjectMap = new Map<id,id>();
            for(Project__c project : [SELECT Id,Buy_Opportunity__c FROM Project__c WHERE Id IN : projectIds]){
                if(project.Buy_Opportunity__c != Null && !oppProjectMap.containsKey(project.Buy_Opportunity__c)){
                    oppProjectMap.put(project.Buy_Opportunity__c, project.id);
                }
            }
            
            if(!oppProjectMap.isEmpty()){
                List<Opportunity> oppList = new List<Opportunity>();
                for(Opportunity opp : [Select id,Project__c from Opportunity where id IN: oppProjectMap.keySet() ]){
                    if(oppProjectMap.containsKey(opp.id)){
                        opp.Project__c = oppProjectMap.get(opp.id);
                        oppList.add(opp);
                    }
                }
                
                if(oppList.size() > 0){
                    Update oppList;
                }
            }
        }
    } 
}