@isTest(SeeAllData=false)
public class TaskLastCompletedBatchTest {
    
    @isTest static void method() {
        //Profile profileId =[SELECT Id FROM Profile WHERE Name = 'Custom: Sales Rep' LIMIT 1];
        Profile someProfile = [SELECT Id FROM Profile WHERE Name = 'Custom: Sales Rep' LIMIT 1];
        
        UserRole obj= new UserRole(Name = 'Sales Rep');
        insert obj;
         
        User usr = new User(
  			Alias = 'testu',
 			Email = 'test@example.com',
  			EmailEncodingKey = 'UTF-8',
  			LastName = 'Test',
  			LanguageLocaleKey = 'en_US',
  			LocaleSidKey = 'en_US',
  			TimeZoneSidKey='America/Los_Angeles',
  			UserRoleId=obj.Id,
            ProfileId=someProfile.Id,
  			UserName='test@examplereination.com',
            CommunityNickname='User123568509786'
		);

		INSERT usr;
        
        System.runAs(usr){
        
        List<Account> accList = new List<Account>();
        accList.add(new Account (Name = 'Investor 1',Phone='9016282964',OwnerId = usr.Id ,RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Investor Owner').getRecordTypeId()));
        insert accList;
        
        List<Task> TaskList = New List<Task>();
        taskList.add(new Task(Subject = 'Sales Call',OwnerId = usr.Id,Priority='Normal',Status='Completed',Call_Result_New__c = 'Connected - Spoke with', WhatId = accList[0].Id,RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Sales').getRecordTypeId()));
        taskList.add(new Task(Subject = 'Sales Call',OwnerId = usr.Id,Priority='Normal',Status='Completed', WhatId = accList[0].Id,RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Sales').getRecordTypeId()));
        insert TaskList;
        
        Test.startTest();
        TaskLastCompletedBatch bMethod = new TaskLastCompletedBatch();
        Database.executeBatch(bMethod);
            System.assert(accList[0].Name == 'Investor 1');
		Test.stopTest();  
        }
    }

}