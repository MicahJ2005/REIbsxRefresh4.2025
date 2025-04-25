public class OppDocForInvestorProspectCtrl {
    
    @AuraEnabled
    public static opportunity  updateFileType(String fileName, String ContentDocumentId, String Field, String OpportunityId){

        opportunity oppRec = new Opportunity();
        oppRec.Id = OpportunityId;
        opprec.put(Field+'__c' , fileName);
        opprec.put(Field+'Id__c' , ContentDocumentId);
        update opprec;
        
        return getOpportunityContractField(OpportunityId);
    }
    
    @AuraEnabled
    public static opportunity getOpportunityContractField(String OpportunityId){
        if(OpportunityId != null){
            Opportunity opprec = [Select Id, Contract_Document_4__c, Contract_Document_5__c, Contract_Document_6__c, Contract_Document_7__c,
                                  Contract_Document_8__c, Contract_Document_9__c,Contract_Document_4Id__c,Contract_Document_5Id__c,Contract_Document_6Id__c,
                                  Contract_Document_7Id__c,Contract_Document_8Id__c,Contract_Document_9Id__c,Street_Address__c,Market__c,Title_Company_Attorney__c,Title_Company_Attorney__r.Id,Title_Company_Attorney__r.Email,
                                  Assessment__r.Name,City__c,State__c,Zip__c,Title_Company_Attorney__r.Name,Title_Company_Days_Allotted__c,Assessment__r.MI_Source__c,
                                  Purchase_Price__c,Additional_Purchase_Costs__c,Closing_Date__c,Earnest_Money__c,Attorney_Title_Company__c,
                                  Seller_Attorney__c,Closing_Concessions_Information__c,Custodian_Contact__r.Email
                                  FROM Opportunity 
                                  WHERE Id =: OpportunityId];
            return opprec;
        }
        return new Opportunity();
    }  
    
    @AuraEnabled
    public static void sendEmailwithAttach(Opportunity oppty){
        oppty = getOpportunityContractField(oppty.Id);
        List<String> sendEmailTo =  new List<String>();
        if(String.isNotBlank(oppty.Custodian_Contact__r.Email)){
            sendEmailTo.add(oppty.Custodian_Contact__r.Email);
        }
        
        Id templateIdtoSend;
        List<Messaging.EmailFileAttachment> fileAttachmentList = new List<Messaging.EmailFileAttachment>();
        
        List<Id> oppDocumentIds = new List<Id>();  
       
        if(String.isNotBlank(oppty.Contract_Document_4Id__c)){
            oppDocumentIds.add(oppty.Contract_Document_4Id__c);
        }
        if(String.isNotBlank(oppty.Contract_Document_5Id__c)){
            oppDocumentIds.add(oppty.Contract_Document_5Id__c);
        }
        if(String.isNotBlank(oppty.Contract_Document_6Id__c)){
            oppDocumentIds.add(oppty.Contract_Document_6Id__c);
        }
        if(String.isNotBlank(oppty.Contract_Document_7Id__c)){
            oppDocumentIds.add(oppty.Contract_Document_7Id__c);
        }
        if(String.isNotBlank(oppty.Contract_Document_8Id__c)){
            oppDocumentIds.add(oppty.Contract_Document_8Id__c);
        }
        if(String.isNotBlank(oppty.Contract_Document_9Id__c)){
            oppDocumentIds.add(oppty.Contract_Document_9Id__c);
        }
        
        
        System.debug('oppDocumentIds :: ' + oppDocumentIds);
        
        for ( ContentVersion cversion : [SELECT title, 
                                         PathOnClient, FileType,
                                         versiondata 
                                         FROM ContentVersion 
                                         WHERE ContentDocumentId IN :oppDocumentIds ]
            ){blob blobBody = cversion.versiondata;
                system.debug('body : '+blobBody+'-----------'+cversion.title);
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName(cversion.title+'.'+cversion.FileType);
                efa.setBody(blobBody);
                fileAttachmentList.add(efa);             }
        
        Folder[] folderIDQuery = [select id from Folder where Name = 'House Buyer Process' AND Type = 'Email'];
        
        EmailTemplate etToSend;
        
        for(EmailTemplate obj : [select Id, Subject, HtmlValue,body, Name,FolderId,TemplateType from EmailTemplate where  FolderId IN:folderIDQuery]){
            if(string.isNotBlank(obj.Name) && String.isNotBlank(oppty.Market__c)){
                if((obj.Name).contains(oppty.Market__c)){
                    etToSend = obj;
                    templateIdtoSend = obj.Id;
                } 
            }
            
        }
        
        //String htmlBody = etToSend.body;
        String htmlBody = 'Test Body';
        /*
        htmlBody = htmlBody.replace('{!Opportunity.Title_Company_Attorney__c}', ((oppty.Title_Company_Attorney__r.Name != null) ? oppty.Title_Company_Attorney__r.Name : ''));
        htmlBody = htmlBody.replace('{!Opportunity.Title_Company_Days_Allotted__c}', ((oppty.Title_Company_Days_Allotted__c != null) ? string.valueOf(oppty.Title_Company_Days_Allotted__c) : ''));
        htmlBody = htmlBody.replace('{!Opportunity.Assessment_MI_Source__c}', ((oppty.Assessment__r.MI_Source__c != null) ? oppty.Assessment__r.MI_Source__c : ''));
        htmlBody = htmlBody.replace('{!Opportunity.Purchase_Price__c}', ((oppty.Purchase_Price__c != null) ? string.valueOf(oppty.Purchase_Price__c) : ''));
        htmlBody = htmlBody.replace('{!Opportunity.Additional_Purchase_Costs__c}', ((oppty.Additional_Purchase_Costs__c != null) ? string.valueOf(oppty.Additional_Purchase_Costs__c) : ''));
        htmlBody = htmlBody.replace('{!Opportunity.Closing_Date__c}', ((oppty.Closing_Date__c != null) ? string.valueOf(oppty.Closing_Date__c) : ''));
        htmlBody = htmlBody.replace('{!Opportunity.Earnest_Money__c}', ((oppty.Earnest_Money__c != null) ? string.valueOf(oppty.Earnest_Money__c) : ''));
        htmlBody = htmlBody.replace('{!Opportunity.Attorney_Title_Company__c}', ((oppty.Attorney_Title_Company__c != null) ? oppty.Attorney_Title_Company__c : ''));
        htmlBody = htmlBody.replace('{!Opportunity.Seller_Attorney__c}', ((oppty.Seller_Attorney__c != null) ? oppty.Seller_Attorney__c : ''));
        htmlBody = htmlBody.replace('{!Opportunity.Closing_Concessions_Text__c}', ((oppty.Closing_Concessions_Text__c != null) ? oppty.Closing_Concessions_Text__c : ''));
        */
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject('Verification Document');
        //email.setSubject(oppty.Assessment__r.Name +' '+ oppty.City__c +', '+ oppty.State__c+' '+ oppty.Zip__c );
        email.setPlainTextBody(htmlBody);
        if(sendEmailTo.size() > 0){
            email.setToAddresses(sendEmailTo);
        }
        email.setWhatId(oppty.Id);
        email.setSaveAsActivity(true);
        //email.setTargetObjectId(oppty.Source_Contact__c);
        if(fileAttachmentList.size() > 0){email.setFileAttachments(fileAttachmentList);
        }
        
            Messaging.SendEmailResult [] emailResult = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});   
        
        List<EmailMessage> activityHistoryList = [SELECT Id FROM EmailMessage ORDER BY CreatedDate DESC LIMIT 1];
        
        List<Attachment> attachmentList = new List<Attachment>();
        for ( ContentVersion cversion : [SELECT title, 
                                         PathOnClient, FileType,
                                         versiondata 
                                         FROM ContentVersion 
                                         WHERE ContentDocumentId IN :oppDocumentIds ]
            ){  Attachment attachmentObj = new Attachment();
                attachmentObj.Body = cversion.versiondata;
                attachmentObj.Name = cversion.Title;
                attachmentObj.ParentId = activityHistoryList[0].Id;
                attachmentList.add(attachmentObj);            }
        insert attachmentList;
    } 

}