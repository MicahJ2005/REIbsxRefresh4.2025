/* **************************************************************************
*
* Batch Class: edCreateHouseFolderStructureBatchable
* Created by Anil Meghnathi: 18/09/2018
*
* - This is batch class to create folder structure for eixsting houses.

* - Modifications:
* - Anil Meghnathi, 18/09/2018 – Initial Development
************************************************************************** */
public class edCreateHouseFolderStructureBatchable implements Database.Batchable<sObject>, Database.Stateful{
	// Query to get houses
    public String query;
    
    //========================================================//
    // Constructor
    // Initialize variables and objects
    //========================================================//
    public edCreateHouseFolderStructureBatchable(String query){
    	this.query = query;
    }
    
	public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<House__c> scope){
    	// House ids to create folder structure
    	Set<Id> houseIds = new Set<Id>();
    	for(House__c house : scope){
    		houseIds.add(house.Id);
    	}
    	
    	// Create folder structure
        edCreateHouseFolderStructureQueueable.createFolderStructure(houseIds);
    }
    
    public void finish(Database.BatchableContext BC){
    }
}