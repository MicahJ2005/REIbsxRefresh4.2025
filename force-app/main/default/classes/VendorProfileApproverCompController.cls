public class VendorProfileApproverCompController {
    
    public Id recordId{get; set;} 
    public Account acc{get; set;} 
    public Boolean isPrimary{get; set;} 
    
    public VendorProfileApproverCompController(){
        acc = new Account();
    }   

    public List<AccountHistory> getAccHistory(){
        List<Account> accList = [SELECT Id, Name, Market__c, Temp_Market__c, Maint_Category_1__c, Property_Maintenance_Trade_s__c, 
                Category_1__c, Rehab_Contractor_Trade_s__c, Primary_Contact_Email__c  
                FROM Account WHERE Id =: recordId];
        if(!accList.isEmpty()) acc = accList[0];
        
        Set<String> fieldsSet = new Set<String>{'Type','BillingCity','BillingState','BillingStreet','BillingPostalCode','Billing_Email__c',
                                                    'Bank_Name__c','Account_Type__c','Routing_Number__c','Account_Number__c','DL_Exp_Date__c',
                                                        'Liab_Exp_Date__c','Wk_Comp_Exp_Date__c','Market__c','Category_1__c','Maint_Category_1__c', 'License__c', 'unlocked'};
        List<AccountHistory> accountsWithHistories = new List<AccountHistory>();
        Map<String, AccountHistory> accHistoryMap = new Map<String, AccountHistory>();
        DateTime createDt;
        Integer i = 0;
        
        for(AccountHistory accHis: [SELECT CreatedDate, OldValue, NewValue, Field FROM AccountHistory WHERE AccountId =: recordId AND Field IN: fieldsSet ORDER BY CreatedDate DESC]){
            System.debug('accHis.Field-----'+accHis.Field);
            if(!accHistoryMap.containsKey(accHis.Field) && accHis.Field != 'unlocked'){accHistoryMap.put(accHis.Field, accHis);accountsWithHistories.add(accHis);}
            else{break;}
        }
        
        return accountsWithHistories;
    }
}