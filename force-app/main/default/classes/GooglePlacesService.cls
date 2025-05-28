public class GooglePlacesService {
    
    private static final String API_KEY = Google_API_Settings__mdt.getInstance('Google_Places_Key').Value__c;

    public class PlaceSearchResult {
        public List<Prediction> candidates;
        public String status;
    }

    public class Prediction {
        public String place_id;
    }

    
    public static void getPlaceIdFromHouseRecordId(map<Id, House__c> newMap, map<Id, House__c> oldMap) {

        List<House__c> houseListToUpdate = new List<House__c>();
        
        for(House__c acc: newMap.values()){
            String address = '';
            if(acc.House_Complete_Address__c != null){
                address = acc.House_Complete_Address__c;
            }
            
            address = address.trim();
            if (address.endsWith(',')) {
                address = address.substring(0, address.length() - 1);
            }
            System.debug('address: '+ address);
            string placeId = getPlaceIdFromAddress(address);
            System.debug('placeId: '+ placeId);
            if(placeId != null){
                acc.Google_Place_ID__c = placeId;
                houseListToUpdate.add(acc);
            }
        }
        if(houseListToUpdate.size() > 0 ){
            update houseListToUpdate;
        }
    }

    
    public static String getPlaceIdFromAddress(String address) {
        System.debug('address: '+ address);
        // Prepare the endpoint
        String baseUrl = 'https://maps.googleapis.com/maps/api/place/findplacefromtext/json';
        String input = EncodingUtil.urlEncode(address, 'UTF-8');
        String url = baseUrl + '?input=' + input + '&inputtype=textquery&fields=place_id&key=' + API_KEY;

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod('GET');

        try {
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                PlaceSearchResult result = (PlaceSearchResult) JSON.deserialize(response.getBody(), PlaceSearchResult.class);
                if (result != null && result.candidates != null && result.candidates.size() > 0) {
                    return result.candidates[0].place_id;
                } else {
                    System.debug('No place ID found for the address.');
                }
            } else {
                System.debug('Failed to call Google Places API: ' + response.getStatus());
            }
        } catch (Exception ex) {
            System.debug('Exception: ' + ex.getMessage());
        }
        return null;
    }
}