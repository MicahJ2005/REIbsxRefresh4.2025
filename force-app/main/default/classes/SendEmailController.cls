/**
 * @description       : 
 * @author            : Michael Lloyd (Demand Chain)
 * @group             : 
 * @last modified on  : 01-26-2022
 * @last modified by  : Michael Lloyd (Demand Chain)
**/
global with sharing class SendEmailController {

    public String error{get;set;}
    public Id relatedToId{get;set;}
    public String emailFrom{get;set;}
    public String emailTo{get;set;}
    public String emailToName{get;set;}
    public String lookupName{get;set;}
    public String lookupValue{get;set;}
    public String lookupEmail{get;set;}
    public List<String> additionalToEmails{get;set;}
    public List<String> ccEmails{get;set;}
    public List<String> bccEmails{get;set;}
    public List<String> additionalToValues{get;set;}
    public List<String> ccValues{get;set;}
    public List<String> bccValues{get;set;}
    public String rowIndex{get;set;}
    public String subject{get;set;}
    public String body{get;set;}
    private Map<Id,EmailTemplate> allEmailTemplates;
    private Map<Id,EmailTemplate> REIEmailTemplates;
    private List<Folder> allEmailTemplateFolders;
    private Folder REIEmailTemplateFolders;
    private Map<Id,Document> allDocuments;
    private List<Folder> allDocumentsFolders;
    private Map<Id,Attachment> allAttachments;
    private Map<Id,ContentVersion> allFiles;
    public String selectedEmailTemplateFolder {public get; public set;}
    public String selectedEmailTemplate {public get; public set;}
    public EmailTemplate chosenEmailTemplate {public get; private set;}
    public String selectedDocumentFolder {public get; public set;}
    public String selectedDocument {public get; public set;}
    public Document chosenDocument {public get; private set;}
    public List<EmailAttachmentWrapper> emailAttachmentListWrapper{get;set;}
    public String rowIndexAttach{get;set;}
    public String newfilename{get;set;}
    public transient String newBody{get;set;}
    private Map<Id,Document> newDocuments;
    public String newFileId{get;set;}
    public Id accountId{get;set;}
    private String templateType;
    public List<Lead> relatedToIdLeadEmailAdd;
    public boolean relatedToIdLead {get;set;}
    public String emailId{get;set;}
        
    public SendEmailController(){
     
        relatedToId = apexpages.currentpage().getparameters().get('relatedId');
        relatedToIdLead = false;
        String sObjNameLead = relatedToId.getSObjectType().getDescribe().getName();
        if(sObjNameLead == 'Lead'){
            relatedToIdLeadEmailAdd = new List<Lead>();
            relatedToIdLeadEmailAdd = [SELECT  Id,Email FROM Lead Where Id =: relatedToId LIMIT 1];
            emailId = relatedToIdLeadEmailAdd[0].email;
            system.debug('emailId  == b '+emailId+'            relatedToIdLeadEmailAdd  '+relatedToIdLeadEmailAdd);
            relatedToIdLead = true;
            emailFrom = 'manish@cmentor.com';
        }
        
        
        //accountId = [select AcctSeed__Customer__c from AcctSeed__Billing__c where Id=:relatedToId ].AcctSeed__Customer__c;
        accountId = null;
        error = '';
        additionalToEmails =  new List<String>();
        ccEmails = new List<String>();
        bccEmails = new List<String>();
        additionalToValues = new List<String>();
        ccValues = new List<String>();
        bccValues = new List<String>();
        allEmailTemplates = new Map<Id,EmailTemplate>([select Id, Name, FolderId,TemplateType from EmailTemplate where isactive =true order by Name asc]);
        REIEmailTemplates = new Map<Id,EmailTemplate>([select Id, Name, FolderId,TemplateType from EmailTemplate where Folder.Name = 'Setter Email Templates' AND isactive =true order by Name asc]);
        allEmailTemplateFolders = [select Id, Name from Folder where Type = 'Email' AND Name != 'Setter Email Templates' order by Name asc];
        REIEmailTemplateFolders = [select Id, Name from Folder where Type = 'Email' AND Name = 'Setter Email Templates'];
        allDocuments = new Map<Id,Document>([select id,folderId,name,Folder.Name from Document order by name asc]);
        allDocumentsFolders = [select Id, Name from Folder where Type = 'Document' order by Name asc];
        allAttachments = new Map<Id,Attachment>([select id,name,ParentId from Attachment where ParentId = : relatedToId order by Name asc]);
        Set<Id> cdlIds = new Set<Id>();
        for(ContentDocumentLink cdl : [SELECT ContentDocumentId FROM ContentDocumentLink where LinkedEntityId = : relatedToId]){
            cdlIds.add(cdl.ContentDocumentId);
        }
        allFiles = new Map<Id,ContentVersion>([select id,Title from ContentVersion where ContentDocumentId in: cdlIds order by Title asc]);
        bccEmails.add(UserInfo.getUserEmail());
        bccValues.add(UserInfo.getName()+' <'+ UserInfo.getUserEmail() +'>');
        emailAttachmentListWrapper = new List<EmailAttachmentWrapper>();
        newDocuments = new Map<Id,Document>();
        selectedEmailTemplateFolder = REIEmailTemplateFolders.Id;
        refreshEmailTemplateSection();
    }
    public void deleteLookupValueFromList(){
        error = '';
        try{
            if(lookupName == 'AdditionalTo'){
                additionalToEmails.remove(Integer.valueOf(rowIndex));
                additionalToValues.remove(Integer.valueOf(rowIndex));
            }else if(lookupName == 'CC'){
                ccEmails.remove(Integer.valueOf(rowIndex));
                ccValues.remove(Integer.valueOf(rowIndex));
            }else if(lookupName == 'BCC'){
                bccEmails.remove(Integer.valueOf(rowIndex));
                bccValues.remove(Integer.valueOf(rowIndex));
            }
        }catch(Exception e){
            error = e.getMessage();
            system.debug('error :: ' + error);
        }
    }
    public void fillMultiLookupsValues(){
        error = '';
        try{
            if(lookupName == 'AdditionalTo'){
                additionalToEmails.add(lookupEmail);
                additionalToValues.add(lookupValue);
            }else if(lookupName == 'CC'){
                ccEmails.add(lookupEmail);
                ccValues.add(lookupValue);
            }else if(lookupName == 'BCC'){
                bccEmails.add(lookupEmail);
                bccValues.add(lookupValue);
            }
        }catch(Exception e){
            error = e.getMessage();
            system.debug('error :: ' + error);
        }
    }
    public List<SelectOption> getFrom() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('User','"'+UserInfo.getName()+'" <'+UserInfo.getUserEmail()+'>'));
        for (OrgWideEmailAddress orgWide : [select Id,DisplayName,Address from OrgWideEmailAddress]) {
            options.add(new SelectOption(orgWide.Id,'"'+orgWide.DisplayName+'" <'+orgWide.Address+'>'));
        }
        return options;
    }
    public List<SelectOption> getEmailTemplateFolderOpts() {
        List<SelectOption> opts = new List<SelectOption>();
        opts.add(new SelectOption(REIEmailTemplateFolders.Id,REIEmailTemplateFolders.name));
        for ( Folder f : allEmailTemplateFolders )
            opts.add(new SelectOption(f.Id, f.Name));
        // add an option for templates in the Unfiled Public folder
        opts.add(new SelectOption(UserInfo.getOrganizationId(), 'Unfiled Public'));
        return opts;
    }

    public List<SelectOption> getEmailTemplateOpts() {
        List<SelectOption> opts = new List<SelectOption>();
        opts.add(new SelectOption('', ' - Select - '));
        if ( selectedEmailTemplateFolder != null ) {
            Id selectedId = (Id) selectedEmailTemplateFolder	;
            for ( EmailTemplate et : allEmailTemplates.values() ) {
                if ( et.FolderId == selectedId )
                    opts.add(new SelectOption(et.Id, et.Name));
            }
        }
        return opts;
    }
    public List<SelectOption> getFileLocation(){
        List<SelectOption> opts = new List<SelectOption>();
        opts.add(new SelectOption('', ' - Select - '));
        opts.add(new SelectOption('My Computer', 'My Computer'));
        opts.add(new SelectOption('Notes & Attachments', 'Notes & Attachments'));
        opts.add(new SelectOption(UserInfo.getUserId(), 'My Personal Documents'));
        for ( Folder f : allDocumentsFolders )
            opts.add(new SelectOption(f.Id, f.Name));
        return opts;
    }
    public List<SelectOption> getDocumentOpts() {
        List<SelectOption> opts = new List<SelectOption>();
        opts.add(new SelectOption('', ' - Select - '));
        if ( String.isNotBlank(selectedDocumentFolder) && selectedDocumentFolder!='My Computer' && selectedDocumentFolder!='Notes & Attachments') {
            Id selectedId = (Id) selectedDocumentFolder;
            for ( Document et : allDocuments.values()) {
                if ( et.FolderId == selectedId )
                    opts.add(new SelectOption(et.Id, et.Name));
            }
        }
        if(String.isNotBlank(selectedDocumentFolder) && selectedDocumentFolder=='Notes & Attachments'){
            for ( Attachment at : allAttachments.values()) {
                opts.add(new SelectOption(at.Id, at.Name));
            }
            for ( ContentVersion at : allFiles.values()) {
                opts.add(new SelectOption(at.Id, at.Title));
            }
        }
        return opts;
    }
    public void refreshDocumentSection(){
        error = '';
        try{
            
        }catch(Exception e){
            error = e.getMessage();
            system.debug('error :: ' + error);
        }
    }
    public void refreshEmailTemplateSection() {
        error = '';
        try{
            if ( selectedEmailTemplateFolder == null || selectedEmailTemplateFolder == '' ) {
                selectedEmailTemplateFolder = null;
                selectedEmailTemplate = null;
            }
            if ( selectedEmailTemplate == null || selectedEmailTemplate == '' ) {
                selectedEmailTemplate = null;
                chosenEmailTemplate = null;
            } else {
                Id selectedId = (Id) selectedEmailTemplate;
                templateType = allEmailTemplates.get(selectedId).TemplateType;
                //chosenEmailTemplate = [select Id, Name, Subject, Body, FolderId,HtmlValue,DeveloperName,BrandTemplateId from EmailTemplate where id =: selectedId ]; // allEmailTemplates.get(selectedId);
                /*for ( EmailTemplate et : allEmailTemplates ) {
                    if ( et.Id == selectedId ) {
                        chosenEmailTemplate = et;
                        break;
                    }
                }*/
                /*Messaging.SingleEmailMessage dummyEmailMsg = new Messaging.SingleEmailMessage();
                dummyEmailMsg.setTemplateId(chosenEmailTemplate.Id);
                dummyEmailMsg.setSaveAsActivity(false);
                String[] toAddresses = new String[]{UserInfo.getUserEmail()};
                    dummyEmailMsg.setToAddresses(toAddresses);
                Savepoint sp = Database.setSavepoint();
                if(String.isNotBlank(emailTo)){
                    dummyEmailMsg.setTargetObjectId(Id.valueOf(emailTo));
                }
                if(relatedToId!=null){
                    dummyEmailMsg.setWhatId(relatedToId);
                }
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {dummyEmailMsg});
                Database.rollback(sp);*/
                Messaging.SingleEmailMessage dummyEmailMsg = new Messaging.SingleEmailMessage();
                //if(Id.valueOf(emailTo) != null){
                if(String.isNotBlank(emailTo)){
                    dummyEmailMsg = Messaging.renderStoredEmailTemplate(selectedId, Id.valueOf(emailTo), relatedToId);
                } else if(emailId != null){
                    dummyEmailMsg = Messaging.renderStoredEmailTemplate(selectedId, relatedToId, relatedToId);
                }
                
                subject = dummyEmailMsg.getSubject();
                System.debug('subject---'+subject);
                body = dummyEmailMsg.getHtmlBody();//'<iframe title="Content" scrolling="no" id="contentFrame" frameborder="0" src="/email/author/emailauthorframe.jsp?email_type=html" style="width: 602px; height: 1205px;"><html><body class="setupTab" style=" background-color:#D9D6D6; bEditID:b1st1; bLabel:body;"><center>' + dummyEmailMsg.getHtmlBody() + '</center></body></html></iframe>';
                System.debug('body---'+body);
                if(body == null){
                    body = dummyEmailMsg.getPlainTextBody();
                    System.debug(body);
                    body = body.replaceAll('\n', '<br/>');
                }
            }
        }catch(Exception e){
            selectedEmailTemplate =null;
            chosenEmailTemplate = null;
            if(e.getMessage().contains('REQUIRED_FIELD_MISSING, Missing targetObjectId with template')){
                error = 'Please select the receipient first.';
            }else{
                error = e.getMessage();
            }
            System.debug('error---'+error+':'+e.getLineNumber());
        }
    }
    public void attachFile(){
        try {
            error = '' ;
            if(String.isNotBlank(selectedDocumentFolder) && selectedDocumentFolder =='Notes & Attachments' && String.isNotBlank(selectedDocument)){
                EmailAttachmentWrapper wrapper = new EmailAttachmentWrapper();
                Id selectedId = (Id) selectedDocument;
                if(allAttachments.containsKey(selectedId)){
                    Attachment chosenAttachment = allAttachments.get(selectedId);
                    wrapper.name = chosenAttachment.Name;
                    wrapper.location = 'Notes & Attachments';
                    wrapper.fileId = selectedDocument;
                    emailAttachmentListWrapper.add(wrapper);
                }else if(allFiles.containsKey(selectedId)){
                    ContentVersion chosenAttachment = allFiles.get(selectedId);
                    wrapper.name = chosenAttachment.Title;
                    wrapper.location = 'Notes & Attachments';
                    wrapper.fileId = selectedDocument;
                    emailAttachmentListWrapper.add(wrapper);
                }
            }else if(String.isNotBlank(selectedDocumentFolder) && selectedDocumentFolder=='My Computer'){
                if(newfilename != null && newbody != null && newfilename != '' && newbody != ''){
                    Document doc = new Document();
                    doc.Name=newfilename;
                    newbody = newbody.replace(System.URL.getSalesforceBaseURL().toExternalForm()+'/', '');
                    doc.Body= EncodingUtil.base64Decode(newbody);
                    doc.FolderId = UserInfo.getUserId();
                    insert doc;
                    newbody = '';
                    doc.Body = null;
                    newDocuments.put(doc.Id,doc);
                    EmailAttachmentWrapper wrapper = new EmailAttachmentWrapper();
                    wrapper.name = newfilename;
                    wrapper.location = 'My Computer';
                    wrapper.fileId = doc.Id;
                    emailAttachmentListWrapper.add(wrapper);
                }
                if(newfilename != null && newfilename != '' && newFileId!=null && newFileId!=''){
                    Document doc = new Document();
                    doc.Name=newfilename;
                    doc.id = newFileId;
                    newDocuments.put(doc.Id,doc);
                    EmailAttachmentWrapper wrapper = new EmailAttachmentWrapper();
                    wrapper.name = newfilename;
                    wrapper.location = 'My Computer';
                    wrapper.fileId = doc.Id;
                    emailAttachmentListWrapper.add(wrapper);
                }
            }else if(String.isNotBlank(selectedDocumentFolder)  && String.isNotBlank(selectedDocument)){
                EmailAttachmentWrapper wrapper = new EmailAttachmentWrapper();
                Id selectedId = (Id) selectedDocument;
                chosenDocument = allDocuments.get(selectedId);
                /*for ( Document et : allDocuments ) {
                    if ( et.Id == selectedId ) {
                        chosenDocument = et;
                        break;
                    }
                }*/
                wrapper.name = chosenDocument.Name;
                wrapper.location = chosenDocument.Folder.Name;
                wrapper.fileId = selectedDocument;
                emailAttachmentListWrapper.add(wrapper);
            }
            selectedDocumentFolder = selectedDocument = '';
        }catch(Exception e){
            System.debug('e----'+e.getMessage());
            error = e.getMessage();
        }
    }
    public void deleteAttachment(){
        try {
            error = '' ;
            if(String.isNotBlank(rowIndexAttach)){
                EmailAttachmentWrapper wrapper = emailAttachmentListWrapper.get(Integer.valueOf(rowIndexAttach));
                if(wrapper.location == 'My Computer'){
                    emailAttachmentListWrapper.remove(Integer.valueOf(rowIndexAttach));
                    Document docToDelete = newDocuments.get(wrapper.fileId);
                    newDocuments.remove(wrapper.fileId);
                    delete docToDelete;
                }else{
                    emailAttachmentListWrapper.remove(Integer.valueOf(rowIndexAttach));
                }
            }
        }catch(Exception e){
            error = e.getMessage();
        }
    }
    public PageReference send() {
        try {
            System.debug('emailTo: ' + emailTo);
            System.debug('emailId: ' + emailId);
            error = '' ;
            Messaging.SingleEmailMessage singleEmailMsg = new Messaging.SingleEmailMessage();
			singleEmailMsg.setReplyTo(Label.LeadSendEmail);
            subject = subject + ' ' + 'REF: '+ relatedToId;
            if(bccEmails.size()>0){
                singleEmailMsg.setBccAddresses(bccEmails);
            }
            if(ccEmails.size()>0){
                singleEmailMsg.setccAddresses(ccEmails);
            }
            if(additionalToEmails.size()>0){
                singleEmailMsg.setToAddresses(additionalToEmails);
            }
            else if(String.isNotBlank(emailId) && emailId.length() > 0 ){
                singleEmailMsg.setToAddresses(new list<string>{string.valueOf(emailId)});
            }
            system.debug('emailFrom :: ' + emailFrom);
           // system.debug('Id.valueOf(emailFrom) :: ' + Id.valueOf(emailFrom));
                if(emailFrom!='User'){
                singleEmailMsg.setOrgWideEmailAddressId(Id.valueOf(emailFrom));
                //singleEmailMsg.setReplyTo(Label.MI_Email);
            }
            singleEmailMsg.setSubject(subject);
            if(!body.contains('ref')){
                body += '<p style="color:white"> [ref: '+ relatedToId +'] [userRef: '+ UserInfo.getUserId() +']</p>';
            }
            if(templateType == 'html'){
                singleEmailMsg.setHTMlBody('<body class="setupTab" style=" background-color:#D9D6D6; bEditID:b1st1; bLabel:body;"><center>'+body+'</center></body>');
            }else{
                singleEmailMsg.setHTMlBody(body);
            }
            singleEmailMsg.setSaveAsActivity(true);
            //singleEmailMsg.setWhatId(relatedToId); // commented by cmentor B.A
            if(relatedToId.getSObjectType().getDescribe().getName() == 'Lead'){
                singleEmailMsg.setTargetObjectId(Id.valueOf(relatedToId));
            }
            //singleEmailMsg.setTargetObjectId(relatedToId);
            //system.debug(' +++ ' + emailTo);
            
            //if(Id.valueOf(emailTo) != null){ // commented by cmentor B.A
            if( String.isNotBlank(emailTo)){
                singleEmailMsg.setTargetObjectId(Id.valueOf(emailTo)); // commented by cmentor B.A
            }else {
                singleEmailMsg.setTargetObjectId(relatedToId); // commented by cmentor B.A
            }

            if(emailAttachmentListWrapper.size()>0){
                List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();
                List<String> docIds = new List<String>();
                for(EmailAttachmentWrapper wrapper : emailAttachmentListWrapper){
                    //Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
                    docIds.add(wrapper.fileId);
                    /*if(wrapper.location == 'My Computer'){
                        //emailAttachment.setBody(newDocuments.get(wrapper.fileId).body);
                    }else if(wrapper.location == 'Notes & Attachments'){
                        //emailAttachment.setBody(allAttachments.get(wrapper.fileId).body);
                    }else{
                        //emailAttachment.setBody(allDocuments.get(wrapper.fileId).body);
                    }
                    //emailAttachment.setFileName(wrapper.name);
                    //emailAttachments.add(emailAttachment);*/
                }
                //singleEmailMsg.setFileAttachments(emailAttachments);
                singleEmailMsg.setEntityAttachments(docIds);
            }
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {singleEmailMsg});
            if(newDocuments.size()>0){
                delete newDocuments.values();
            }
            return new PageReference('/'+relatedToId);
        }catch(Exception e){
            error = e.getMessage();
            System.debug('error-- Line - ' +e.getLineNumber());
            System.debug('error-- Message - ' +e.getMessage());
            return null;
        }
    }
    @RemoteAction
    global static List<sObject> getLookupRecord(String likeString , String objectName) {
        if(String.IsNotBlank(likeString) && String.IsNotBlank(objectName)){
            likeString = likeString+'%';
            String query = '';
            if(objectName == 'Contact'){
                query = 'SELECT Id, Name,Email,Account.Name FROM '+objectName+' WHERE  (Name LIKE : likeString OR email like : likeString) and email!=null LIMIT 50';
            }else{
                query = 'SELECT Id, Name FROM '+objectName+' WHERE Name LIKE : likeString LIMIT 50';
            }
            List<sObject> sObjectsList = database.query(query);
            if(sObjectsList.size()<50){
                likeString = '%'+likeString+'%';
                if(objectName == 'Contact'){
                    query = 'SELECT Id, Name,Email,Account.Name FROM '+objectName+' WHERE (Name LIKE : likeString OR email like : likeString) and email!=null  and Id NOT IN: sObjectsList LIMIT '+ (50-sObjectsList.size());
                }else{
                    query = 'SELECT Id, Name FROM '+objectName+' WHERE Name LIKE : likeString LIMIT '+ (50-sObjectsList.size());
                }
                sObjectsList.addAll(database.query(query));
            }
            return sObjectsList;
        }
        return null;
    }
    @RemoteAction
    global static List<UserContactWrapper> getLookupRecordUserContact(String likeString,String accountId) {
        if(String.IsNotBlank(likeString)){
            likeString = '%'+likeString+'%';
            String query = '';
            List<UserContactWrapper> wrapperList = new List<UserContactWrapper>();
            query = 'SELECT Id, Name,Email,Account.Name FROM Contact WHERE (Name LIKE : likeString OR email like : likeString) and email!=null LIMIT 50';
            for(Contact cont : database.query(query) ){
                UserContactWrapper obj = new UserContactWrapper(cont.Id,cont.Name,cont.Email);
                wrapperList.add(obj);
            }
            if(wrapperList.size()<50){
                query = 'SELECT Id, Name,Email FROM User WHERE (Name LIKE : likeString OR email like : likeString) and email!=null and isactive = true LIMIT  '+ (50-wrapperList.size());
                for(User usr : database.query(query) ){
                    UserContactWrapper obj = new UserContactWrapper(usr.Id,usr.Name,usr.Email);
                    wrapperList.add(obj);
                }
            }
            return wrapperList;
        }
        return null;
    }
    public class EmailAttachmentWrapper{
        public String name{get;set;}
        public String location{get;set;}
        private Id fileId;
    }
    global class UserContactWrapper{
        public String Id{get;set;}
        public String Name{get;set;}
        public String Email{get;set;}
        global UserContactWrapper(String Id,String Name,String email){
            this.Id =Id;
            this.Name = Name;
            this.Email = Email;
        }
    }
}