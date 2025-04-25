global class ProjectDaysVacantBatchSchedule implements Schedulable  {
    
    global void execute(SchedulableContext sc)
    {    
        ProjectDaysVacantBatch objBatch = new ProjectDaysVacantBatch();
        Database.executeBatch(objBatch);
        
    }    
    
}