public with sharing class UpdatePortfolioCustomField {

    @InvocableMethod(label='Update PW Portfolio Custom Field' description='Queues updates for PW Portfolio custom fields')
    public static void updateCustomField(List<PortfolioInput> inputList) {

        if (inputList.size() > 0) {
            System.enqueueJob(new UpdatePortfolioCustomFieldQueueable((List<String>)inputList[0].entityIdList));
        }
    }

    public class PortfolioInput {
        @InvocableVariable(label='Entity ID List' description='The ID of the PW Portfolio entity')
        public List<String> entityIdList;
    }
}
