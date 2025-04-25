/* **************************************************************************
*
* Batch Class: edCreateHouseFolderStructureSchedulable
* Created by Anil Meghnathi: 26/09/2018
*
* - This is schedulable class to create folder structure for eixsting houses.

* - Modifications:
* - Anil Meghnathi, 26/09/2018 – Initial Development
************************************************************************** */
public class edCreateHouseFolderStructureSchedulable implements Schedulable{
	//========================================================//
    // Execute schedule
    //========================================================//
    public void execute(SchedulableContext sc){
        // Start a batch to update folder structure
        edCreateHouseFolderStructureBatchable batchable = new edCreateHouseFolderStructureBatchable('Select Id From House__c');
		Database.executeBatch(batchable, 10);
    }
}