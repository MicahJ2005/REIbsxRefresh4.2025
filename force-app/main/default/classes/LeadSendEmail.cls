global class LeadSendEmail implements Messaging.InboundEmailHandler {
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env){
        String StartSeperator = 'REF: ';
        String EndSeperator = '</LeadId>';
        String recId;
        List<EmailMessage> interactionHistoriesToinsert = new List<EmailMessage>();
        List<EmailMessageRelation> emrList = new List<EmailMessageRelation>();
        
        List<Messaging.Inboundemail.BinaryAttachment> binAttachList = new List<Messaging.Inboundemail.BinaryAttachment>();
        List<Messaging.InboundEmail.TextAttachment> textAttachList = new List<Messaging.InboundEmail.TextAttachment>();
        
        binAttachList = email.binaryAttachments;
        textAttachList = email.textAttachments;       
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        String emailBody = email.plainTextBody;
        String subject = email.subject;
        System.debug('binary attachment '+email.binaryAttachments);
        System.debug('text attachment '+email.textAttachments);
        System.debug(emailBody);
        System.debug(subject);
        try {
            Integer StartIndex;
            Integer EndIndex;
            
            if(String.isNotBlank(StartSeperator)){
                StartIndex = subject.indexOf(StartSeperator);
                System.debug(StartIndex);
            }
            if(String.isNotBlank(EndSeperator)){
                EndIndex = subject.indexOf(EndSeperator);
                System.debug(EndIndex);
            }
            if(StartIndex != Null && StartIndex != -1 && EndIndex != null && EndIndex != -1) {
            }
            if(StartIndex != Null && StartIndex != -1) {
                recId = subject.subString(StartIndex + StartSeperator.length(), StartIndex + StartSeperator.length() + 18);
            }
			System.debug('Recor Id '+recId);
            if(binAttachList != NULL){
                List<Attachment> attachList = new List<Attachment>();
                for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
                    
                    Attachment attachment = new Attachment();
                    // attach to the newly created contact record
                    attachment.ParentId = recId;
                    attachment.Name = bAttachment.filename;
                    attachment.Body = bAttachment.body;
                    attachList.add(attachment);
                }
                insert attachList;
            }
            if(textAttachList != NULL){
                List<Attachment> attachListText = new List<Attachment>();
                for (Messaging.InboundEmail.TextAttachment tAttachment : email.textAttachments) {
                    
                    Attachment attachment = new Attachment();
                    // attach to the newly created contact record
                    attachment.ParentId = recId;
                    attachment.Name = tAttachment.filename;
                    attachment.Body = Blob.valueOf(tAttachment.body);
                    attachListText.add(attachment);
                }
                insert attachListText;  
            }
            //change end
            if(recId != null) {
                List<Lead> recList= [SELECT Id, OwnerId, Owner.Email FROM Lead WHERE Id =: recId];
                List<User> usrList = [SELECT Id, Email, Name FROM User Where Id =: recList[0].OwnerId];
                System.debug('List '+recList);
                System.debug('User '+usrList);
                System.debug(recList[0].OwnerId);
                List<String> toIds = new List<String>();
                toIds.add(recId);
                String usrEmail = UserInfo.getUserEmail();
                String usrName = UserInfo.getName();
                System.debug('User Email '+usrEmail);
                System.debug('User Name '+usrName);
                System.debug('Email '+email.fromName);
                if(!recList.isEmpty()) {
                    interactionHistoriesToinsert.add(new EmailMessage(
                        MessageDate = Datetime.now(),
                        Status = '3',
                        ToIds = toIds,
                        FromAddress = recList[0].Owner.Email,//email.fromAddress,
                        FromName = email.fromName,
                        ToAddress = toStringFromList(email.toAddresses),
                        CcAddress = toStringFromList(email.ccAddresses),
                        Subject = email.Subject,
                        HtmlBody = email.HtmlBody
                    ));
                }
                
                if(!interactionHistoriesToinsert.isEmpty()) {
                    insert interactionHistoriesToinsert;
                    EmailMessage m = new EmailMessage();  
                }
                // new change 2
                if(binAttachList != NULL){
                    List<Attachment> attachList2 = new List<Attachment>();
                    for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
                        
                        Attachment attachment = new Attachment();
                        // attach to the newly created contact record
                        attachment.ParentId = interactionHistoriesToinsert[0].Id;
                        attachment.Name = bAttachment.filename;
                        attachment.Body = bAttachment.body;
                        attachList2.add(attachment);
                    }
                    insert attachList2; 
                }
                
                if(textAttachList != NULL){
                    List<Attachment> attachListText2 = new List<Attachment>();
                    for (Messaging.InboundEmail.TextAttachment tAttachment : email.textAttachments) {
                        
                        Attachment attachment = new Attachment();
                        // attach to the newly created contact record
                        attachment.ParentId = interactionHistoriesToinsert[0].Id;
                        attachment.Name = tAttachment.filename;
                        attachment.Body = Blob.valueOf(tAttachment.body);
                        attachListText2.add(attachment);
                    }
                    insert attachListText2;
                }
                
                //change end
                
                if(!interactionHistoriesToinsert.isEmpty()) {
                    EmailMessageRelation emr = new EmailMessageRelation();
                    emr.emailMessageId = interactionHistoriesToinsert[0].id;
                    emr.RelationId = recList[0].Id;
                    emr.relationType = 'FromAddress';
                    emr.RelationAddress = recList[0].Owner.Email;//email.fromAddress;
                    emrList.add(emr);
                }

                
                
                if(!emrList.isEmpty()){
                    insert emrList;
                }
                
                Task tskObj = new Task();
                tskObj.OwnerId = recList[0].OwnerId;
                tskObj.WhoId = recList[0].Id;
                tskObj.Subject = 'Response to '+email.subject;
                tskObj.Description = 'Response to '+email.subject;
                tskObj.Type = 'Email';
                tskObj.ActivityDate = System.today();
                tskObj.RecordTypeId = '0123A000001SV2S'; // record type
                insert tskObj;
                System.debug('Task Id '+tskObj.Id);
                // new change 3
                if(binAttachList != NULL){
                    List<Attachment> attachList3 = new List<Attachment>();
                    for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
                        
                        Attachment attachment = new Attachment();
                        // attach to the newly created contact record
                        attachment.ParentId = tskObj.Id;
                        attachment.OwnerId = recList[0].OwnerId;
                        attachment.Name = bAttachment.filename;
                        attachment.Body = bAttachment.body;
                        attachList3.add(attachment);
                    }
                    insert attachList3;
                }
                
                if(textAttachList != NULL){
                    List<Attachment> attachListText3 = new List<Attachment>();
                    for (Messaging.InboundEmail.TextAttachment tAttachment : email.textAttachments) {
                        
                        Attachment attachment = new Attachment();
                        // attach to the newly created contact record
                        attachment.ParentId = tskObj.Id;
                        attachment.OwnerId = recList[0].OwnerId;
                        attachment.Name = tAttachment.filename;
                        attachment.Body = Blob.valueOf(tAttachment.body);
                        attachListText3.add(attachment);
                    }
                    insert attachListText3; 
                }
                
                //change end
            }     
        }
        catch (QueryException e) {
            System.debug('Query Issue: ' + e);
        }
        
        result.success = true;
        return result;
    }
    
    private static String toStringFromList(List<String> arr) {
        String arrString = '';
        If(arr != null && arr.size() > 0){
            for(String elem : arr) {
                arrString += elem + ';';
            }
            arrString = arrString.subString(0, arrString.length()-1);
        }
        return arrString;
    }
}