public with sharing class PWLeaseConversationsController {
    @AuraEnabled(cacheable=false)
    public static List<Object> getLeaseConversations(Id leaseId) {
        // Query to get the lease external ID or API ID
        PW_Lease__c lease = [
            SELECT Id, PW_Lease_Entity_ID__c
            FROM PW_Lease__c
            WHERE Id = :leaseId
            LIMIT 1
        ];

        ///need to figure out how to query for specific market

        
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
       

        String endpoint = 'https://api.propertyware.com/pw/api/rest/v1/leases/' + lease.PW_Lease_Entity_ID__c + '/conversations';
// String endpoint = 'https://api.propertyware.com/pw/api/rest/v1/leases/3226009604/conversations';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        // req.setHeader('Authorization', 'Bearer ' + PropertyWareAuthService.getAccessToken()); // Replace with your auth mechanism
        req.setHeader('Content-Type', 'application/json');
        // Set required headers
        req.setHeader('x-propertyware-client-secret', PWPPMGCREDS.x_propertyware_client_secret__c);
        req.setHeader('x-propertyware-system-id', PWPPMGCREDS.x_propertyware_system_id__c);
        req.setHeader('x-propertyware-client-id', PWPPMGCREDS.x_propertyware_client_id__c);

        // Optional common headers
        req.setHeader('Accept', '*/*');
        req.setHeader('Accept-Encoding', 'gzip, deflate, br');
        req.setHeader('Connection', 'keep-alive');

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            List<Object> conversations = (List<Object>) JSON.deserializeUntyped(res.getBody());
            return conversations;
        } else {
            throw new AuraHandledException('Error fetching conversations: ' + res.getBody());
        }
    }
}
