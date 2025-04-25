@isTest
public class HubSpotTaskEmailServiceTest {
    
    @testSetup 
    public static void testSetup(){
        insert new One_to_One_Lead_Ref__c(Not_One_to_One__c = 0, One_to_One__c = 5); 
    }
    
    public static Lead insertLead(){
        Lead leadId=new Lead(LastName='Test Inbound',
                             Status='Contacted/Connection',
                             Company='Test Company',
                             Street = 'Test Street',
                             City = 'Test City',
                             State = 'MS',
                             postalCode = '12345',
                             Country = 'Test Country');
        insert leadId;
        return leadId;
    }
    
    @isTest public static void testInboundMail(){
        
        Lead ld=HubSpotTaskEmailServiceTest.insertLead();
        
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        email.subject = 'Test Email Subject';
        email.fromAddress = 'test@testorg.com';
        email.plainTextBody='REF: '+ld.Id+'</LeadId>';
        
        HubSpotTaskEmailService hubEmailServ=new HubSpotTaskEmailService();
        hubEmailServ.handleInboundEmail(email, env);   
    }
}