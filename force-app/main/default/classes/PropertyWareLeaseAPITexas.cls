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

        Map<String, List<Object>> buildingIdAndLeaseFromPW = new Map<String, List<Object>>();

        List<Object> raw = new List<Object>();
        try {
            HttpResponse response = http.send(request);
            if(response.getStatusCode() == 200) {
                raw = (List<Object>) JSON.deserializeUntyped(response.getBody());
                system.debug('Texas Leases:'+ raw);
                for(Object o: raw){
                    Map<String, Object> lease = (Map<String, Object>) o;
                    system.debug('Texas Leases in Loop:'+ lease);
                    system.debug('Texas Leases in Loop buildingID:'+ lease.get('buildingID'));
                    if(String.valueOf(lease.get('buildingID')) != null){
                        if(buildingIdAndLeaseFromPW.containsKey(String.valueOf(lease.get('buildingID')))){
                            buildingIdAndLeaseFromPW.get(String.valueOf(lease.get('buildingID'))).add(lease);
                        }else{
                            buildingIdAndLeaseFromPW.put(String.valueOf(lease.get('buildingID')), new List<Object>());
                            buildingIdAndLeaseFromPW.get(String.valueOf(lease.get('buildingID'))).add(lease);
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Callout error: ' + e.getMessage());
        }

       Map<string, PW_Building__c> currentBuildingsMap = getPWBuildings(buildingIdAndLeaseFromPW);
       system.debug('Texas currentBuildings:'+ currentBuildingsMap);

       Map<string, PW_Lease__c> currentLeasesMap = getLeases(buildingIdAndLeaseFromPW);
       system.debug('Texas currentLeases:'+ currentLeasesMap);
       
       List<PW_Lease__c> newLeases = new List<PW_Lease__c>();

       if(raw.size() > 0){
            // raw = (List<Object>) JSON.deserializeUntyped(response.getBody());
            system.debug('Texas Leases:'+ raw);
            for(Object o: raw){
                Map<String, Object> lease = (Map<String, Object>) o;
                PW_Lease__c leaseRecord = new PW_Lease__c();
                
                if(currentLeasesMap.containsKey(String.valueOf(lease.get('id')))){
                    leaseRecord.Id = String.valueOf(currentLeasesMap.get(String.valueOf(lease.get('id'))).Id);
                }
                if(currentBuildingsMap.containsKey(String.valueOf(lease.get('buildingID')))){
                    leaseRecord.PW_Building__c = currentBuildingsMap.get(String.valueOf(lease.get('buildingID'))).Id;
                }

                leaseRecord.Name = String.valueOf(lease.get('leaseName'));
                leaseRecord.PW_Active__c = (Boolean) lease.get('active');
                leaseRecord.PW_Lease_Entity_ID__c = String.valueOf(lease.get('id'));
                leaseRecord.PW_Building_Entity_ID__c = String.valueOf(lease.get('buildingID'));
                leaseRecord.PW_Portfolio_Entity_ID__c = String.valueOf(lease.get('portfolioID'));
                leaseRecord.PW_Lease_Status__c = String.valueOf(lease.get('status'));

                leaseRecord.PW_Move_In_Date__c = lease.containsKey('moveInDate') && lease.get('moveInDate') != null
                    ? String.valueOf(lease.get('moveInDate')) : null;
                leaseRecord.PW_Move_Out_Date__c = lease.containsKey('moveOutDate') && lease.get('moveOutDate') != null
                    ? String.valueOf(lease.get('moveOutDate')) : null;
                leaseRecord.PW_Notice_Given_Date__c = lease.containsKey('noticeGivenDate') && lease.get('noticeGivenDate') != null
                    ? String.valueOf(lease.get('noticeGivenDate')) : null;
                leaseRecord.PW_Start_Date__c = lease.containsKey('startDate') && lease.get('startDate') != null
                    ? String.valueOf(lease.get('startDate')) : null;
                leaseRecord.PW_End_Date__c = lease.containsKey('endDate') && lease.get('endDate') != null
                    ? String.valueOf(lease.get('endDate')) : null;
                leaseRecord.PW_Last_Modified_in_Propertyware__c = lease.containsKey('lastModifiedDateTime') && lease.get('lastModifiedDateTime') != null
                    ? formatZuluDateTime(String.valueOf(lease.get('lastModifiedDateTime'))) : null;
                leaseRecord.PW_Create_Date_in_Propertyware__c = lease.containsKey('createdDateTime') && lease.get('createdDateTime') != null
                    ? formatZuluDateTime(String.valueOf(lease.get('createdDateTime'))) : null;

                leaseRecord.PW_Lease_Balance__c = lease.containsKey('leaseBalance') && lease.get('leaseBalance') != null
                    ? String.valueOf(lease.get('leaseBalance')) : null;
                leaseRecord.PW_Base_Rent__c = lease.containsKey('baseRent') && lease.get('baseRent') != null
                    ? String.valueOf(lease.get('baseRent')) : null;

                ///Check for custom fields
                if (lease.containsKey('customFields') && lease.get('customFields') != null) {
                    List<Object> customFields = (List<Object>) lease.get('customFields');

                    for (Object cfObj : customFields) {
                        Map<String, Object> customField = (Map<String, Object>) cfObj;
                        system.debug('customField: '+ customField);
                        String fieldName = String.valueOf(customField.get('fieldName'));
                        Object fieldValue = customField.get('value');

                        if (fieldName == 'Filed to Evict') {
                            leaseRecord.PW_Filed_to_Evict__c = fieldValue != null ? String.valueOf(fieldValue) : null;
                        } else if (fieldName == 'Court Date') {
                            leaseRecord.PW_Court_Date__c = fieldValue != null ? String.valueOf(fieldValue) : null;
                        } else if (fieldName == 'Court Results') {
                            leaseRecord.PW_Court_Results__c = fieldValue != null ? String.valueOf(fieldValue) : null;
                        } else if (fieldName == 'Call Date') {
                            leaseRecord.PW_Call_Date__c = fieldValue != null ? String.valueOf(fieldValue) : null;
                        } else if (fieldName == 'Date Renewed') {
                            leaseRecord.PW_Date_Renewed__c = fieldValue != null ? String.valueOf(fieldValue) : null;
                        } else if (fieldName == 'Owner Wants Inspection?') {
                            leaseRecord.PW_Owner_Wants_Inspection__c = fieldValue != null ? String.valueOf(fieldValue) : null;
                        } else if (fieldName == 'Owner Wants to Renew') {
                            leaseRecord.PW_Owner_Wants_to_Renew__c = fieldValue != null ? String.valueOf(fieldValue) : null;
                        } else if (fieldName == 'Payment Contact Method') {
                            leaseRecord.PW_Payment_Contact_Method__c = fieldValue != null ? String.valueOf(fieldValue) : null;
                        } else if (fieldName == 'Ordered WRIT') {
                            leaseRecord.PW_Ordered_WRIT__c = fieldValue != null ? String.valueOf(fieldValue) : null;
                        } else if (fieldName == 'Put out w/ WRIT') {
                            leaseRecord.PW_Put_out_w_WRIT__c = fieldValue != null ? String.valueOf(fieldValue) : null;
                        } else if (fieldName == 'Reason for Leaving') {
                            leaseRecord.PW_Reason_for_Leaving__c = fieldValue != null ? String.valueOf(fieldValue) : null;
                        } else if (fieldName == 'Promise to Pay Date') {
                            leaseRecord.PW_Promise_to_Pay_Date__c = fieldValue != null ? String.valueOf(fieldValue) : null;
                        } else if (fieldName == 'Market Rent') {
                            leaseRecord.PW_Market_Rent__c = fieldValue != null ? String.valueOf(fieldValue) : null;
                        } else if (fieldName == '% Increase') {
                            leaseRecord.PW_Increase__c = fieldValue != null ? String.valueOf(fieldValue) : null;
                        } else if (fieldName == 'Total Increase') {
                            leaseRecord.PW_Total_Increase__c = fieldValue != null ? String.valueOf(fieldValue) : null;
                        }
                    }
                }
                newLeases.add(leaseRecord);
            }
        }
        
        if(newLeases.size() > 0){
            Database.UpsertResult[] results = Database.upsert(newLeases, false); // allOrNone = false

            for (Integer i = 0; i < results.size(); i++) {
                if (results[i].isSuccess()) {
                    System.debug('Record succeeded: ' + newLeases[i].Id);
                } else {
                    for (Database.Error err : results[i].getErrors()) {
                        System.debug('Error on record ' + i + ': ' + err.getMessage());
                    }
                }
            }
        }
    }
    

    public static Map<string, PW_Building__c> getPWBuildings(Map<String, List<Object>> buildingIdAndLeaseFromPW) {
        Map<string, PW_Building__c> pwBuildingMap = new Map<string, PW_Building__c>();
        for(PW_Building__c building: [
            SELECT Id, 
                Name,   
                PW_Building_Entity_ID1__c, 
                PW_Building_ID__c
                FROM PW_Building__c
                WHERE PW_Building_Entity_ID1__c IN :buildingIdAndLeaseFromPW.keySet()
            ]){
                pwBuildingMap.put(building.PW_Building_Entity_ID1__c, building);
            }
        return pwBuildingMap;
    }

    public static Map<string, PW_Lease__c> getLeases(Map<String, List<Object>> buildingIdAndLeaseFromPW){

        Map<string, PW_Lease__c> pwLeaseMap = new Map<string, PW_Lease__c>();
        for(PW_Lease__c lease: [SELECT Id, Name, PW_Active__c, PW_Lease_Entity_ID__c, 
                                        PW_Building_Entity_ID__c, PW_Portfolio_Entity_ID__c, 
                                        PW_Lease_Status__c, PW_Move_In_Date__c,
                                        PW_Move_Out_Date__c, PW_Notice_Given_Date__c, 
                                        PW_Start_Date__c, PW_End_Date__c, PW_Last_Modified_in_Propertyware__c, 
                                        PW_Create_Date_in_Propertyware__c, PW_Lease_Balance__c, PW_Base_Rent__c 
                                        FROM PW_Lease__c
                                        WHERE PW_Building_Entity_ID__c IN :buildingIdAndLeaseFromPW.keySet()
                                        ]){
                                            // if(pwLeaseMap.containsKey(lease.PW_Building_Entity_ID__c)){
                                                pwLeaseMap.put(lease.PW_Lease_Entity_ID__c, lease);
                                            // }else{  
                                            //     pwLeaseMap.put(lease.PW_Building_Entity_ID__c, new List<PW_Lease__c>());
                                            //     pwLeaseMap.get(lease.PW_Building_Entity_ID__c).add(lease);
                                            // }
                                        }
        return pwLeaseMap;
    }

    public static String formatZuluDateTime(String zuluDateTime) {
        if (String.isBlank(zuluDateTime)) return null;

        try {
            // Handle ISO 8601 by replacing 'T' with a space if present
            if (zuluDateTime.contains('T')) {
                zuluDateTime = zuluDateTime.replace('T', ' ');
            }

            // Parse into GMT DateTime
            DateTime parsedDate = DateTime.valueOfGmt(zuluDateTime);

            // Format to human-readable string
            return parsedDate.format('M/d/yyyy h:mm a');
        } catch (Exception e) {
            System.debug('Invalid datetime string: ' + zuluDateTime);
            return zuluDateTime; // Fallback: return raw string if parsing fails
        }
    }
}