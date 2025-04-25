/**
Name        : AccountTriggerHandler
Date        : 
Author      : Shweta Fulara(Cmentor)
Description : Handler class for AccountTrigger.
**/
public class AccountTriggerHandler{
    public static Boolean inApproval = false;

    public static void onBeforeInsert(List<Account> accList){
        for(Account acc : accList){
            if(acc.Type != NULL){
                if(acc.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get('Vendor - Pro Serv').getRecordTypeId() && acc.Type.contains('Lender')){
                    acc.Status__c = 'Inactive';
                } 
            }
        } 
    }   
    // 5 Jan 21
    public static void onAfterInsert(List<Account> accList){
        for(Account acc: accList){
            if(acc.Type != NULL && inApproval == false && acc.Approval_Status__c != 'Waiting for approval' && acc.Approval_Status__c != 'Approved'){
                if(acc.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get('Vendor - Pro Serv').getRecordTypeId() && acc.Type.contains('Lender')){
                    System.debug('Account RecordType '+acc.RecordType.Name+'\nAccount Type '+acc.Type);
                    Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
                    approvalRequest.setComments('Account Submitted for approval');
                    approvalRequest.setObjectId(acc.Id);
                    Approval.ProcessResult approvalResult = Approval.process(approvalRequest);
                    System.debug('Account submitted for approval successfully: '+approvalResult .isSuccess());
                    inApproval = true;
                }
            }  
        }
    }
    // 5 Jan 21
    public static void onBeforeUpdate(List<Account> accList, Map<Id, Account> oldMap){
        
        
        for(Account acc: accList){
            /*System.debug('=====1=======');
if(acc.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.AccVendorRecType).getRecordTypeId()){
System.debug('======2======');
onBeforeUpdateEmail(accList,oldMap);
}*/			
            if((acc.Approval_Status__c == 'Approved' || acc.Approval_Status__c == 'Rejected') && 
                     acc.Approval_Status__c != oldMap.get(acc.Id).Approval_Status__c && acc.Is_Uploaded__c)
            {
                acc.addError('You must review all documents and change the status in order to approve/reject the object.');
            }
        }
    }
    
    public static void vendorAccountApprovalRequestEmailAlert(List<Account> accList, Map<Id, Account> oldMap){
        Id vendorRecodType = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.AccVendorRecType).getRecordTypeId();
        Id vendorfieldServiceRecodType =  Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.AccountVendorFieldServiceRecordType).getRecordTypeId();
        Boolean isChange = false;
        List<Vendor_Account_Approver_s_To_Emails__mdt> emailMdt = [SELECT Id,Email__c FROM Vendor_Account_Approver_s_To_Emails__mdt];
        List<EmailTemplate> emailTemplate = [Select Id,Subject,Body,HtmlValue,Markup,TemplateType from EmailTemplate where DeveloperName = 'Vendor_Profile_Update_Approval_Request'];
        OrgWideEmailAddress orgEmail = [select Id, DisplayName, Address from OrgWideEmailAddress where DisplayName = 'PPMG Update'];
        List<User> userList = [SELECT Id FROM User WHERE Name =: 'Michelle Carmichael'];

        for(Account acc1: accList){
            if(acc1.RecordTypeId == vendorRecodType || acc1.RecordTypeId == vendorfieldServiceRecodType){
        
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage accNotificationmail = new Messaging.SingleEmailMessage();  
            
            List<String> vendorEmail = new List<String>();
            for(Vendor_Account_Approver_s_To_Emails__mdt em : emailMdt){
                vendorEmail.add(em.Email__c);
            }
            
            String htmlBody = '';
            if(emailTemplate.size() > 0){
                htmlBody = emailTemplate[0].HtmlValue;
                accNotificationmail.setTemplateId(emailTemplate[0].id);
                accNotificationmail.setSubject(emailTemplate[0].Subject);
                
            }
            accNotificationmail.setToAddresses(vendorEmail);
            accNotificationmail.setOrgWideEmailAddressId(orgEmail.Id);
            
            //Id vendorRecodType = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.AccVendorRecType).getRecordTypeId();
            //Id vendorfieldServiceRecodType =  Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.AccountVendorFieldServiceRecordType).getRecordTypeId();
            //Boolean isChange = false;
            
            for(Account acc : accList){
                if(acc.RecordTypeId == vendorRecodType || acc.RecordTypeId == vendorfieldServiceRecodType && String.isNotBlank(acc.AccountUpdateFromPortal__c)){
                    if(acc.AccountUpdateFromPortal__c == 'YES'){
                        acc.AccountUpdateFromPortal__c = '';
                        // Billing Email
                        if(acc.Billing_Email__c != oldMap.get(acc.id).Billing_Email__c ){
                            isChange = true;
                            if(htmlBody.contains('{!Account.Billing_Email__c}') && String.isNotBlank(acc.Billing_Email__c)){
                                htmlBody = htmlBody.replace('{!Account.Billing_Email__c}', (acc.Billing_Email__c));
                            }else{
                                htmlBody = htmlBody.replace('{!Account.Billing_Email__c}', (''));
                            }
                            
                            if(htmlBody.contains('{!Account.Old_Billing_Email__c}') && oldMap.get(acc.id).Billing_Email__c != null){
                                htmlBody = htmlBody.replace('{!Account.Old_Billing_Email__c}', (oldMap.get(acc.id).Billing_Email__c));
                            }else{
                                htmlBody = htmlBody.replace('{!Account.Old_Billing_Email__c}', (''));
                            }
                            
                        }else{
                            htmlBody = htmlBody.replace('{!Account.Billing_Email__c}', (''));
                            htmlBody = htmlBody.replace('{!Account.Old_Billing_Email__c}', (''));
                        } 
                        
                        // Billing Postal Code
                        if(acc.BillingPostalCode != oldMap.get(acc.id).BillingPostalCode){
                            isChange = true;
                            if(htmlBody.contains('{!Account.BillingPostalCode}') && String.isNotBlank(acc.BillingPostalCode)){
                                htmlBody = htmlBody.replace('{!Account.BillingPostalCode}', (acc.BillingPostalCode));
                            }else{
                                htmlBody = htmlBody.replace('{!Account.BillingPostalCode}', (''));
                            }
                            
                            if(htmlBody.contains('{!Account.Old_Billing_PostalCode__c}') && oldMap.get(acc.id).BillingPostalCode != null){
                                htmlBody = htmlBody.replace('{!Account.Old_Billing_PostalCode__c}', (oldMap.get(acc.id).BillingPostalCode));
                            }else{
                                htmlBody = htmlBody.replace('{!Account.Old_Billing_PostalCode__c}', (''));
                            }
                        }else{
                            htmlBody = htmlBody.replace('{!Account.BillingPostalCode}', (''));
                            htmlBody = htmlBody.replace('{!Account.Old_Billing_PostalCode__c}', (''));
                        }
                        
                        // Billing Street
                        if(acc.BillingStreet != oldMap.get(acc.id).BillingStreet){
                            isChange = true;
                            if(htmlBody.contains('{!Account.BillingStreet}') && String.isNotBlank(acc.BillingStreet)){
                                htmlBody = htmlBody.replace('{!Account.BillingStreet}', (acc.BillingStreet));
                            }else {
                                htmlBody = htmlBody.replace('{!Account.BillingStreet}', (''));
                            }
                            
                            if(htmlBody.contains('{!Account.Old_Billing_Street__c}') && oldMap.get(acc.id).BillingStreet != null){
                                htmlBody = htmlBody.replace('{!Account.Old_Billing_Street__c}', (oldMap.get(acc.id).BillingStreet));
                            }else{
                                htmlBody = htmlBody.replace('{!Account.Old_Billing_Street__c}', (''));
                            }
                            
                        }else{
                            htmlBody = htmlBody.replace('{!Account.BillingStreet}', (''));
                            htmlBody = htmlBody.replace('{!Account.Old_Billing_Street__c}', (''));
                        }
                        
                        // Billing State
                        if(acc.BillingState != oldMap.get(acc.id).BillingState){
                            isChange = true;
                            if(htmlBody.contains('{!Account.BillingState}') && String.isNotBlank(acc.BillingState)){
                                htmlBody = htmlBody.replace('{!Account.BillingState}', (acc.BillingState));
                            }else{
                                htmlBody = htmlBody.replace('{!Account.BillingState}', (''));
                            }
                            if(htmlBody.contains('{!Account.Old_Billing_State__c}') && oldMap.get(acc.id).BillingState != null){
                                htmlBody = htmlBody.replace('{!Account.Old_Billing_State__c}', (oldMap.get(acc.id).BillingState));
                            }else{
                                htmlBody = htmlBody.replace('{!Account.Old_Billing_State__c}', (''));
                            }
                        }else{
                            htmlBody = htmlBody.replace('{!Account.BillingState}', (''));
                            htmlBody = htmlBody.replace('{!Account.Old_Billing_State__c}', (''));
                        }
                        
                        // Billing City
                        if(acc.BillingCity != oldMap.get(acc.id).BillingCity){
                            isChange = true;
                            if(htmlBody.contains('{!Account.BillingCity}') && String.isNotBlank(acc.BillingCity))
                            {
                                htmlBody = htmlBody.replace('{!Account.BillingCity}', (acc.BillingCity));
                            }else
                            {
                                htmlBody = htmlBody.replace('{!Account.BillingCity}', (''));
                            }
                            if(htmlBody.contains('{!Account.Old_Billing_City__c}') && oldMap.get(acc.id).BillingCity != null){
                                htmlBody = htmlBody.replace('{!Account.Old_Billing_City__c}', (oldMap.get(acc.id).BillingCity));
                            }else{
                                htmlBody = htmlBody.replace('{!Account.Old_Billing_City__c}', (''));
                            }
                        }else{
                            htmlBody = htmlBody.replace('{!Account.BillingCity}', (''));
                            htmlBody = htmlBody.replace('{!Account.Old_Billing_City__c}', (''));
                        }
                        
                        // Maintenance Categories
                        if(acc.Maint_Category_1__c != oldMap.get(acc.id).Maint_Category_1__c)
                        {
                            isChange = true;
                            if(htmlBody.contains('{!Account.Maint_Category_1__c}') && String.isNotBlank(acc.Maint_Category_1__c))
                            {
                                htmlBody = htmlBody.replace('{!Account.Maint_Category_1__c}', (acc.Maint_Category_1__c));
                            }else
                            {
                                htmlBody = htmlBody.replace('{!Account.Maint_Category_1__c}', (''));
                            }
                            if(htmlBody.contains('{!Account.Old_Maint_Category_1__c}') && oldMap.get(acc.id).Maint_Category_1__c != null){
                                htmlBody = htmlBody.replace('{!Account.Old_Maint_Category_1__c}', (oldMap.get(acc.id).Maint_Category_1__c));
                            }else{
                                htmlBody = htmlBody.replace('{!Account.Old_Maint_Category_1__c}', (''));
                            }
                        }
                        else
                        {
                            htmlBody = htmlBody.replace('{!Account.Maint_Category_1__c}', (''));
                            htmlBody = htmlBody.replace('{!Account.Old_Maint_Category_1__c}', (''));
                        }
                        
                        // Rehab Categories
                        if(acc.Category_1__c != oldMap.get(acc.id).Category_1__c){
                            isChange = true;
                            if(htmlBody.contains('{!Account.Category_1__c}') && String.isNotBlank(acc.Category_1__c))
                            {
                                htmlBody = htmlBody.replace('{!Account.Category_1__c}', (acc.Category_1__c));
                            }else
                            {
                                htmlBody = htmlBody.replace('{!Account.Category_1__c}', (''));
                            }
                            if(htmlBody.contains('{!Account.Old_Category_1__c}') && oldMap.get(acc.id).Category_1__c != null){
                                htmlBody = htmlBody.replace('{!Account.Old_Category_1__c}', (oldMap.get(acc.id).Category_1__c));
                            }else{
                                htmlBody = htmlBody.replace('{!Account.Old_Category_1__c}', (''));
                            }
                        }else{
                            htmlBody = htmlBody.replace('{!Account.Category_1__c}', (''));
                            htmlBody = htmlBody.replace('{!Account.Old_Category_1__c}', (''));
                        }
                        
                        // Market
                        if(acc.Market__c != oldMap.get(acc.id).Market__c){
                            isChange = true;
                            if(htmlBody.contains('{!Account.Market__c}') && String.isNotBlank(acc.Market__c))
                            {
                                htmlBody = htmlBody.replace('{!Account.Market__c}', (acc.Market__c));
                            }else
                            {
                                htmlBody = htmlBody.replace('{!Account.Market__c}', (''));
                            }
                            if(htmlBody.contains('{!Account.Old_Market__c}') && oldMap.get(acc.id).Market__c != null){
                                htmlBody = htmlBody.replace('{!Account.Old_Market__c}', (oldMap.get(acc.id).Market__c));
                            }else{
                                htmlBody = htmlBody.replace('{!Account.Old_Market__c}', (''));
                            }
                        }else{
                            htmlBody = htmlBody.replace('{!Account.Market__c}', (''));
                            htmlBody = htmlBody.replace('{!Account.Old_Market__c}', (''));
                        }
                        
                        // Bank Name
                        if(acc.Bank_Name__c != oldMap.get(acc.id).Bank_Name__c){
                            isChange = true;
                            if(htmlBody.contains('{!Account.Bank_Name__c}') && String.isNotBlank(acc.Bank_Name__c))
                            {
                                htmlBody = htmlBody.replace('{!Account.Bank_Name__c}', (acc.Bank_Name__c));
                            }else
                            {
                                htmlBody = htmlBody.replace('{!Account.Bank_Name__c}', (''));
                            }
                            if(htmlBody.contains('{!Account.Old_Bank_Name__c}') && oldMap.get(acc.id).Bank_Name__c != null){
                                htmlBody = htmlBody.replace('{!Account.Old_Bank_Name__c}', (oldMap.get(acc.id).Bank_Name__c));
                            }else{
                                htmlBody = htmlBody.replace('{!Account.Old_Bank_Name__c}', (''));
                            }
                        }else{
                            htmlBody = htmlBody.replace('{!Account.Bank_Name__c}', (''));
                            htmlBody = htmlBody.replace('{!Account.Old_Bank_Name__c}', (''));
                        }
                        
                        // Routing Number
                        if(acc.Routing_Number__c != oldMap.get(acc.id).Routing_Number__c){
                            isChange = true;
                            if(htmlBody.contains('{!Account.Routing_Number__c}') && String.isNotBlank(acc.Routing_Number__c))
                            {
                                htmlBody = htmlBody.replace('{!Account.Routing_Number__c}', (acc.Routing_Number__c));
                            }else
                            {
                                htmlBody = htmlBody.replace('{!Account.Routing_Number__c}', (''));
                            }
                            if(htmlBody.contains('{!Account.Old_Routing_Number__c}') && oldMap.get(acc.id).Routing_Number__c != null){
                                htmlBody = htmlBody.replace('{!Account.Old_Routing_Number__c}', (oldMap.get(acc.id).Routing_Number__c));
                            }else{
                                htmlBody = htmlBody.replace('{!Account.Old_Routing_Number__c}', (''));
                            }
                        }else{
                            htmlBody = htmlBody.replace('{!Account.Routing_Number__c}', (''));
                            htmlBody = htmlBody.replace('{!Account.Old_Routing_Number__c}', (''));
                        }
                        
                        // Account Number
                        if(acc.Account_Number__c != oldMap.get(acc.id).Account_Number__c){
                            isChange = true;
                            if(htmlBody.contains('{!Account.Account_Number__c}') && String.isNotBlank(acc.Account_Number__c))
                            {
                                htmlBody = htmlBody.replace('{!Account.Account_Number__c}', (acc.Account_Number__c));
                            }else
                            {
                                htmlBody = htmlBody.replace('{!Account.Account_Number__c}', (''));
                            }
                            if(htmlBody.contains('{!Account.Old_AccountNumber__c}') && oldMap.get(acc.id).Account_Number__c != null){
                                htmlBody = htmlBody.replace('{!Account.Old_AccountNumber__c}', (oldMap.get(acc.id).Account_Number__c));
                            }else{
                                htmlBody = htmlBody.replace('{!Account.Old_AccountNumber__c}', (''));
                            }
                        }else{
                            htmlBody = htmlBody.replace('{!Account.Account_Number__c}', (''));
                            htmlBody = htmlBody.replace('{!Account.Old_AccountNumber__c}', (''));
                        }
                        
                        // Account Type
                        if(acc.Account_Type__c != oldMap.get(acc.id).Account_Type__c){
                            isChange = true;
                            if(htmlBody.contains('{!Account.Account_Type__c}') && String.isNotBlank(acc.Account_Type__c))
                            {
                                htmlBody = htmlBody.replace('{!Account.Account_Type__c}', (acc.Account_Type__c));
                            }else
                            {
                                htmlBody = htmlBody.replace('{!Account.Account_Type__c}', (''));
                            }
                            if(htmlBody.contains('{!Account.Old_Account_Type__c}') && oldMap.get(acc.id).Account_Type__c != null){
                                htmlBody = htmlBody.replace('{!Account.Old_Account_Type__c}', (oldMap.get(acc.id).Account_Type__c));
                            }else{
                                htmlBody = htmlBody.replace('{!Account.Old_Account_Type__c}', (''));
                            }
                        }else{
                            htmlBody = htmlBody.replace('{!Account.Account_Type__c}', (''));
                            htmlBody = htmlBody.replace('{!Account.Old_Account_Type__c}', (''));
                        }
                        
                        
                        // 	License #
                        if(acc.License__c != oldMap.get(acc.id).License__c){
                            isChange = true;
                            if(htmlBody.contains('{!Account.License__c}') && String.isNotBlank(acc.License__c))
                            {
                                htmlBody = htmlBody.replace('{!Account.License__c}', (acc.License__c));
                            }else
                            {
                                htmlBody = htmlBody.replace('{!Account.License__c}', (''));
                            }
                            if(htmlBody.contains('{!Account.Old_License__c}') && oldMap.get(acc.id).License__c != null){
                                htmlBody = htmlBody.replace('{!Account.Old_License__c}', (oldMap.get(acc.id).License__c));
                            }else{
                                htmlBody = htmlBody.replace('{!Account.Old_License__c}', (''));
                            }
                        }else{
                            htmlBody = htmlBody.replace('{!Account.License__c}', (''));
                            htmlBody = htmlBody.replace('{!Account.Old_License__c}', (''));
                        }
                        htmlBody = htmlBody.replace('{!Account.Name}', (acc.Name));
                        htmlBody = htmlBody.replace('{!Account.Id}', (acc.id));
                        if(isChange){
                            //accNotificationmail.setTargetObjectId(userList[0].id);                
                            accNotificationmail.setSaveAsActivity(false);
                            accNotificationmail.setHtmlBody(htmlBody);
                            mails.add(accNotificationmail);
                        }
                    }
                }
            }
            if(mails.size() > 0){
                Messaging.sendEmail(mails);
                }
                }
        }
    }
    
    public static void onAfterUpdate(List<Account> accList, Map<Id, Account> oldMap){
        List<Opportunity> oppList = [SELECT Id, Name, AccountId, House_Number__c, Project__c, Project__r.House__c, Project__r.House__r.Investor__c, Project__r.House__r.Status__c 
                                     FROM Opportunity WHERE AccountId IN:accList];
        List<House__c> houseList = new List<House__c>();
        Map<String, Opportunity> oppMap = new Map<String, Opportunity>();
        String idHouse = '';
        for(Opportunity opp : oppList){
            idHouse = opp.AccountId + String.valueOf(opp.House_Number__c);
            System.debug('Id  '+idHouse);
            oppMap.put(idHouse, opp);
        }
        //setAccountFields(accList, oldMap);
        Set<Id> accIds = new Set<Id>();
        
        Set<String> fieldsSet = new Set<String>{'Type','BillingCity','BillingState','BillingStreet','BillingPostalCode','Billing_Email__c',
            'Bank_Name__c','Account_Type__c','Routing_Number__c','Account_Number__c','DL_Exp_Date__c',
            'Liab_Exp_Date__c','Wk_Comp_Exp_Date__c','Market__c','Category_1__c','Maint_Category_1__c',
            'License__c'};
                
                Set<String> fieldsObtained = new Set<String>();
        
        List<Account> accListToUpdate = new List<Account>();
        for(Account acc: [SELECT Id, Approval_Status__c, Market__c, Temp_Market__c, Rehab_Contractor_Trade_s__c , Category_1__c, 
                          Maint_Category_1__c, Property_Maintenance_Trade_s__c, RecordType.Name, RecordTypeId, Properties_Closed__c,
                          (SELECT Field, CreatedDate, OldValue, NewValue FROM Histories WHERE Field IN: fieldsSet ORDER BY CreatedDate DESC) 
                          FROM Account WHERE Id IN: accList 
                          AND
                          (RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.AccVendorRecType).getRecordTypeId()
                           OR
                           RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.AccountVendorFieldServiceRecordType).getRecordTypeId()
                           OR
                           RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByName().get('Investor Owner').getRecordTypeId()
                           OR
                           RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByName().get('Investor Prospect').getRecordTypeId()
                          )
                         ]
           ){
               if(acc.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.AccVendorRecType).getRecordTypeId() ||
                  acc.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.AccountVendorFieldServiceRecordType).getRecordTypeId()){
                      if(acc.Approval_Status__c == 'Rejected' && acc.Approval_Status__c != oldMap.get(acc.Id).Approval_Status__c){
                          
                          for(AccountHistory accHis: acc.Histories){
                              if(!fieldsObtained.contains(accHis.Field)){if(accHis.Field == 'Market__c'){acc.put(accHis.Field, acc.Temp_Market__c);}else if(accHis.Field == 'Category_1__c'){acc.put(accHis.Field, acc.Rehab_Contractor_Trade_s__c);}else if(accHis.Field == 'Maint_Category_1__c'){acc.put(accHis.Field, acc.Property_Maintenance_Trade_s__c);}else{acc.put(accHis.Field, accHis.OldValue);}
                                                                         fieldsObtained.add(accHis.Field);
                                                                        }
                              else{break;}
                          }
                          accListToUpdate.add(acc);
                      }
                  }
               
               System.debug('Inside '+acc.RecordType.Name+' '+acc.RecordTypeId);
               if(acc.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get('Investor Owner').getRecordTypeId() ||
                  acc.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get('Investor Prospect').getRecordTypeId()){
                      if(acc.Properties_Closed__c != oldMap.get(acc.Id).Properties_Closed__c && acc.Properties_Closed__c != 0){
                          Account accRec = new Account();
                          accRec.Id = acc.Id;
                          accRec.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Investor Owner').getRecordTypeId();
                          accListToUpdate.add(accRec);
                          String str = acc.Id + String.valueOf(acc.Properties_Closed__c);
                          if(oppMap.containsKey(str)){
                              System.debug('Inside Map');
                              System.debug('str   '+str);
                              System.debug('Project '+oppMap.get(str).Project__c+'\n House '+oppMap.get(str).Project__r.House__c);
                              if(oppMap.get(str).Project__c != NULL){
                                  if(oppMap.get(str).Project__r.House__c != NULL){
                                      House__c house = new House__c();
                                      house.Id = oppMap.get(str).Project__r.House__c;
                                      house.Investor__c = acc.Id;
                                      house.Status__c = 'Managed';
                                      houseList.add(house);
                                  }
                              }
                          }                              
                      }
                  }
           }
        if(!houseList.isEmpty()){
            update houseList;
        }
        
        if(!accListToUpdate.isEmpty()){
            update accListToUpdate;
        }
        
        
        /*
System.debug('accList-----'+accList);
for(Account acc: accList){
if(acc.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.AccVendorRecType).getRecordTypeId()){
if(acc.Approval_Status__c == 'Approved' && acc.Approval_Status__c != oldMap.get(acc.Id).Approval_Status__c){
acc.Market__c = acc.Temp_Market__c;
acc.Category_1__c = acc.Rehab_Contractor_Trade_s__c;
acc.Maint_Category_1__c = acc.Property_Maintenance_Trade_s__c;
}
if(acc.Approval_Status__c == 'Rejected' && acc.Approval_Status__c != oldMap.get(acc.Id).Approval_Status__c){
acc.Temp_Market__c = acc.Market__c;
acc.Rehab_Contractor_Trade_s__c = acc.Category_1__c;
acc.Property_Maintenance_Trade_s__c = acc.Maint_Category_1__c;
}
}
}
*/
    }
    
    public static void onAfterUpdateAppStatus(List<Account> accList, Map<Id, Account> accountMap){
        
        Id RecordTypeIdAcc = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Vendor').getRecordTypeId();
        Id RecordTypeIdVendorFieldServiceAcc = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Vendor - Field Service').getRecordTypeId();
        
        List<Id> accountIdList = new List<Id>();
        for(Account accObj : accList){
            if(!accObj.Email_for_New_Vendor_Approved_should_be__c && accountMap.get(accObj.Id).Approval_Status__c != 'Approved' && accObj.Approval_Status__c == 'Approved' && (accObj.RecordTypeId == RecordTypeIdAcc || accObj.RecordTypeId == RecordTypeIdVendorFieldServiceAcc)){
                //   accObj.Email_for_New_Vendor_Approved_should_be__c = True;
                accountIdList.add(accObj.Id);
            }
        }
        
        if(!System.isFuture() && !System.isBatch())
            onAfterUpdateAppStatus(accountIdList);  
    }
    
    @future
    public static void onAfterUpdateAppStatus(List<Id> accUpdatedId){
        
        Id RecordTypeIdAcc = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Vendor').getRecordTypeId();
        
        List<Account> accList = [SELECT Id,Approval_Status__c FROM Account WHERE Id IN: accUpdatedId];
        
        for(Account accObj : accList){
            accObj.Email_for_New_Vendor_Approved_should_be__c = True;
        }
        update accList;   
        
    } 
    
    
    /*
//Method used to set Accounting fields for User who don't have AcctSeed access
public static void setAccountFields(List<Account> accList, Map<Id, Account> oldMap){
for(Account acc: accList){
if(String.isNotBlank(acc.SSN__c) && acc.SSN__c != oldMap.get(acc.Id).SSN__c){
acc.AcctSeed__Taxpayer_Identification_Number__c = acc.SSN__c;
}
}
}

//Method used to set Accounting Type and Accounting Active to true.
public static void setAccountingValues(List<Account> accList){
Id ownerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Owner').getRecordTypeId();
Id vendorRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Vendor').getRecordTypeId();

for(Account acc: accList){
if(acc.RecordTypeId == ownerRecordTypeId){
acc.AcctSeed__Accounting_Active__c = true;
acc.AcctSeed__Accounting_Type__c = 'Customer and Vendor';
}
if(acc.RecordTypeId == vendorRecordTypeId){
acc.AcctSeed__Accounting_Active__c = true;
acc.AcctSeed__Accounting_Type__c = 'Vendor';
}
}
}
*/
    
    /*
public static void onAfterInsert(List<Account> accList){
createGL_Variable2(accList);
}


public static void createGL_Variable2(List<Account> accList){
List<AcctSeed__Accounting_Variable__c> variable2List = new List<AcctSeed__Accounting_Variable__c>();

Map<Id, AcctSeed__Accounting_Variable__c> variable2Map = new Map<Id, AcctSeed__Accounting_Variable__c>();

Id ownerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Owner').getRecordTypeId();

for(Account acc: accList){
if(acc.RecordTypeId == ownerRecordTypeId){
AcctSeed__Accounting_Variable__c variable2 = new AcctSeed__Accounting_Variable__c(
Name=acc.Name, AcctSeed__Active__c= true, AcctSeed__Type__c='GL Account Variable 2'
);
variable2Map.put(acc.Id, variable2); 
}
}

//Commented before sending for Vendor changes
if(!variable2Map.isEmpty()){
insert variable2Map.values();

List<Account> accListToUpdate = new List<Account>();

for(Id accId: variable2Map.keySet()){
Account acc = new Account(Id=accId, AcctSeed__GL_Account_Variable_2__c=variable2Map.get(accId).Id);
accListToUpdate.add(acc);
}

if(!accListToUpdate.isEmpty()){
update accListToUpdate;
}
}
} 
*/
    
    
}