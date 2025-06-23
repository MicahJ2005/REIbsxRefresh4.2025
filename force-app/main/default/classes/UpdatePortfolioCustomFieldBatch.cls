public class UpdatePortfolioCustomFieldBatch implements Database.Batchable<SObject>, Database.Stateful {

    public Integer batchSize = 50;

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT Id, PW_Batch_Synced__c, PW_Portfolio_Entity_ID__c, Customer_Service_Assignment__c
            FROM PW_Portfolio__c 
            WHERE PW_Portfolio_Entity_ID__c != null 
            AND PW_Batch_Synced__c = false
            AND Customer_Service_Assignment__c != ' '
            // LIMIT: batchSize
        ]);
    }

    public void execute(Database.BatchableContext BC, List<SObject> scope) {
        List<String> portfolioIds = new List<String>();
        for (SObject sObj : scope) {
            PW_Portfolio__c portfolio = (PW_Portfolio__c) sObj;
            portfolioIds.add(portfolio.Id);
        }

        if (!portfolioIds.isEmpty()) {
            System.enqueueJob(new UpdatePortfolioCustomFieldQueueable(portfolioIds));
        }
    }

    public void finish(Database.BatchableContext BC) {
        // Optional: Add email or logging if needed
        System.debug('Finished executing UpdatePortfolioCustomFieldBatch');
    }
}
