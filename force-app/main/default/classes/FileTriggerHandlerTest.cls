/* **************************************************************************
* Copyright 2015-2018, Neilon Inc.
* All rights reserved
*
* Controller Class: FileTriggerHandlerTest
* Created by Anil Meghnathi: 14/09/2018
*
* - Test class for FileTriggerHandler.

* - Modifications:
* - Anil Meghnathi, 14/09/2018 – Initial Development
************************************************************************** */
@isTest
public class FileTriggerHandlerTest {
    @testsetup static void createTestData(){
        // Create user
        s3LinkTestUtils.createUser('testas', 'amegh@test.com', 'amegh@test.com');
        
        // Create buckets
        s3LinkTestUtils.createFoldersForBucket('test_bucket');
        
        // Create default folders for house
        edCreateHouseFolderStructureQueueable.createDefaultFoldersForHouse();
    }
    
    static testMethod void testInsertHouse() {
        Test.startTest();
        // Create house
        House__c house = new House__c(Name = 'Test House 1');
        insert house;
        Test.stopTest();
        
        // Get folders
        List<Neilon__Folder__c> folders = [Select Id, Department__c From Neilon__Folder__c Where NEILON__Parent__r.Name = 'Test House 1'];
        System.assertEquals(6, folders.size());
        
        // Create files
        List<Neilon__File__c> files = s3LinkTestUtils.createFiles(folders[0]);
        
        // Get department of files
        files = [Select Id, Department__c From Neilon__File__c Where Id IN: files];
        System.assertEquals(folders[0].Department__c, files[0].Department__c);
    }
}