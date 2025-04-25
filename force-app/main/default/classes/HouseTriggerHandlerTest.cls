/* **************************************************************************
* Copyright 2015-2018, Neilon Inc.
* All rights reserved
*
* Controller Class: HouseTriggerHandlerTest
* Created by Anil Meghnathi: 14/09/2018
*
* - Test class for HouseTriggerHandler.

* - Modifications:
* - Anil Meghnathi, 14/09/2018 – Initial Development
************************************************************************** */
@isTest
public class HouseTriggerHandlerTest {
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
        List<Neilon__Folder__c> folders = [Select Id From Neilon__Folder__c Where NEILON__Parent__r.Name = 'Test House 1'];
        System.assertEquals(6, folders.size());
    }
    
        static testMethod void testBeforeUpdateHouse() {
        Test.startTest();
        // Create house
        House__c house = new House__c(Name = 'Test House 1');
        insert house;
        update house;
        Test.stopTest();
        
        // Get folders
        List<Neilon__Folder__c> folders = [Select Id From Neilon__Folder__c Where NEILON__Parent__r.Name = 'Test House 1'];
        System.assertEquals(6, folders.size());
    }
    
    static testMethod void testUpdateAccountInformation(){
               
        List<Account> accList = new List<Account>();
        accList.add(new Account (Name = 'Investor 1',Phone='9016282964',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Investor Owner').getRecordTypeId()));
        insert accList;
        
        List <House__c> newHouses = new List<House__c>();
        
        newHouses.add(new House__c(Name = 'Investor House 1', Market__c = 'MEM', City__c = 'Memphis',Street_Address__c='1234 Test House',State__c='TN',Zip_Code__c='38141',
                                              House_Type__c='Single Family Detached',Sq_Feet__c=1234,Bedrooms__c='1',Bathrooms__c='1',Year_Built__c='1974', Car_Storage_Parking__c = 'DR',
                                              Investor__c=accList[0].Id, Status__c='Managed',Management_Source__c='Purchased From REI'));
        newHouses.add(new House__c(Name = 'Investor House 2', Market__c = 'MEM', City__c = 'Memphis',Street_Address__c='1234 Test House',State__c='TN',Zip_Code__c='38141',
                                              House_Type__c='Single Family Detached',Sq_Feet__c=1234,Bedrooms__c='1',Bathrooms__c='1',Year_Built__c='1974', Car_Storage_Parking__c = 'DR',
                                              Investor__c=accList[0].Id, Status__c='Managed',Management_Source__c='Outside'));
        newHouses.add(new House__c(Name = 'Investor House 3', Market__c = 'MEM', City__c = 'Memphis',Street_Address__c='1234 Test House',State__c='TN',Zip_Code__c='38141',
                                              House_Type__c='Single Family Detached',Sq_Feet__c=1234,Bedrooms__c='1',Bathrooms__c='1',Year_Built__c='1974', Car_Storage_Parking__c = 'DR',
                                              Investor__c=accList[0].Id, Status__c='Managed',Management_Source__c='Purchased From REI'));
        
        
        Test.startTest();
        insert newHouses;
        Test.stopTest();
        
        Account investorConfirmation = [SELECT Id, Name, Outside_Properties_Managed__c,	REI_Properties_Managed__c FROM Account WHERE Name = 'Investor 1' LIMIT 1];
        
        System.assertEquals(2, investorConfirmation.REI_Properties_Managed__c);
        System.assertEquals(1, investorConfirmation.Outside_Properties_Managed__c);
        
    }
}