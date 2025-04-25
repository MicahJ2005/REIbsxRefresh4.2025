/* **************************************************************************
* Copyright 2015-2018, Neilon Inc.
* All rights reserved
*
* Controller Class: edCreateHouseFolderStructureSchedulable
* Created by Anil Meghnathi: 26/09/2018
*
* - Test class for edCreateHouseFolderStructureSchedulable.

* - Modifications:
* - Anil Meghnathi, 26/09/2018 – Initial Development
************************************************************************** */
@isTest
public class edCreateHouseFolderStructureScheduleTest {
    @testsetup static void createTestData(){
        // Create user
        s3LinkTestUtils.createUser('testas', 'amegh@test.com', 'amegh@test.com');
        
        // Create buckets
        s3LinkTestUtils.createFoldersForBucket('test_bucket');
        
        // Create default folders for house
        edCreateHouseFolderStructureQueueable.createDefaultFoldersForHouse();
    }
    
    static testMethod void testBatch() {
    	Test.startTest();
        // Create house
        House__c house = new House__c(Name = 'Test House 1');
        
        FileTriggerHandler.isSkipTrigger = true;
        insert house;
        FileTriggerHandler.isSkipTrigger = false;
        
        // Start job to create folder strcuture
        edCreateHouseFolderStructureSchedulable schedule = new edCreateHouseFolderStructureSchedulable();
		schedule.execute(null);
        Test.stopTest();
        
        // Get folders
        List<Neilon__Folder__c> folders = [Select Id From Neilon__Folder__c Where NEILON__Parent__r.Name = 'Test House 1'];
        System.assertEquals(6, folders.size());
    }
}