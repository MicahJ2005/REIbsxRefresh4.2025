@IsTest
public class TaskOwnerUpdateCtrlTest {
    
    
    @testSetup
    static void testDaat(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Custom: Customer Service']; 
        User u = new User(Alias = 'standt', Email='customer@Serive.com', 
                          EmailEncodingKey='UTF-8', LastName='customerLastName', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='customer@Serive.com');
        insert u;
        
        Task tsk = new Task();
        tsk.Subject = 'Test Subject';
        insert tsk;
    }
    
    @IsTest
    public static  void default_Test() {
        
        List<User> userList = [SELECT Id FROM User];
        List<Task> tskList = [SELECT Id FROM Task];
        
        PageReference pageRef = Page.TaskOwnerUpdate;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id',tskList[0].id);
        TaskOwnerUpdateCtrl controller = new TaskOwnerUpdateCtrl();
        controller.taskObj.New_Assignee__c = userList[0].id;
        controller.saveAndRedirect();
        
        System.runAs(userList[0]) {
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId());
        }
    }
    
    @IsTest
    public static  void default_Test_1() {
        
        List<User> userList = [SELECT Id FROM User];
        List<Task> tskList = [SELECT Id FROM Task];
        
        
        PageReference pageRef = Page.TaskOwnerUpdate;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id',tskList[0].id);
        TaskOwnerUpdateCtrl controller = new TaskOwnerUpdateCtrl();
        controller.taskObj.New_Assignee__c = tskList[0].id;
        controller.saveAndRedirect();
        
        System.runAs(userList[0]) {
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId());
        }
    }
    
    @IsTest
    public static  void default_Test_2() {
        
        List<User> userList = [SELECT Id FROM User];
        List<Task> tskList = [SELECT Id FROM Task];
        
        PageReference pageRef = Page.TaskOwnerUpdate;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id',tskList[0].id);
        TaskOwnerUpdateCtrl controller = new TaskOwnerUpdateCtrl();
        controller.saveAndRedirect();
        
        System.runAs(userList[0]) {
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId());
        }
    }
    
}