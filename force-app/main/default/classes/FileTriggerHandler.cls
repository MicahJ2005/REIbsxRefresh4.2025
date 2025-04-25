/* **************************************************************************
*
* Controller Class: FileTriggerHandler
* Created by Anil Meghnathi: 14/09/2018
*
* - Trigger Handler Class for File Trigger
*
* - Modifications:
* - Anil Meghnathi, 14/09/2018 – Initial Development
************************************************************************** */
public class FileTriggerHandler {
    // Flag to skipp trigger
    public static Boolean isSkipTrigger = false;
    
    /*
    *   Executed:   On before insert of files
    *   Purpose:    Set file department using folder department
    *   Parameters: 
    *   UnitTests:  
    */
    public void onBeforeInsert(List<NEILON__File__c> newFiles){
        if(!isSkipTrigger){
            // Folder Ids
            Set<Id> folderIds = new Set<Id>();
            
            for(NEILON__File__c file : newFiles){
                folderIds.add(file.NEILON__Folder__c);
            }
            
            // Get folders
            Map<Id, NEILON__Folder__c> foldersById = new Map<Id, NEILON__Folder__c>([Select Id, Department__c From NEILON__Folder__c Where Id IN: folderIds]);
            
            // Set department
            for(NEILON__File__c file : newFiles){
                NEILON__Folder__c folder = foldersById.get(file.NEILON__Folder__c);
                file.Department__c = folder.Department__c;
            }
        }
    }
}