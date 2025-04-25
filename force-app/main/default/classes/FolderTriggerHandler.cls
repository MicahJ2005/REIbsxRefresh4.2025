/* **************************************************************************
*
* Controller Class: FolderTriggerHandler
* Created by Anil Meghnathi: 16/09/2018
*
* - Trigger Handler Class for Folder Trigger
*
* - Modifications:
* - Anil Meghnathi, 16/09/2018 – Initial Development
************************************************************************** */
public class FolderTriggerHandler {
    // Flag to skipp trigger
    public static Boolean isSkipTrigger = false;
    
    /*
    *   Executed:   On before insert of folders
    *   Purpose:    Set file department using parent folder department
    *   Parameters: 
    *   UnitTests:  
    */
    public void onBeforeInsert(List<NEILON__Folder__c> newFolders){
        if(!isSkipTrigger){
            // Folder Ids
            Set<Id> folderIds = new Set<Id>();
            
            for(NEILON__Folder__c newFolder : newFolders){
                if(newFolder.NEILON__Parent__c != null){
                	folderIds.add(newFolder.NEILON__Parent__c);
                }
            }
            
            // Get folders
            Map<Id, NEILON__Folder__c> foldersById = new Map<Id, NEILON__Folder__c>([Select Id, Department__c From NEILON__Folder__c Where Id IN: folderIds]);
            
            // Set department
            for(NEILON__Folder__c newFolder : newFolders){
                if(String.isBlank(newFolder.Department__c)){
                	NEILON__Folder__c folder = foldersById.get(newFolder.NEILON__Parent__c);
                    if(folder != null){
                		newFolder.Department__c = folder.Department__c;
                    }
                }
            }
        }
    }
}