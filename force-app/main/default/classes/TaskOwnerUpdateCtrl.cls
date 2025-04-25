public class TaskOwnerUpdateCtrl {
    
    public task taskObj {get;set;}
    public string currentRecordId {get;set;}
    
    public TaskOwnerUpdateCtrl(){
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
        if(String.isNotBlank(currentRecordId)){
            taskObj = [SELECT Id,New_Assignee__c,OwnerId FROM Task WHERE Id =: currentRecordId];
        }
    }
    
    public PageReference saveAndRedirect(){
        
        try{
            System.debug('taskObj'+taskObj);
            if(taskObj.New_Assignee__c != null){
                taskObj.OwnerId = taskObj.New_Assignee__c;
                taskObj.New_Assignee__c = null;
                Update taskObj;
                
                PageReference pg = new PageReference('/'+taskObj.id);
                pg.setRedirect(true);
                return pg;
                
            }
        }Catch(Exception ex){
            System.debug('Error'+ex.getMessage());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage()));
        }
        
        return null;
    }
}