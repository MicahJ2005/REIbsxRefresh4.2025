@isTest
public class UpdateProjDaysAvailableScheduleTest {
    static testMethod void scheduleTest(){
        
        Test.startTest();      
        UpdateProjDaysAvailableSchedule obj = new UpdateProjDaysAvailableSchedule();
        string cronexpression='0 0 6 ? * * *';
        system.schedule('testing',cronexpression , obj);
        Test.stopTest();
    }
}