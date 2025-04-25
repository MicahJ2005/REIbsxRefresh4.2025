public without sharing class ProcessCommunityPortalUserCtrl {
    
    @AuraEnabled
    public static String processUser(String contactId){
        List<contact> contactRecList = [Select Id,name,email,lastname,accountId,firstname from contact where Id =: contactId];
        if(contactRecList != null && contactRecList.size() > 0){
            User userRec = createUserRec(contactRecList[0]);
            Database.DMLOptions dlo = new Database.DMLOptions();
            dlo.EmailHeader.triggerUserEmail= true;
            try{
                Database.saveresult sr = Database.insert(userRec,dlo);
                if (!sr.isSuccess()) {            
                    for(Database.Error err : sr.getErrors()) {
                        return err.getMessage();
                    }
                }
                else{
                    If(contactRecList[0].accountId != null){
                        updateAccountWelcome(contactRecList[0].accountId);
                        sendEmailAlert(contactRecList[0].Id,contactRecList[0].Name);
                    }
                    return 'User Created';
                    
                }
            } Catch(Exception ex){
                return ex.getMessage();
            }
        }
        
        return '';
    }
    
    @Future
    public static void updateAccountWelcome(Id accId) {
        Account acc = new Account();
        acc.Id = accId;
        acc.Welcome_Message_Sent__c = true;
        acc.Welcome_Message_Sent_Date__c = System.today();
        update acc;
    }
    
    public static user createUserRec(Contact cntRec){
        List<Profile> profileRecList= [Select id,name from Profile where name ='Vendor Community Login' limit 1];
        
        if(profileRecList.size() > 0 && String.isNotBlank(cntRec.email)){
            User userRec = new  User();
            userRec.contactId=cntRec.Id; 
            userRec.username=cntRec.Email;  
            userRec.firstname= String.isNotBlank(cntRec.FirstName) ? cntRec.FirstName: ''  ; 
            userRec.lastname=String.isNotBlank(cntRec.LastName) ? cntRec.LastName: '' ;  
            userRec.email=cntRec.Email; 
            userRec.communityNickname = cntRec.LastName + '_' + String.valueof((Math.random() * 100)); 
            userRec.alias = (String.isNotBlank(cntRec.FirstName) ? string.valueof(cntRec.FirstName.substring(0,1)):'') + cntRec.LastName.substring(0,1);  
            userRec.profileid = profileRecList[0].Id;
            userRec.emailencodingkey='UTF-8'; 
            userRec.languagelocalekey='en_US'; 
            userRec.localesidkey='en_US'; 
            userRec.timezonesidkey='America/Los_Angeles'; 
            return userRec;
        }
        return null;
        
    }
    
    @Future
    public static void sendEmailAlert(String contactId, String contactName){
        
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        List<String> emailList = new List<String>();
        for(Field_Service_Portal_Email__mdt mtd : [SELECT Id,Email__c FROM Field_Service_Portal_Email__mdt])
        {
            emailList.add(mtd.Email__c);
        }
        System.debug('emailList'+emailList);
        if(emailList.size() > 0){
            message.setToAddresses(emailList);
        }
        message.setHtmlBody('<a href="'+'https://ppmg.lightning.force.com' +'/'+contactId+'">'+contactName+'</a>'+' has been invited to the Vendor Portal, please move this Available Submitter to the Allowed Submitters list using below Link :-- '+'<a href="'+'https://ppmg.lightning.force.com' +'/lightning/setup/ApprovalProcesses/page?address=%2Fp%2Fprocess%2FProcessDefinitionWizardStageManager%3Fid%3D04a3A000000PLEO%26jump%3D5%26retURL%3D%252F04a3A000000PLEO'+'">Link</a>');
        message.setSubject('New Portal Invite');
        System.debug('message.toAddresses'+message.toAddresses);
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
        if (results[0].success) 
        {
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send: ' +  results[0].errors[0].message);
        }
    }
}