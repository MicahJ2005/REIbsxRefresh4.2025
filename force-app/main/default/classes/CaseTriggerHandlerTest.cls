@isTest
public class CaseTriggerHandlerTest {
    
    static testMethod void createnewcase() {
      User userToCreate = [Select id, Name from user where Name='Isaac Huicochea'];
      Id itCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('IT Team Support').getRecordTypeId();
      User finalUserAssign = [Select id, Name from user where Name='David Hall'];
        
      Test.startTest();    
      Case caseToCreate =new Case();
      List<Case> Ids= New List<Case>();
      caseToCreate.ownerid= userToCreate.id;
      caseToCreate.Type = 'Hardware';
      caseToCreate.Status='New';
      caseToCreate.RecordTypeId=itCaseRecordTypeId;
      caseToCreate.Priority='Medium';
      insert caseToCreate; 
      
      Ids.add(caseToCreate);
      CaseTriggerHandler.caseAssign(Ids);
        
      Case caseCreated = [SELECT Id,OwnerId FROM Case WHERE id =:caseToCreate.Id];
          
      System.assertEquals(caseCreated.OwnerId, finalUserAssign.id);
      
      Test.stopTest();
   }

}