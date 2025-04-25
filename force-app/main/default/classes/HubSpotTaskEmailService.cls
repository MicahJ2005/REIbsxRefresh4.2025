global class HubSpotTaskEmailService implements Messaging.InboundEmailHandler {
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env){
        String StartSeperator = 'REF: ';
        String EndSeperator = '</LeadId>';
        String leadId;
        List<EmailMessage> interactionHistoriesToinsert = new List<EmailMessage>();
        List<EmailMessageRelation> emrList = new List<EmailMessageRelation>();
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        String emailBody = email.plainTextBody;
        System.debug(emailBody); 
        try {
            Integer StartIndex;
            Integer EndIndex;
            
            if(String.isNotBlank(StartSeperator)){
                StartIndex = emailBody.indexOf(StartSeperator);
                System.debug(StartIndex);
            }
            if(String.isNotBlank(EndSeperator)){
                EndIndex = emailBody.indexOf(EndSeperator);
                System.debug(EndIndex);
            }
            if(StartIndex != Null && StartIndex != -1 && EndIndex != null && EndIndex != -1) {
                //leadId = emailBody.subString(StartIndex + StartSeperator.length(), EndIndex);
            }
            if(StartIndex != Null && StartIndex != -1) {
                leadId = emailBody.subString(StartIndex + StartSeperator.length(), StartIndex + StartSeperator.length() + 18);
                //System.debug(leadId);
            }
            
            if(leadId != null) {
                List<Lead> leadList= [SELECT Id,OwnerId FROM Lead WHERE Id =: leadId];
                if(!leadList.isEmpty()) {
                    interactionHistoriesToinsert.add(new EmailMessage(
                        MessageDate = Datetime.now(),
                        Status = '3',
                        FromAddress = email.fromAddress,
                        FromName = email.fromName,
                        ToAddress = toStringFromList(email.toAddresses),
                        CcAddress = toStringFromList(email.ccAddresses),
                        Subject = email.Subject,
                        HtmlBody = email.HtmlBody
                    ));
                }
                
                if(!interactionHistoriesToinsert.isEmpty()) {
                    insert interactionHistoriesToinsert;
                }
                
                if(!interactionHistoriesToinsert.isEmpty()) {
                    EmailMessageRelation emr = new EmailMessageRelation();
                    emr.emailMessageId = interactionHistoriesToinsert[0].id;
                    emr.RelationId = leadList[0].Id;
                    emr.relationType = 'FromAddress';
                    emr.RelationAddress = email.fromAddress;
                    emrList.add(emr);
                }
                
                if(!emrList.isEmpty()){
                    insert emrList;
                }
                
                Task tskObj = new Task();
                tskObj.OwnerId = leadList[0].OwnerId;
                tskObj.WhoId = leadList[0].Id;
                tskObj.Subject = 'Response to '+email.subject;
                tskObj.Description = 'Response to '+email.subject;
                tskObj.Type = 'Email';
                tskObj.RecordTypeId = '0123A000001SV2S';
                
                insert tskObj;   
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