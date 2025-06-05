public with sharing class UpdatePortfolioCustomFieldQueueable implements Queueable, Database.AllowsCallouts {

    private List<String> entityIds;

    public UpdatePortfolioCustomFieldQueueable(List<String> entityIds) {
        this.entityIds = entityIds;
    }

    public void execute(QueueableContext context) {
        System.debug('entityIds In QUEUE: '+ entityIds);
        List<PW_Portfolio__c> portfolioList = [SELECT Id, PW_Org__c, PW_Portfolio_Entity_ID__c, Customer_Service_Assignment__c FROM PW_Portfolio__c WHERE Id IN: entityIds];
        
        for (PW_Portfolio__c portfolio : portfolioList) {    
            string metadataDevName = '';
            if(portfolio.PW_Org__c == 'PPMG of Texas, LLC'){
                metadataDevName = 'PW_PPMG_of_Texas_Creds';
            }
            else if(portfolio.PW_Org__c == 'Premier Property Management Group'){
                metadataDevName = 'PW_PPMG_Creds';
            }

            PropertyWare_Setting__mdt PWPPMGCREDS = [
                                                    SELECT 
                                                        MasterLabel,
                                                        DeveloperName,
                                                        x_propertyware_client_id__c,
                                                        x_propertyware_client_secret__c,
                                                        x_propertyware_system_id__c
                                                    FROM PropertyWare_Setting__mdt
                                                    WHERE DeveloperName =: metadataDevName
                                                    LIMIT 1
                                                ];
            Http http = new Http();

        
           HttpRequest request = new HttpRequest();

            request.setEndpoint('https://api.propertyware.com/pw/api/rest/v1/portfolios/customfields');
            request.setMethod('PUT');
            request.setTimeout(30000); // 30 seconds
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Accept', 'application/json');

            // TODO: Replace with real token or authentication method
            request.setHeader('x-propertyware-client-secret', PWPPMGCREDS.x_propertyware_client_secret__c);
            request.setHeader('x-propertyware-system-id', PWPPMGCREDS.x_propertyware_system_id__c);
            request.setHeader('x-propertyware-client-id', PWPPMGCREDS.x_propertyware_client_id__c);

            Map<String, Object> payload = new Map<String, Object>{
                'entityId' => portfolio.PW_Portfolio_Entity_ID__c,
                'fieldSetDTOS' => new List<Object>{
                    new Map<String, Object>{
                        'name' => 'CSR Assignment',
                        'value' => portfolio.Customer_Service_Assignment__c
                    }
                }
            };

            request.setBody(JSON.serialize(payload));

            try {
                HttpResponse res = http.send(request);
                if (res.getStatusCode() != 200 && res.getStatusCode() != 204) {
                    System.debug('Failed for ID ' + portfolio.PW_Portfolio_Entity_ID__c + ': ' + res.getBody());
                } else {
                    System.debug('Success for ID ' + portfolio.PW_Portfolio_Entity_ID__c);
                }
            } catch (Exception ex) {
                System.debug('Callout failed for ID ' + portfolio.PW_Portfolio_Entity_ID__c + ': ' + ex.getMessage());
            }
        }
    }
}
