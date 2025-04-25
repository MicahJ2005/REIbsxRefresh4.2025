global class UpdateProjDaysAvailableSchedule implements Schedulable  {
    
    global void execute(SchedulableContext sc){    
        UpdateProjDaysAvailableBatch objBatch = new UpdateProjDaysAvailableBatch();
        Database.executeBatch(objBatch);
        
    }    
    
}