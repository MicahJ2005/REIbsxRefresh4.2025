public class ProjectItemEditExtn{
    Project_Item__c projectItem;
    
    public ProjectItemEditExtn(ApexPages.StandardController sc){
        projectItem = [SELECT Id, Case__r.Status FROM Project_Item__c WHERE Id =: sc.getId()];
    }
    
    public PageReference createProjectItem(){
        if(projectItem.Case__r.Status == 'Closed'){
            PageReference pgRef = Page.PICaseClosed;
            pgRef.getParameters().put('id', projectItem.Id);
            return pgRef;
        }
        else{
            PageReference pgRef = Page.CreateProjectItem;
            pgRef.getParameters().put('id', projectItem.Id);
            return pgRef;
        }
    }
}