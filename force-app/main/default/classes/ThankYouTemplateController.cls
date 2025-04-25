public with sharing class ThankYouTemplateController{
    
    public PageReference thankYouSave(){
        try{
            String selectedOpt = ApexPages.currentPage().getParameters().get('selectedOpt');
            Id objId = ApexPages.currentPage().getParameters().get('id');
            List<Project_Item__c> projectItemList = [SELECT Id, Maintenance_Status__c,Maintenance_Unsatisfied_Reason__c,
                                                        Confirmation_of_Satisfaction__c FROM Project_Item__c 
                                                        WHERE Id=: objId AND Confirmation_of_Satisfaction__c = false];
            if(!projectItemList.isEmpty()){
                Project_Item__c  projectItem = new Project_Item__c();
                projectItem = projectItemList[0];
                if(selectedOpt == 'Satisfied'){
                    projectItem.Maintenance_Status__c = 'Closed';
                    projectItem.Confirmation_of_Satisfaction__c = true;
                }
                else{
                    projectItem.Maintenance_Status__c = selectedOpt.substringBefore(' -');
                    projectItem.Maintenance_Unsatisfied_Reason__c = selectedOpt.substringAfter('- ');
                    projectItem.Confirmation_of_Satisfaction__c = true;
                }
                System.debug('projectItem-----'+projectItem);
                
                update projectItem;
            }
        }
        catch(Exception e){
            System.debug('error-----'+e.getMessage());
        }
        
        return null;
    }
}