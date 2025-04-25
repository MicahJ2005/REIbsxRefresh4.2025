global class TaskLastCompletedBatch implements Database.Batchable<SObject> {
    
    //Start Method
    global Database.QueryLocator start(Database.BatchableContext info){
        List<User> salesTeam = [SELECT Id FROM User WHERE IsActive = True and UserRole.Name = 'Sales Rep'];
        String sQuery = 'SELECT Id, Subject, CompletedDateTime,Completed_Date__c, Call_Result_New__c, WhatId, OwnerId, Owner.Name, Status FROM Task WHERE RecordType.Name = \'Sales\' AND Status= \'Completed\' AND CompletedDateTime >= 2021-01-01T00:00:00.000+0000 AND WhatId != null AND OwnerId IN :salesTeam';
        return Database.getQueryLocator(sQuery);
    }
    
    //Execute Method
    global void execute(Database.BatchableContext info, List<Task> totalNumTasks){
        List<Account> accToUpdate = new List<Account>();
        System.debug('Beginning'+ totalNumTasks);
        System.debug('Beginning'+ totalNumTasks.size());
        List<Id> accIds = New List <Id>();
        for(Task iter :totalNumTasks){
            if(iter.WhatId != null && String.valueOf(iter.whatId).startsWith('001') && !accIds.contains(Iter.WhatId))
            	accIds.add(iter.WhatId);
        }
        system.debug(accIds);
        
		List<Account> accountsTotal= [SELECT Id, Name, Sales_Last_Activity__c, Sales_Last_Spoke_With_Calls__c FROM Account WHERE Id IN :accIds];
        System.debug('total info' +accountsTotal);
        Map<Id, Account> m = new Map<Id, Account>(accountsTotal);
        System.debug('Accounts'+ m);
        
        for(date d= date.valueOf('2021-01-01') ; d <= system.today(); d=d.addDays(1)){
            System.debug('date is:'+ d);
            for(Task tskIter: totalNumTasks){
                for(Account accIter:accountsTotal){
                    if(tskIter.WhatId == accIter.Id && tskIter.Completed_Date__c == d && tskIter.Call_Result_New__c == 'Connected - Spoke With' ){
                        accIter.Sales_Last_Spoke_With_Calls__c = tskIter.Completed_Date__c;
                        accIter.Sales_Last_Activity__c = tskIter.Completed_Date__c;
                        System.debug('Update' + accIter.Sales_Last_Spoke_With_Calls__c);
                    } else if(tskIter.WhatId == accIter.Id && tskIter.Completed_Date__c == d){
                        accIter.Sales_Last_Activity__c = tskIter.Completed_Date__c;
                        System.debug('Update Last Activity' + accIter.Sales_Last_Activity__c);
                    }
                }
                
            }
        }
        try {
            update accountsTotal;
            System.debug(accountsTotal);        
        } catch(Exception ex) {
           system.debug('======error====='+ex.getMessage()+'======Line No====='+ ex.getLineNumber());
       } 
    }
    
    
    //Finish Method
    global void finish(Database.BatchableContext BC) {
    }

}