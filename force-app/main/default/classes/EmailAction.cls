global class EmailAction {
    
    @InvocableMethod(label='Send Email')
    global static List<EmailActionResult> sendEmails(List<EmailActionRequest> requests) {
        
        List<EmailActionResult> results = new List<EmailActionResult>();
        
        for(EmailActionRequest request : requests){
            results.add(sendEmail(request));
        }
        
        return results;
    }
    
    public static EmailActionResult sendEmail(EmailActionRequest request) {
        Boolean hasOptedOut = false;
        String objName = request.targetObjectId.getSObjectType().getDescribe().getName();
        if(objName == 'Contact'){
            List<Contact> conList = [SELECT Id, HasOptedOutOfEmail FROM Contact WHERE Id =: request.targetObjectId];
            if(!conList.isEmpty()){
                hasOptedOut = conList[0].HasOptedOutOfEmail;
            }
        }
        
        EmailActionResult emailActionResult = new EmailActionResult();
            
        if(objName != 'Contact' || (objName == 'Contact' && !hasOptedOut)){ 
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            mail.setSubject(request.subject);
            if(!request.getBccAddresses().isEmpty()){
                mail.setBccAddresses(request.getBccAddresses()); 
            }
            //mail.setCcAddresses(new List<String>{emailStr});
            if(!request.getCcAddresses().isEmpty()){
                mail.setCcAddresses(request.getCcAddresses());
            }
            mail.setTemplateId(request.emailTemplateId);
            mail.setHtmlBody(request.htmlBody);
            mail.setPlainTextBody(request.plainTextBody);
            //mail.setOrgWideEmailAddressId(request.orgWideEmailAddressId);
            //mail.setReplyTo(Label.MI_Email);
            mail.setSenderDisplayName(request.displayName);
            mail.setTargetObjectId(request.targetObjectId); // Only User, Contact, Lead, or Person objects are allowed for targetObjectId
            mail.setWhatId(request.whatId);
            mail.setSaveAsActivity(request.saveAsActivity);
            mail.setOptOutPolicy('FILTER');
            
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
            messages.add(mail);
            
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            
            for(Messaging.SendEmailResult result :results) {                
                
                if(result.IsSuccess()) {
                    
                    emailActionResult.isSuccess = true;
                    
                } else {
                    
                    emailActionResult.isSuccess = false;
                    Messaging.SendEmailError[] errors = result.getErrors(); 
                    
                    if (errors.size() > 0 ){
                        
                        emailActionResult.errorMessage = errors[0].getMessage();
                        System.debug('EmailAction error: ' + errors[0].getMessage()); 
                        
                    }
                }
            } 
        }
        else{
            emailActionResult.isSuccess = true;
        }
        
        return emailActionResult;
    }
    
    global class EmailActionResult {
        
        @InvocableVariable
        global Boolean isSuccess;
        
        @InvocableVariable
        global String errorMessage;
        
    }
    
    global class EmailActionRequest {
        
        private List<String> bccAddresses;
        private List<String> ccAddresses;
        
        @InvocableVariable(required=false)
        global Id emailTemplateId;
        
        @InvocableVariable(required=false)
        global String subject;
        
        @InvocableVariable(required=false)
        global String htmlBody;
        
        @InvocableVariable(required=false)
        global String plainTextBody;
        
        @InvocableVariable(required=false)
        global String ccAddress;
        
        @InvocableVariable(required=false)
        global String bccAddress;
        
        @InvocableVariable(required=false)
        global Id orgWideEmailAddressId;
        
        @InvocableVariable(required=false)
        global String displayName;
        
        @InvocableVariable(required=true)
        global Id targetObjectId;
        
        @InvocableVariable(required=true)
        global Id whatId;
        
        @InvocableVariable(required=false)
        global Boolean saveAsActivity;
        
        public EmailActionRequest() {
            ccAddresses = new List<String>();
            bccAddresses = new List<String>();
        }
        
        public List<String> getCcAddresses(){
            
            if (ccAddress != null){
                ccAddresses.add(ccAddress);    
            }
            return ccAddresses;
        }
        
        public List<String> getBccAddresses(){
            
            if (bccAddress != null){
                bccAddresses.add(bccAddress);    
            }
            return bccAddresses;
        }
        
    }
}