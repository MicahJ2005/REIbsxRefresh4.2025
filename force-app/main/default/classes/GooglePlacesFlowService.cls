public class GooglePlacesFlowService {

    public class InputWrapper {
        @InvocableVariable(required=true)
        public Id recordId;
    }

    public class OutputWrapper {
        @InvocableVariable
        public String placeId;
    }

    @InvocableMethod(label='Get Google Place ID' description='Returns Google Place ID from Account address')
    public static void getPlaceIdFromAccount(List<InputWrapper> inputs) {
        system.debug('getPlaceIdFromAccount inputs: '+ inputs);
        List<OutputWrapper> results = new List<OutputWrapper>();

        for (InputWrapper input : inputs) {
            GooglePlacesService.getPlaceIdFromHouseRecordId(input.recordId);
        }
    }
}