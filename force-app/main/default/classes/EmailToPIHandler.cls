global class EmailToPIHandler  implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
           
        if(email.htmlbody != NULL && email.htmlbody.contains('ref:')){
            String recordId = email.htmlbody.substringAfter('ref: ');
            recordId = recordId.substringBefore(']');
            String fromAddress = email.fromAddress;
            String userId = '';
            if(email.htmlbody.contains('userRef:')){
                userId = email.htmlbody.substringAfter('userRef: ');
                userId = userId.substringBefore(']');
            }
            
            messaging.InboundEmailresult result = new messaging.InboundEmailresult();
            System.debug('userId----'+userId);
            
            List<User> usrList = [SELECT Id FROM User WHERE Id=: userId];
            
            string des = email.plaintextbody;
            string tasksubject = email.subject;
            /*
            List<Task> taskList = new List<Task>();
            
            Task tsk = new Task(Description = des, subject = tasksubject, Priority = 'Medium', 
                            ActivityDate = System.today(), ReminderDateTime = System.now(), 
                            WhatId = recordId);
            if(!usrList.isEmpty()){
                tsk.OwnerId = usrList[0].Id;
            }
            
            taskList.add(tsk);
            insert taskList;
            */
            
            String toAdr = '';
            String ccAdr = '';
            if(email.toAddresses != null && !email.toAddresses.isEmpty()){
                for(String adr: email.toAddresses){
                    if(String.isBlank(toAdr)){
                        toAdr = adr;
                    }
                    else{
                         toAdr = '; '+adr;
                    }
                }
            }
            
            if(email.ccAddresses != null && !email.ccAddresses.isEmpty()){
                for(String adr: email.ccAddresses){
                    if(String.isBlank(ccAdr)){
                        ccAdr = adr;
                    }
                    else{
                         ccAdr = '; '+adr;
                    }
                }
            }
            
            String htmlBody = email.htmlBody.abbreviate(31900);
            if(!htmlBody.contains('ref')){
                htmlBody += '<p style="color:white"> [ref: '+ recordId +'] [userRef: '+ userId +']</p>';
            }
            
            String plainBody = email.plainTextBody.abbreviate(31900);
            if(!plainBody.contains('ref')){
                plainBody += '<p style="color:white"> [ref: '+ recordId +'] [userRef: '+ userId+']</p>';
            }
            
            EmailMessage emailMessage = new EmailMessage(FromAddress = email.fromAddress,
            FromName = email.fromName,
            Incoming = true,
            IsTracked = true,
            ToAddress = toAdr,
            CcAddress = ccAdr,
            Subject = email.subject,
            TextBody = plainBody,
            HtmlBody = htmlBody,
            Status = '3',
            RelatedToId = recordId); 
            insert emailMessage;
            
            List<EmailMessageRelation> emrList = new List<EmailMessageRelation>();
            if(!usrList.isEmpty()){
                // Add Email Message Relation for id of the sender
                EmailMessageRelation emr = new EmailMessageRelation();
                emr.emailMessageId = emailMessage.id;
                emr.RelationId = usrList[0].Id; // user id of the sender
                emr.relationType = 'ToAddress';
                emrList.add(emr);
            }
            if(String.isNotBlank(email.fromAddress)){
                List<Contact> conList = [SELECT Id FROM Contact WHERE Email =: fromAddress AND RecordType.Name = 'Investor'];
                // Add Email Message Relation for id of the sender
                EmailMessageRelation emr = new EmailMessageRelation();
                emr.emailMessageId = emailMessage.id;
                emr.relationType = 'FromAddress';
                if(!conList.isEmpty()){
                    emr.RelationId = conList[0].Id; // contact id of the sender
                }
                else{
                    emr.RelationAddress = email.fromAddress;
                }   
                emrList.add(emr);
            }
            if(email.ccAddresses != null){
                for(String ccAddr: email.ccAddresses){
                    // Add Email Message Relation for id of the sender
                    EmailMessageRelation emr = new EmailMessageRelation();
                    emr.emailMessageId = emailMessage.id;
                    emr.RelationAddress = ccAddr; 
                    emr.relationType = 'CcAddress';
                    emrList.add(emr);
                }
            }
                        
            if(!emrList.isEmpty()){
                insert emrList;
            }
            system.debug('emailMessage----' + emailMessage);
            system.debug('emrList----' + emrList);
            
            List<EmailMessage> emailMsgList = [SELECT Id, ActivityId FROM EmailMessage WHERE Id =: emailMessage.Id];
            Id maintenanceRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
            if(!emailMsgList.isEmpty()){
                if(!usrList.isEmpty()){
                    Task tskUpdate = new Task(Id=emailMsgList[0].ActivityId, Type__c='Email',
                                              Result__c='Owner Responded', OwnerId = usrList[0].Id, Status='Not Started',
                                              RecordTypeId = maintenanceRecordTypeId);
                    update tskUpdate;
                }
                
            }
            
        } else {
         
               List<Messaging.SingleEmailMessage> emailList1 = new List<Messaging.SingleEmailMessage>();
        
                Messaging.SingleEmailMessage email1= new Messaging.SingleEmailMessage();
                
                String[] toAddresses = new String[] {Label.Incoming_Email_Issue_email};
                
                email1.Setsubject(email.subject);
                email1.SetHTMLBody(email.htmlbody);
                
                email1.settoAddresses(toAddresses);
                emailList1.add(email1);
                
                if(!emailList1.isEmpty() && !Test.isRunningTest()){
                  Messaging.sendEmail(emailList1);
               }
        
        }
          
      return null; 
    }
}