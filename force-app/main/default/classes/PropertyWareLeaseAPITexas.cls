public with sharing class PropertyWareLeaseAPITexas implements Queueable, Database.AllowsCallouts{

    public void execute(QueueableContext ctx) {
        getLeases();
    }
    
    public static void getLeases() {

        PropertyWare_Setting__mdt PWPPMGCREDS = [
                                                SELECT 
                                                    MasterLabel,
                                                    DeveloperName,
                                                    x_propertyware_client_id__c,
                                                    x_propertyware_client_secret__c,
                                                    x_propertyware_system_id__c
                                                FROM PropertyWare_Setting__mdt
                                                WHERE DeveloperName = 'PW_PPMG_of_Texas_Creds'
                                                LIMIT 1
                                            ];

        PropertyWare_Setting__mdt PWgetBuildingHoursSpanMTD = [
            SELECT 
                MasterLabel,
                DeveloperName,
                IntegerValue__c
            FROM PropertyWare_Setting__mdt
            WHERE DeveloperName = 'EndFromHoursAgo'
            LIMIT 1
                ];

        PropertyWare_Setting__mdt PWStartFromHoursAgoMTD = [
                        SELECT 
                            MasterLabel,
                            DeveloperName,
                            IntegerValue__c
                        FROM PropertyWare_Setting__mdt
                        WHERE DeveloperName = 'StartFromHoursAgo'
                        LIMIT 1
                            ];           


        Http http = new Http();
        HttpRequest request = new HttpRequest();
        Datetime now = Datetime.now(); // Current datetime
        String toDateTime = now.addHours(Integer.valueOf(PWgetBuildingHoursSpanMTD.IntegerValue__c)).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''); // set by EndFromHoursAgo Custom Metadata
        
        String fromDateTime = now.addHours(Integer.valueOf(PWStartFromHoursAgoMTD.IntegerValue__c)).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''); // set by StartFromHoursAgo Custom Metadata

        string dateTimeParameters = '?lastModifiedDateTimeStart='+ EncodingUtil.urlEncode(fromDateTime, 'UTF-8')+'&lastModifiedDateTimeEnd='+ EncodingUtil.urlEncode(toDateTime, 'UTF-8');
        System.debug(dateTimeParameters);

        request.setEndpoint('https://api.propertyware.com/pw/api/rest/v1/leases'+ dateTimeParameters+'&includeDeactivated=true&includeCustomFields=true');
        request.setMethod('GET');

        // Set required headers
        request.setHeader('x-propertyware-client-id', PWPPMGCREDS.x_propertyware_client_id__c);
        request.setHeader('x-propertyware-client-secret', PWPPMGCREDS.x_propertyware_client_secret__c);
        request.setHeader('x-propertyware-system-id', PWPPMGCREDS.x_propertyware_system_id__c);

        // Optional common headers
        request.setHeader('Accept', '*/*');
        request.setHeader('Accept-Encoding', 'gzip, deflate, br');
        request.setHeader('Connection', 'keep-alive');

        // Map<String, PWBuildingWrapper> PWIdAndAddress = new Map<String, PWBuildingWrapper>();

        Map<String, List<Object>> buildingIdAndLeaseFromPW = new Map<String, List<Object>>();

        try {
            HttpResponse response = http.send(request);
            if(response.getStatusCode() == 200) {
                List<Object> raw = (List<Object>) JSON.deserializeUntyped(response.getBody());
                system.debug('Texas Leases:'+ raw);
                for(Object o: raw){
                    Map<String, Object> lease = (Map<String, Object>) o;
                    system.debug('Texas Leases in Loop:'+ lease);
                    if(buildingIdAndLeaseFromPW.containsKey(String.valueOf(lease.get('buildingId')))){
                        buildingIdAndLeaseFromPW.get(String.valueOf(lease.get('buildingId'))).add(lease);
                    }else{
                        buildingIdAndLeaseFromPW.put(String.valueOf(lease.get('buildingId')), new List<Object>{lease});
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Callout error: ' + e.getMessage());
        }

       List<PW_Building__c> currentBuildings = getPWBuildings(buildingIdAndLeaseFromPW);
       system.debug('Texas currentBuildings:'+ currentBuildings);
       for(PW_Building__c building: currentBuildings){
           system.debug('building PW MAP'+ buildingIdAndLeaseFromPW.get(building.PW_Building_ID__c));
        }
           
    }
    

    public static List<PW_Building__c> getPWBuildings(Map<String, Object> buildingIdAndLeaseFromPW) {
        return [
            SELECT Id, 
                Name,   
                PW_Building_Entity_ID1__c, 
                PW_Building_ID__c
                FROM PW_Building__c
                WHERE PW_Building_ID__c IN :buildingIdAndLeaseFromPW.keySet()
            ];
    }
}