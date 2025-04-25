public class VendorPortalProcessProceduresCont {
    public Account acc{get; set;}
    public VendorPortalProcessProceduresCont(){
        List<User> usrList = [SELECT Id, AccountId__c FROM User WHERE Id =: UserInfo.getUserId()];
        acc = new Account();
        if(!usrList.isEmpty()){
            List<Account> accList = [SELECT Id, Type, Market__c FROM Account WHERE Id =: usrList[0].AccountId__c];
            if(!accList.isEmpty()){
                acc = accList[0];
            }
            //acc = [SELECT Id, Type, Market__c FROM Account WHERE Id =: usrList[0].AccountId__c];
        }
    }
}