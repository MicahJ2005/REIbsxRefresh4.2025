/* **************************************************************************
* Copyright 2015-2018, Neilon Inc.
* All rights reserved
*
* Controller Class: edCreateHouseFolderStructureBatchTest
* Created by Anil Meghnathi: 18/09/2018
*
* - Test class for edCreateHouseFolderStructureBatchable.

* - Modifications:
* - Anil Meghnathi, 18/09/2018 – Initial Development
************************************************************************** */
@isTest
public class edCreateHouseFolderStructureBatchTest {
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
        edCreateHouseFolderStructureBatchable batchable = new edCreateHouseFolderStructureBatchable('Select Id From House__c');
		Database.executeBatch(batchable, 10);
        Test.stopTest();
        
        // Get folders
        List<Neilon__Folder__c> folders = [Select Id From Neilon__Folder__c Where NEILON__Parent__r.Name = 'Test House 1'];
        System.assertEquals(6, folders.size());
        
    }
}