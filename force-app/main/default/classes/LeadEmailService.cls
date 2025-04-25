global class LeadEmailService implements Messaging.InboundEmailHandler 
{
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email,Messaging.InboundEnvelope env)
    {
        // Create an InboundEmailResult object for returning the result of the Apex Email Service
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        System.debug('Email'+ email);
        System.debug('------= '+email.fromAddress);
        try{
            String relatedToId = '';
            String usrId = '';
            List<EmailMessage> emailMessageList = new List<EmailMessage>();
            List<Task> TaskList = new List<Task>();
            String fromEmail = email.fromAddress;
            if(String.isNotBlank(fromEmail)){
                List<Lead> leadList = [SELECT Id,Email,OwnerId FROM Lead WHERE Email =:fromEmail];
                if(leadList.size() > 0){
                    relatedToId = leadList[0].Id;
                    usrId = leadList[0].OwnerId;
                    List<String> toIds = new List<String>();
                    toIds.add(leadList[0].Id);
                    emailMessageList.add(
                        new EmailMessage (
                            ToIds = toIds,
                            MessageDate = Datetime.now(),
                            Status = '3',
                            FromAddress = email.fromAddress,
                            FromName = email.fromName,
                            //ToAddress = toStringFromList(email.toAddresses),
                            //CcAddress = toStringFromList(email.ccAddresses),
                            Subject = email.Subject,
                            TextBody = email.plainTextBody
                        )
                    );
                     TaskList.add(
                        new Task(
                            Status = 'Not Started',
                            Type = 'Email',
                            Subject = email.Subject,
                            Priority = 'Normal',
                            OwnerId = leadList[0].OwnerId,
                            WhoId = leadList[0].Id
                        )
                    );
                }
            }
            System.debug('emailMessageList'+emailMessageList);
            if(emailMessageList.size() > 0 ){
                Insert emailMessageList;
                if(TaskList.size() > 0){
                    insert TaskList;
                }
                
                // Add Email Message Relation for id of the sender
                EmailMessageRelation emr = new EmailMessageRelation();
                emr.emailMessageId = emailMessageList[0].id;
                emr.relationId = Id.valueof(relatedToId); // user id of the sender
                emr.relationType = 'FromAddress';
                insert emr;
                
                List<EmailMessage> emailMsgList = [SELECT Id, ActivityId FROM EmailMessage WHERE Id =: emailMessageList[0].Id];
                
               
                
            }
        }Catch (Exception e){
            System.debug('Exception : ' + e);
        }
        
        result.success = true;
        return result;
    }
}