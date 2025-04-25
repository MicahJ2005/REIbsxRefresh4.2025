@isTest
public class ProjectDaysVacantBatchTest {
    static testMethod void testBatchProject(){
        
        Account acc1 = new Account(Name ='Test acc'
                                  );
        insert acc1;
        
        House__c house = new House__c();
        house.Name = 'Test Name';
        house.State__c = 'MS';
        house.Street_Address__c = '703 Stell Ave';
        house.Street_Address_Line_2__c = '703 Stell Ave';
        house.City__c = 'Mansfield';
        house.State__c = 'TX';
        house.Zip_Code__c = '76063-2017';
        house.Lease_Terms__c  = '6 months';
        insert house; 
        
        Project__c pro = new Project__c();
        pro.Name = 'test project';
        pro.House__c = house.id;
        pro.Account__c = acc1.id;
        pro.Project_Status__c = 'Ready to Show';
        pro.Application_Status__c = 'Cancelled';
        pro.Move_Up_Date_New__c = date.today().addDays(-10);
        //pro.recordtypeId = Schema.SObjectType.Project__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
        insert pro;
        
        Test.startTest();
        
        ProjectDaysVacantBatch obj = new ProjectDaysVacantBatch();
        Database.executeBatch(obj);
        
        Test.stopTest();
    }
}