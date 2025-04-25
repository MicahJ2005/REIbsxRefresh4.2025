@isTest
public class ProjectDaysVacantBatchScheduleTest {
    
    static testMethod void scheduleTest(){
        Test.startTest();
        
        ProjectDaysVacantBatchSchedule obj = new ProjectDaysVacantBatchSchedule();
        string cronexpression='0 0 6 ? * * *';
        system.schedule('testing',cronexpression , obj);
        
        
        Test.stopTest();
    }

}