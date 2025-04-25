public with sharing class UserAuditReportController {

 public Account userObj {get;set;}  
 public Date startDate {get;set;}
 public Date endDate {get;set;}
 public List<sobject> sObjectList{get;set;}
 public list<WrapperClass> wrpList{get;set;}
 public Boolean showExportButton{get;set;}
 
    public UserAuditReportController () {
        userObj = new Account(); 
        sObjectList = new List<sobject>();
        wrpList = new list<WrapperClass>();   
        showExportButton = false;
    }
    
    public void searchButton() {
        
        Map<String, UserAuditReportObjectName__c> customeSettingObjectName = UserAuditReportObjectName__c.getAll();
        wrpList.clear();
        sObjectList.clear();
        string qString = '';
        for (UserAuditReportObjectName__c obj : customeSettingObjectName.values()) {
            Id ownerObjId = userObj.CreatedById;
                        
            if(obj.Object_API_Name__c == 'Case') {
                qString = 'SELECT id,CaseNumber,CreatedById,CreatedDate,LastModifiedDate FROM ' + obj.Object_API_Name__c + '  WHERE ((DAY_ONLY(CreatedDate) >=: startDate AND DAY_ONLY(CreatedDate) <=: endDate) OR (DAY_ONLY(LastModifiedDate) >=: startDate AND DAY_ONLY(LastModifiedDate) <=: endDate)) AND CreatedById =: ownerObjId order by CreatedDate desc';                
            } else if(obj.Object_API_Name__c == 'Task' || obj.Object_API_Name__c == 'Event') {
                qString = 'SELECT id,Subject,CreatedById,CreatedDate,LastModifiedDate FROM ' + obj.Object_API_Name__c + '  WHERE ((DAY_ONLY(CreatedDate) >=: startDate AND DAY_ONLY(CreatedDate) <=: endDate) OR (DAY_ONLY(LastModifiedDate) >=: startDate AND DAY_ONLY(LastModifiedDate) <=: endDate)) AND CreatedById =: ownerObjId order by CreatedDate desc';     
            } else {
                qString = 'SELECT id,Name,CreatedById,CreatedDate,LastModifiedDate FROM ' + obj.Object_API_Name__c + '  WHERE ((DAY_ONLY(CreatedDate) >=: startDate AND DAY_ONLY(CreatedDate) <=: endDate) OR (DAY_ONLY(LastModifiedDate) >=: startDate AND DAY_ONLY(LastModifiedDate) <=: endDate)) AND CreatedById =: ownerObjId order by CreatedDate desc';   
            }
                        
            sObjectList.addAll(database.query(qString)); 
        }
                
        for(sobject sObj : sObjectList){
            string apiName = sObj.id.getSObjectType().getDescribe().getName();
            Schema.DescribeSobjectResult[] results = Schema.describeSObjects(new List<String>{apiName});
            
            WrapperClass wrp = new WrapperClass();
            wrp.sObjectRecord = sObj;
            wrp.objectName = results[0].getLabel();
            
            system.debug('sObj.get(LastModifiedDate)=='+sObj.get('LastModifiedDate')+'sObj.get(CreatedDate)=='+sObj.get('CreatedDate'));
            
            if(sObj.get('LastModifiedDate') != sObj.get('CreatedDate') && Date.VAlueOf(sObj.get('LastModifiedDate')) >= startDate 
               && Date.VAlueOf(sObj.get('CreatedDate')) <= endDate){
                wrp.type = 'Modified';
                wrp.typeDate = DateTime.VAlueOf(sObj.get('LastModifiedDate'));
            }Else{
                wrp.type = 'Created';                
                wrp.typeDate = DateTime.ValueOf(sObj.get('CreatedDate'));
            }
            
            wrpList.add(wrp);
        }
        
        if(!wrpList.isEmpty()) {
            showExportButton = true;            
        }
    }
    
    public PageReference Export_Data() 
    {
       PageReference newPage = New PageReference('/apex/UserAuditReport_Export');   
       newPage.setRedirect(false);             
       return newPage;   
    }

    public class WrapperClass{
        public sObject sObjectRecord{get;set;}
        public string objectName{get;set;}
        public string type{get;set;}
        public dateTime typeDate{get;set;}        
    }
}