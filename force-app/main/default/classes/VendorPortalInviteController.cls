/*
    Name             : VendorPortalInviteController
    Author           : Shweta F.
    Date             : 08/14/2019
    Description      : This class is used for Vendor Portal Invite Email Template.
*/
public with sharing class VendorPortalInviteController {

 private ApexPages.StandardSetController standardController;
 
    public VendorPortalInviteController(ApexPages.StandardSetController controller) {
        this.standardController = controller;
    }
    
    public PageReference inviteAccount()
    {       
        // Get the selected records (optional, you can use getSelected to obtain ID's and do your own SOQL)
        List<Account> selectedAccountsList = (List<Account>) standardController.getSelected();
        
        Messaging.SingleEmailMessage email;
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();        
        list<EmailTemplate> emailTemplateList = [select id,name,HtmlValue from EmailTemplate where developername=:'Vendor_Portal_Test_Team_Invite'];
        //String emailBody = emailTemplateList[0].HtmlValue;
        //System.debug('====emailBody====='+emailTemplateList[0].HtmlValue);
        System.debug('========='+selectedAccountsList);
        Map<Id,Contact> accountwithContactMap = new Map<Id,Contact>();
        
        Map<Id,Account> accountMap = new Map<Id,Account>();                
        for(Account acc: [SELECT Id, Primary_Contact_Email__c FROM Account WHERE Id IN: selectedAccountsList AND (RecordType.Name =: Label.accVendorRecType OR RecordType.Name =: Label.AccountVendorFieldServiceRecordType)]) {            
            if(!accountMap.containsKey(acc.id)) {
                accountMap.put(acc.id,acc);
            }              
        }
        
        for(Contact con: [SELECT Id,Name,AccountId,Email,Is_Primary__c FROM Contact WHERE  AccountId IN: accountMap.KeySet() AND Is_Primary__c = true]) { 
        System.debug('========='+con);                   
            if(!accountwithContactMap.containsKey(con.AccountId)) 
                accountwithContactMap.put(con.AccountId,con);     
        }
        
        System.debug('========='+accountwithContactMap);
        // Update records       
        for(id accId: accountwithContactMap.KeySet())
        {      
            if(!accountMap.isEmpty() && accountMap.containsKey(accId) && !accountwithContactMap.isEmpty() && accountwithContactMap.containsKey(accId)) {
                System.debug('=========');
                accountMap.get(accId).Welcome_Message_Sent__c = true;
                List<String> toaddress = new List<String>();
                email = new Messaging.SingleEmailMessage();
                email.setTemplateID(emailTemplateList[0].id);
                
                system.debug(accountwithContactMap.get(accId)) ;
                //system.debug(emailBody) ;               
                //emailBody = emailBody.replace('[PC Name]',accountwithContactMap.get(accId).Name);
                //emailBody = emailBody.replace('{!$Label.VendorCommunityURL}', Label.VendorCommunityURL);
                //email.setHTMLBody(emailBody);

                email.setTargetObjectId(accountwithContactMap.get(accId).Id);
                email.setWhatId(accId);
                //email.setTreatTargetObjectAsRecipient(false);
                email.setSaveAsActivity(false); 
                email.setTreatTargetObjectAsRecipient(false);                        
                //toaddress.add(accountMap.get(accId).Primary_Contact_Email__c);
                toaddress.add(accountwithContactMap.get(accId).Email);
                email.setToAddresses(toaddress);             
                emails.add(email);
            }                     
        } 
        
        try {
            if(!accountMap.isEmpty()) {
                update accountMap.Values();  
            }
            if(emails.size() > 0) {
                Messaging.SendEmail(emails);
            }
        }catch(Exception e) {            
            System.debug('=========='+e.getLineNumber()+'========'+ e.getMessage());
        } 
                 
        return null;        
    }

}