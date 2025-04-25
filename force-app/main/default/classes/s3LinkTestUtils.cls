/* **************************************************************************
* Copyright 2015-2018, Neilon Inc.
* All rights reserved
*
* Controller Class: s3LinkTestUtils
* Created by Anil Meghnathi: 14/09/2018
*
* - Used to create the test data.

* - Modifications:
* - Anil Meghnathi, 14/09/2018 – Initial Development
************************************************************************** */
@isTest
public class s3LinkTestUtils {
    public static User createUser(String alias, String emailAddress, String userName){
        // Create a user
        Profile p = [Select Id From Profile Where Name = 'System Administrator'];
        User testUser = new User(alias=alias, email=emailAddress, 
                    emailencodingkey='UTF-8', lastname='testing', languagelocalekey='en_US',
                    localesidkey='en_US', profileid=p.id, 
                    timezonesidkey='America/Los_Angeles', username=userName);
        insert testUser;
        System.assertEquals(testUser.Id != null, true);
        return testUser;
    }
    
    public static NEILON__Folder__c createFoldersForBucket(String name){
        NEILON__Folder__c bucket = new NEILON__Folder__c(Name = name);
        bucket.NEILON__Parent__c = null;
        bucket.NEILON__Active__c = true;
        bucket.NEILON__Default__c = true;
        insert bucket;
        return bucket;
    }
    
    public static List<NEILON__File__c> createFiles(NEILON__Folder__c folder){
        
        // Create files
        List<NEILON__File__c> files = new List<NEILON__File__c>();
        NEILON__File__c file1 = new NEILON__File__c(Name= 'File1.png');
        file1.NEILON__Folder__c = folder.Id;
        file1.NEILON__Bucket_Name__c = 'Test_Bucket1';
        file1.NEILON__Extension__c = '.png';
        file1.NEILON__Size__c = 5000;
        file1.NEILON__Content_Type__c = 'image/png';
        file1.NEILON__Track_Download_History__c = true;
        files.add(file1);
        
        NEILON__File__c file2 = new NEILON__File__c(Name= 'File2.png');
        file2.NEILON__Folder__c = folder.Id;
        file2.NEILON__Bucket_Name__c = 'Test_Bucket1';
        file2.NEILON__Extension__c = '.jpg';
        file2.NEILON__Size__c = 5001;
        file2.NEILON__Content_Type__c = 'image/jpg';
        files.add(file2);
        
        NEILON__File__c file3 = new NEILON__File__c(Name= 'File3.png');
        file3.NEILON__Folder__c = folder.Id;
        file3.NEILON__Bucket_Name__c = 'Test_Bucket1';
        file3.NEILON__Extension__c = '.pdf';
        file3.NEILON__Size__c = 5000;
        file3.NEILON__Content_Type__c = 'image/pdf';
        files.add(file3);
        
        insert files;
        return files;
    }  
    
    public static List<NEILON__Folder__c> createSubfolders(NEILON__Folder__c parentFolder){
		List<NEILON__Folder__c> subFolders = new List<NEILON__Folder__c>();
		NEILON__Folder__c sub1 = new NEILON__Folder__c(Name= parentFolder.Name+'_Sub_Folder1');
		sub1.NEILON__Bucket_Name__c = parentFolder.NEILON__Bucket_Name__c;
		sub1.NEILON__Parent__c = parentFolder.Id;
		subFolders.add(sub1);
		
		NEILON__Folder__c sub2 = new NEILON__Folder__c(Name= parentFolder.Name+'_Sub_Folder2');
		sub2.NEILON__Bucket_Name__c = parentFolder.NEILON__Bucket_Name__c;
		sub2.NEILON__Parent__c = parentFolder.Id;
		subFolders.add(sub2);
		
		insert subFolders;
		return subFolders;
	} 
}