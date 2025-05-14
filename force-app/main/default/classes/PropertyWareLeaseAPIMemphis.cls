public with sharing class PropertyWareLeaseAPIMemphis implements Queueable, Database.AllowsCallouts{

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
                                                WHERE DeveloperName = 'PW_PPMG_Creds'
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



        try {
            HttpResponse response = http.send(request);
            if(response.getStatusCode() == 200) {
                List<Object> raw = (List<Object>) JSON.deserializeUntyped(response.getBody());
                system.debug('Memphis Leases:'+ raw);
            }
        } catch (Exception e) {
            System.debug('Callout error: ' + e.getMessage());
        }
    }
}