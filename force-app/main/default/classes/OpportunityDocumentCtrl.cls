public class OpportunityDocumentCtrl {
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
            Opportunity opprec = [Select Id, Contract_Document_1__c, Contract_Document_2__c, Contract_Document_3__c,Contract_Document_4__c,
                                  Contract_Document_5__c,Contract_Document_6__c,Contract_Document_1Id__c,Contract_Document_2Id__c,Contract_Document_3Id__c,
                                  Contract_Document_4Id__c,Contract_Document_5Id__c,Contract_Document_6Id__c,Market__c,Title_Company_Attorney__c,
                                  Title_Company_Attorney__r.Id,Title_Company_Attorney__r.Email,Title_Company_Attorney__r.AccountId,Street_Address__c,
                                  Assessment__r.Name,City__c,State__c,Zip__c,Title_Company_Attorney__r.Name,Title_Company_Days_Allotted__c,
                                  Assessment__r.MI_Source__c,Purchase_Price__c,Additional_Purchase_Costs__c,Contract_Closing_Date__c,Closing_Date__c,Earnest_Money__c,
                                  Attorney_Title_Company__c,Closing_Concessions__c,Occupancy_At_Closing__c,Owner.Name,Account.Name,Opportunity.Total_Purchase_Cost__c
                                  ,Opportunity.Original_Contract_Date__c,Opportunity.Earnest_Money_Held_At__c,Opportunity.Closing_Concessions_Information__c
                                  FROM Opportunity 
                                  WHERE Id =: OpportunityId];
            return opprec;
        }
        return new Opportunity();
    }  
    
    @AuraEnabled
    public static void sendEmailwithAttach(Opportunity oppty){
        List<Opportunity> oppList = [SELECT Id,OwnerId,Source_Contact__c,Source_Contact__r.Email FROM Opportunity WHERE ID=: oppty.id] ;
        
        oppty = getOpportunityContractField(oppty.Id);
        
        List<String> sendEmailTo =  new List<String>();
        
        List<String> sendEmailCC =  new List<String>();
        for(Buy_Opportunity_CC_Email__mdt ccEmail : [select Label from Buy_Opportunity_CC_Email__mdt]){
            sendEmailCC.add(ccEmail.Label);
        }
        
        if(!oppList.isEmpty() && oppList[0].Source_Contact__r.Email != '' && oppList[0].Source_Contact__r.Email != null){
            sendEmailCC.add(oppList[0].Source_Contact__r.Email);
        }
        if(!oppList.isEmpty() && oppList[0].OwnerId != null){
            String ownerEmail = [SELECT Email FROM User WHERE Id=: oppList[0].OwnerId Limit 1].Email;
            System.debug('ownerEmail'+ownerEmail);
            if(String.isNotBlank(ownerEmail)){
                sendEmailCC.add(ownerEmail);
            }
        }
        
        
        if(String.isNotBlank(oppty.Title_Company_Attorney__r.Email)){
            sendEmailTo.add(oppty.Title_Company_Attorney__r.Email);
        }
        Id templateIdtoSend;
        List<Messaging.EmailFileAttachment> fileAttachmentList = new List<Messaging.EmailFileAttachment>();
        
        List<Id> oppDocumentIds = new List<Id>();    
        if(String.isNotBlank(oppty.Contract_Document_1Id__c)){
            oppDocumentIds.add(oppty.Contract_Document_1Id__c);
        }
        if(String.isNotBlank(oppty.Contract_Document_2Id__c)){
            oppDocumentIds.add(oppty.Contract_Document_2Id__c);
        }
        
        if(String.isNotBlank(oppty.Contract_Document_3Id__c)){
            oppDocumentIds.add(oppty.Contract_Document_3Id__c);
        }
        
        if(String.isNotBlank(oppty.Contract_Document_4Id__c)){
            oppDocumentIds.add(oppty.Contract_Document_4Id__c);
        }
        
        if(String.isNotBlank(oppty.Contract_Document_5Id__c)){
            oppDocumentIds.add(oppty.Contract_Document_5Id__c);
        }
        
        if(String.isNotBlank(oppty.Contract_Document_6Id__c)){
            oppDocumentIds.add(oppty.Contract_Document_6Id__c);
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
        
        String X = etToSend.HtmlValue;
        String htmlBody = X.Substring(0,X.length()-100);
        
        htmlBody = htmlBody.replace('{!Opportunity.Title_Company_Attorney__c}', ((oppty.Title_Company_Attorney__r.Name != null) ? oppty.Title_Company_Attorney__r.Name : ''));
        htmlBody = htmlBody.replace('{!Opportunity.Title_Company_Days_Allotted__c}', ((oppty.Title_Company_Days_Allotted__c != null) ? string.valueOf(oppty.Title_Company_Days_Allotted__c) : ''));
        htmlBody = htmlBody.replace('{!Opportunity.OwnerId}', ((oppty.Owner.Name != null) ? String.valueof(oppty.Owner.Name) : ''));
        htmlBody = htmlBody.replace('{!Opportunity.Total_Purchase_Cost__c}', ((oppty.Total_Purchase_Cost__c != null) ? String.valueof(oppty.Total_Purchase_Cost__c) : ''));
        htmlBody = htmlBody.replace('{!Opportunity.Contract_Closing_Date__c}', ((oppty.Contract_Closing_Date__c != null) ? string.valueOf(oppty.Contract_Closing_Date__c) : ''));
        htmlBody = htmlBody.replace('{!Opportunity.Additional_Purchase_Costs__c}', ((oppty.Additional_Purchase_Costs__c != null) ? string.valueOf(oppty.Additional_Purchase_Costs__c) : ''));
        htmlBody = htmlBody.replace('{!Opportunity.Original_Contract_Date__c}', ((oppty.Original_Contract_Date__c != null) ? string.valueOf(oppty.Original_Contract_Date__c) : ''));
        htmlBody = htmlBody.replace('{!Opportunity.Earnest_Money__c}', ((oppty.Earnest_Money__c != null) ? string.valueOf(oppty.Earnest_Money__c) : ''));
        htmlBody = htmlBody.replace('{!Opportunity.Earnest_Money_Held_At__c}', ((oppty.Earnest_Money_Held_At__c != null) ? string.valueOf(oppty.Earnest_Money_Held_At__c) : ''));
        htmlBody = htmlBody.replace('{!Opportunity.AccountId}', ((oppty.Account.Name != null) ? oppty.Account.Name : ''));
        htmlBody = htmlBody.replace('{!Opportunity.Closing_Concessions_Information__c}', ((oppty.Closing_Concessions_Information__c != null) ? oppty.Closing_Concessions_Information__c : ''));
        htmlBody = htmlBody.replace('{!Opportunity.Occupancy_At_Closing__c}', ((oppty.Occupancy_At_Closing__c!= null) ? oppty.Occupancy_At_Closing__c: ''));
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        email.setSubject(oppty.Assessment__r.Name +' '+ oppty.City__c +', '+ oppty.State__c+' '+ oppty.Zip__c );
        email.setHTMLBody(htmlBody);
        if(sendEmailTo.size() > 0){
            email.setToAddresses(sendEmailTo);
        }
        email.setWhatId(oppty.Id);
        email.setCcAddresses(sendEmailCC);
        email.setSaveAsActivity(true);
        
        if(oppty.Title_Company_Attorney__c != null){
            email.setTargetObjectId(oppty.Title_Company_Attorney__c);
        }
        
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