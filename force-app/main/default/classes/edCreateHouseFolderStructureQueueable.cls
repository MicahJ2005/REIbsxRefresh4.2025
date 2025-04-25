/* **************************************************************************
*
* Controller Class: edCreateHouseFolderStructureQueueable
* Created by Anil Meghnathi: 02/09/2018
*
* - This is queuable class to create folder structure for house.

* - Modifications:
* - Anil Meghnathi, 02/09/2018 – Initial Development
************************************************************************** */
public without sharing class edCreateHouseFolderStructureQueueable implements Queueable{
	Set<Id> houseIds;
    //========================================================//
    //Constructor
    //Initialize variables and objects
    //========================================================//
    public edCreateHouseFolderStructureQueueable(Set<Id> houseIds){
        this.houseIds = houseIds;
	}
    
    /*
    *   Purpose:    Create default folders for house
    *   Parameters: 
    *   UnitTests:  
    */
    public static void createDefaultFoldersForHouse(){
    	// List of default folders for house
    	List<Folder_Configuration__c> folders = new List<Folder_Configuration__c>();
    	
    	Folder_Configuration__c folderForContracts = new Folder_Configuration__c(Name = '02-PurchaseClosings-ContractAddendums');
        folderForContracts.Shared_Departments__c = 'Closing;Buying;Agents;';
        folderForContracts.Object_Type__c = 'House__c';
        folders.add(folderForContracts);
        
        Folder_Configuration__c folderForRehab = new Folder_Configuration__c(Name = '04-PurchaseClosings-ClosingDocuments');
        folderForRehab.Shared_Departments__c = 'Closing;Agents(R);Rehab Admin;';
        folderForRehab.Object_Type__c = 'House__c';
        folders.add(folderForRehab);
        
        Folder_Configuration__c folderForFinance = new Folder_Configuration__c(Name = '06-PurchaseClosings-RefinancePackage');
        folderForFinance.Shared_Departments__c = 'Buying;Finance;';
        folderForFinance.Object_Type__c = 'House__c';
        folders.add(folderForFinance);
        
        Folder_Configuration__c folderForClosingsAddendums = new Folder_Configuration__c(Name = '08-Closings-ContractAddendums');
        folderForClosingsAddendums.Shared_Departments__c = 'Closing;Buying;Sales(R);';
        folderForClosingsAddendums.Object_Type__c = 'House__c';
        folders.add(folderForClosingsAddendums);
        
        Folder_Configuration__c folderForAccounting = new Folder_Configuration__c(Name = '10-Closings-PropertyManagement');
        folderForAccounting.Shared_Departments__c = 'Closing;Accounting;Customer Service(R);';
        folderForAccounting.Object_Type__c = 'House__c';
        folders.add(folderForAccounting);
        
        Folder_Configuration__c folderForClosingDocuments = new Folder_Configuration__c(Name = '12-Closings-ClosingDocuments');
        folderForClosingDocuments.Shared_Departments__c = 'Closing;Buying;Rehab Admin;';
        folderForClosingDocuments.Object_Type__c = 'House__c'; 
        folders.add(folderForClosingDocuments);
        
        insert folders;
    }
    
    /*
    *   Purpose:    Create folder structure for houses
    *   Parameters: 
    *   UnitTests:  
    */
    public static void createFolderStructure(Set<Id> houseIds){
    	// Get default bucket
    	List<NEILON__Folder__c> buckets = [Select Name From NEILON__Folder__c Where NEILON__Parent__c = null AND NEILON__Default__c = true AND NEILON__Active__c = true LIMIT 1];
    	
    	if(buckets.isEmpty()){
    		return;
    	}
    	
    	// Get houses
        Map<Id, House__c> housesById = new Map<Id, House__c>([Select Id, Name From House__c Where Id IN: houseIds]);
		
        // Record home folders by house Ids
        Map<Id, NEILON__Folder__c> recordHomeFoldersByHouseId = new Map<Id, NEILON__Folder__c>();
        
        // Get existing record home folder for houses
        List<NEILON__Folder__c> existingRecordHomeFolders = [Select Id, Name, House__c, NEILON__Bucket_Name__c, NEILON__Bucket_Region__c, (Select Id, Name, Department__c From NEILON__Children__r) From NEILON__Folder__c Where NEILON__Record_Home__c = true AND House__c IN: housesById.keySet()];
        for(NEILON__Folder__c existingRecordHomeFolder : existingRecordHomeFolders){
        	recordHomeFoldersByHouseId.put(existingRecordHomeFolder.House__c, existingRecordHomeFolder);
        }
        
        // Remove houses with existing folders
        if(!recordHomeFoldersByHouseId.isEmpty()){
        	houseIds.removeAll(recordHomeFoldersByHouseId.keySet());
        }
        
        // Create folder structure
        if(!houseIds.isEmpty()){
        	// Folder by house Id
        	Map<String, NEILON__Folder__c> newRecordHomeFoldersByHouseId = new Map<String, NEILON__Folder__c>();
        	
        	for(Id houseId : houseIds){
        		House__c house = housesById.get(houseId);
        		NEILON__Folder__c folderForHouse = new NEILON__Folder__c();
        		folderForHouse.Name = house.Name;
            	folderForHouse.NEILON__Description__c = 'Houses';
        	    folderForHouse.NEILON__Amazon_File_Key__c = buckets[0].Name+'/'+folderForHouse.NEILON__Description__c+'/'+folderForHouse.Name;
        		folderForHouse.NEILON__Parent_Id__c = house.Id;
        		newRecordHomeFoldersByHouseId.put(houseId, folderForHouse);
        	}
        	
        	// Set numbered folder names
        	NEILON.apGlobalUtils.setFolderNumbers(newRecordHomeFoldersByHouseId, false, 'New');
        	
        	// Prepare map of folder name by id
        	Map<Id, String> houseNamesById = new  Map<Id, String>();
        	for(NEILON__Folder__c folderForHouse : newRecordHomeFoldersByHouseId.values()){
        		houseNamesById.put(folderForHouse.NEILON__Parent_Id__c, folderForHouse.Name);
        	}
        	
        	// Create folder structure
	        Map<Id, NEILON__Folder__c> updatedRecordHomeFoldersByHouseId = NEILON.apGlobalUtils.buildFolderArchitecture(houseIds, houseNamesById);
	        
	        // Add new folders into list for existing
	        if(!updatedRecordHomeFoldersByHouseId.isEmpty()){
	        	for(NEILON__Folder__c folderForHouse : updatedRecordHomeFoldersByHouseId.values()){
	        		recordHomeFoldersByHouseId.put(folderForHouse.NEILON__Parent_Id__c, folderForHouse);
	        	}
	        }
        }
        
        // Folders to insert
        List<NEILON__Folder__c> dapartmentFoldersToInsert = new List<NEILON__Folder__c>();
        
        // Folders to delete
        List<NEILON__Folder__c> dapartmentFoldersToDelete = new List<NEILON__Folder__c>();
        
        // Folders to update
        List<NEILON__Folder__c> dapartmentFoldersToUpdate = new List<NEILON__Folder__c>();
        
        // Get folder configuration for house
        List<Folder_Configuration__c> folderConfigurations = [Select Id, Name, Shared_Departments__c From Folder_Configuration__c Where Object_Type__c = 'House__c'];
        
        // Configured department folder names
        Map<String, Folder_Configuration__c> configuredDepartmentFoldersByName = new Map<String, Folder_Configuration__c>();
        for(Folder_Configuration__c folderConfiguration : folderConfigurations){
        	configuredDepartmentFoldersByName.put(folderConfiguration.Name, folderConfiguration);
        }
        
        for(Id houseId : recordHomeFoldersByHouseId.keyset()){
        	
        	// Get record home folder
        	NEILON__Folder__c recordHomeFolder = recordHomeFoldersByHouseId.get(houseId);
        	
        	// Exsting department folders
        	List<NEILON__Folder__c> existingDepartmentFolders = new List<NEILON__Folder__c>();
        	if(recordHomeFolder != null && !recordHomeFolder.NEILON__Children__r.isEmpty()){
        		existingDepartmentFolders = recordHomeFolder.NEILON__Children__r;
        	}
        	
        	// Existing department folder names
        	Map<String, NEILON__Folder__c> existingDepartmentFoldersByName = new Map<String, NEILON__Folder__c>();
        	for(NEILON__Folder__c existingDepartmentFolder : existingDepartmentFolders){
        		if(!configuredDepartmentFoldersByName.containsKey(existingDepartmentFolder.Name)){
        			dapartmentFoldersToDelete.add(existingDepartmentFolder);
        		} else{
        			existingDepartmentFoldersByName.put(existingDepartmentFolder.Name, existingDepartmentFolder);
        		}
        	}
        	
        	if(recordHomeFolder != null){
	        	for(Folder_Configuration__c folderConfiguration : folderConfigurations){
	        		if(!existingDepartmentFoldersByName.containsKey(folderConfiguration.Name)){
			            NEILON__Folder__c folderForHouse = new NEILON__Folder__c(Name = folderConfiguration.Name);
			            folderForHouse.Department__c = folderConfiguration.Shared_Departments__c;
			            folderForHouse.House__c = houseId;
			            folderForHouse.NEILON__Parent_Id__c = houseId;
			            folderForHouse.NEILON__Parent__c = recordHomeFolder.Id; 
			            folderForHouse.NEILON__Parent_Object_API_Name__c = 'House__c';
			        	folderForHouse.NEILON__Bucket_Name__c = recordHomeFoldersByHouseId.values()[0].NEILON__Bucket_Name__c;
			        	folderForHouse.NEILON__Bucket_Region__c = recordHomeFoldersByHouseId.values()[0].NEILON__Bucket_Region__c;
			            dapartmentFoldersToInsert.add(folderForHouse);
	        		} else {
	        			NEILON__Folder__c existingDepartmentFolder = existingDepartmentFoldersByName.get(folderConfiguration.Name);
	        			if(existingDepartmentFolder.Department__c != folderConfiguration.Shared_Departments__c){
	        				existingDepartmentFolder.Department__c = folderConfiguration.Shared_Departments__c;
	        				dapartmentFoldersToUpdate.add(existingDepartmentFolder);
	        			}
	        		}
	        	}
        	}
        }
        
        // Create newely configured folders
        insert dapartmentFoldersToInsert;
        
        // Delete removed folders
        delete dapartmentFoldersToDelete;
        
        // Update shared departments for folders
        update dapartmentFoldersToUpdate;
    }
    
    /*
    *   Purpose:    Create folder structure for houses
    *   Parameters: 
    *   UnitTests:  
    */
    public void execute(QueueableContext context) {
    	// Create folder structure
        edCreateHouseFolderStructureQueueable.createFolderStructure(houseIds);
    }
}