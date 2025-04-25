/**
    Name        : CaseTriggerNew 
    Date        : Jan 3, 2019
    Author      : Shweta Fulara(Cmentor)
    Description : Trigger on Case.
**/
trigger CaseTriggerNew on Case (before insert, before update,after insert) {
    
    if(trigger.isBefore && trigger.isInsert){
        CaseTriggerNewHandler.onBeforeInsert(trigger.new);
    } 
    if(trigger.isBefore && trigger.isUpdate){
        CaseTriggerNewHandler.onBeforeUpdate(trigger.new);
    }
    //DEPRECATED: As now we have new screen to create PI
    /*
    if(trigger.isAfter && trigger.isUpdate){
        CaseTriggerNewHandler.onAfterUpdate(trigger.new, trigger.oldMap);
    }    
	*/
    
    /*IT Case Assignment handling added here
     * -Isaac Arcos Huicochea on 03/25/2021
     */
    if(trigger.isInsert){
            CaseTriggerHandler.caseAssign(trigger.new);
        }      
}