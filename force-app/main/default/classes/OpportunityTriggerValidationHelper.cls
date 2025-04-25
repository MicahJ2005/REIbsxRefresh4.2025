public class OpportunityTriggerValidationHelper {
    
    public static void requiredOppStageValidation(List<Opportunity> oppsToReview) {
        Id salesRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Investor').getRecordTypeId();

        // Lists to store opportunities to review and their IDs
        List<Opportunity> oppIdsToReview = new List<Opportunity>();
        Set<Id> oppIds = new Set<Id>();

        // Filter opportunities based on criteria
        for (Opportunity opp : oppsToReview) {
            if (opp.RecordTypeId == salesRecordType && 
                (opp.StageName == 'Contract Out/ Title' || opp.StageName == 'Waiting To Close' || opp.StageName == 'Appraisal/HI')) {
                oppIdsToReview.add(opp);
                oppIds.add(opp.Id);
            }
        }

        System.debug('Opportunities to review: ' + oppIdsToReview);

        // Query OpportunityFieldHistory for all filtered Opportunity IDs
        Map<Id, List<OpportunityFieldHistory>> oppHistoryMap = new Map<Id, List<OpportunityFieldHistory>>();
        if (!oppIds.isEmpty()) {
            List<OpportunityFieldHistory> previousStages = [
                SELECT OpportunityId, OldValue, NewValue
                FROM OpportunityFieldHistory
                WHERE OpportunityId IN :oppIds
            ];
            
            // Group history records by OpportunityId
            for (OpportunityFieldHistory history : previousStages) {
                if (!oppHistoryMap.containsKey(history.OpportunityId)) {
                    oppHistoryMap.put(history.OpportunityId, new List<OpportunityFieldHistory>());
                }
                oppHistoryMap.get(history.OpportunityId).add(history);
            }
        }

        System.debug('OpportunityFieldHistory map: ' + oppHistoryMap);

        // Validate Opportunities based on history
        for (Opportunity opp : oppIdsToReview) {
            List<OpportunityFieldHistory> historyList = oppHistoryMap.get(opp.Id);
            Boolean isValidated = false;

            if (historyList != null) {
                for (OpportunityFieldHistory history : historyList) {
                    if (history.OldValue == 'HOT: Contract-Won' || history.NewValue == 'HOT: Contract-Won') { isValidated = true; break;}
                }
            }

            // Add error if not validated
            if (!isValidated) {
                opp.addError('The Opportunity must have entered the "HOT: Contract-Won" status before skipping ahead!');
            }
        }
    }
}