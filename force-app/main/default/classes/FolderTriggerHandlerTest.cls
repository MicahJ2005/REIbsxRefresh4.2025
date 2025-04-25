/* **************************************************************************
* Copyright 2015-2018, Neilon Inc.
* All rights reserved
*
* Controller Class: FolderTriggerHandlerTest
* Created by Anil Meghnathi: 16/09/2018
*
* - Test class for FolderTriggerHandlerTest.

* - Modifications:
* - Anil Meghnathi, 16/09/2018 – Initial Development
************************************************************************** */
@isTest
public class FolderTriggerHandlerTest {
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
        List<Neilon__Folder__c> folders = [Select Id, Name, NEILON__Bucket_Name__c, Department__c From Neilon__Folder__c Where NEILON__Parent__r.Name = 'Test House 1'];
        System.assertEquals(6, folders.size());
        
        // Create files
        List<Neilon__Folder__c> subFolders = s3LinkTestUtils.createSubfolders(folders[0]);
        
        // Get department of files
        subFolders = [Select Id, Department__c From Neilon__Folder__c Where Id IN: subFolders];
        System.assertEquals(subFolders[0].Department__c, folders[0].Department__c);
    }
}