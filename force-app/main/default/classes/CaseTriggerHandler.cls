public class CaseTriggerHandler {
	
    public static void caseAssign(List<Case> caseInfo){
        System.debug('the information is at follows'+ caseInfo);
        Id itRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('IT Team Support').getRecordTypeId();
        List<Id> caseIds = new List<Id>{};
        List<AssignmentRule> AR = new List<AssignmentRule>{};
        AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
        for(Case iterCase : caseInfo){
            if(iterCase.RecordTypeId == itRecordType){
        		for (Case theCase:caseInfo){
                    caseIds.add(theCase.Id);} 
            	}
        }
        if(caseIds.size()>0){
    	try{
            List<Case> cases = new List<Case>{}; 
        	Database.DMLOptions dmo = new Database.DMLOptions();
/*          List<AssignmentRule> AR = new List<AssignmentRule>{};
            AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];*/
            if(AR.size()>0){
        		for(Case c : [Select Id from Case where Id in :caseIds]){
            		dmo.assignmentRuleHeader.assignmentRuleId = AR[0].Id;
                	dmo.EmailHeader.TriggerUserEmail=True;
            		c.setOptions(dmo);
            		cases.add(c);
       				}
        		Database.upsert(cases);
            }
           	}
         	catch(Exception e){
            	system.debug('The following exception has occured:' +e.getMessage());
            }
        }
	}
}