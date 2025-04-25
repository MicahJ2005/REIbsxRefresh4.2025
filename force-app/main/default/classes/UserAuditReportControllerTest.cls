@istest()
public Class UserAuditReportControllerTest {

    @isTest()
    public static void Method1() {
    
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        UserAuditReportObjectName__c customsett = new UserAuditReportObjectName__c();
        customsett.Name = 'Account';
        customsett.Object_API_Name__c = 'Account';
        insert customsett;    
    
        PageReference pageRef = Page.UserAuditReport; 
        Test.setCurrentPage(pageRef);
        
        UserAuditReportController controller = new UserAuditReportController();               
        controller.startDate = date.today().addDays(-13);
        controller.endDate = date.today();
        controller.userObj.CreatedById = UserInfo.getUserId();
        UserAuditReportController.WrapperClass wrappCls = new UserAuditReportController.WrapperClass();               
        controller.searchButton();
        controller.Export_Data();
        
    }

}