public class SendEmailLeadExtn {

    sObject obj;
    
    public SendEmailLeadExtn(ApexPages.StandardController sc){
        obj = (sObject)sc.getRecord();
    }
    
    public PageReference sendMail(){
        PageReference pgRef = Page.SendEmail;
        pgRef.getParameters().put('relatedId', obj.Id);
        return pgRef;
    }
}