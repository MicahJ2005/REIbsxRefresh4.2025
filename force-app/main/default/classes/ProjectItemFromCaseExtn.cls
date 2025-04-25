public class ProjectItemFromCaseExtn{

    Case cs;
    
    public ProjectItemFromCaseExtn(ApexPages.StandardController sc){
        cs = [SELECT Id, Status FROM Case WHERE Id =: sc.getId()];
    }
    
    public PageReference createProjectItem(){
        
        if(cs.Status == 'Closed'){
            PageReference pgRef = Page.PICaseClosed;
            pgRef.getParameters().put('id', cs.Id);
            return pgRef;
        }
        else{
            PageReference pgRef = Page.CreateProjectItem;
            pgRef.getParameters().put('id', cs.Id);
            return pgRef;
        }
    }
}