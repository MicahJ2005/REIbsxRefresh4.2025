public with sharing class PropertyWareAPIUtility2 implements Queueable, Database.AllowsCallouts{

    public void execute(QueueableContext ctx) {
        getBuildings();
    }

    public static void getBuildings() {

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

        PW_Portfolio__c defaultPortfolio = [SELECT Id, PW_Portfolio_Entity_ID__c FROM PW_Portfolio__c WHERE Name = 'Default PW Portfolio' LIMIT 1];

        House__c defaultHouse = [ SELECT Id, Name FROM House__c WHERE Name = 'Default House' LIMIT 1];

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        Datetime now = Datetime.now(); // Current datetime
        String toDateTime = now.addHours(Integer.valueOf(PWgetBuildingHoursSpanMTD.IntegerValue__c)).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''); // set by EndFromHoursAgo Custom Metadata
       
        String fromDateTime = now.addHours(Integer.valueOf(PWStartFromHoursAgoMTD.IntegerValue__c)).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''); // set by StartFromHoursAgo Custom Metadata

        string dateTimeParameters = '?lastModifiedDateTimeStart='+ EncodingUtil.urlEncode(fromDateTime, 'UTF-8')+'&lastModifiedDateTimeEnd='+ EncodingUtil.urlEncode(toDateTime, 'UTF-8');
        System.debug(dateTimeParameters);

        request.setEndpoint('https://api.propertyware.com/pw/api/rest/v1/buildings'+ dateTimeParameters+'&includeDeactivated=true&includeCustomFields=true');
        request.setMethod('GET');

        // Set required headers
        request.setHeader('x-propertyware-client-id', PWPPMGCREDS.x_propertyware_client_id__c);
        request.setHeader('x-propertyware-client-secret', PWPPMGCREDS.x_propertyware_client_secret__c);
        request.setHeader('x-propertyware-system-id', PWPPMGCREDS.x_propertyware_system_id__c);

        // Optional common headers
        request.setHeader('Accept', '*/*');
        request.setHeader('Accept-Encoding', 'gzip, deflate, br');
        request.setHeader('Connection', 'keep-alive');

        Map<String, PWBuildingWrapper> PWIdAndAddress = new Map<String, PWBuildingWrapper>();



        try {
            HttpResponse response = http.send(request);
            if(response.getStatusCode() == 200) {
                List<Object> raw = (List<Object>) JSON.deserializeUntyped(response.getBody());
                System.debug(raw);
                for(Object o: raw){
                    Map<String, Object> building = (Map<String, Object>) o;
                    System.debug(building);
                    PWBuildingWrapper bw = new PWBuildingWrapper();
                    for(String key: building.keySet()){
                        Address addressWrapper = new Address();
                        if(key == 'address'){
                            System.debug('Address at 46: ' + building.get(key));
                            Map<String, Object> address = (Map<String, Object>) building.get(key);
                            System.debug(address);
                            
                            bw.address = String.valueOf(address.get('address'));
                            bw.city = String.valueOf(address.get('city'));  
                            bw.country = String.valueOf(address.get('country'));    
                            bw.stateRegion = String.valueOf(address.get('stateRegion'));
                            bw.postalCode = String.valueOf(address.get('postalCode'));
                            
                        }
                        if(key == 'marketing'){
                            System.debug('marketing: ' + building.get(key));
                            Map<String, Object> marketing = (Map<String, Object>) building.get(key);
                            System.debug(marketing);
                            bw.publishedForRent = Boolean.valueOf(marketing.get('publishedForRent'));
                        }
                        if(key == 'customFields'){
                            System.debug('customFields: ' + building.get(key));
                            for(object o2: (List<Object>) building.get(key)){
                                Map<String, Object> temp = (Map<String, Object>) o2;
                                // System.debug('temp: ' + temp);
                                if(temp.get('fieldName') == 'Building Market'){
                                    if(temp.get('value') != '' && temp.get('value') != null){
                                        bw.market = String.valueOf(temp.get('value'));
                                    }
                                }
                                if(temp.get('fieldName') == 'Group HOI DO NOT EDIT'){
                                    if(temp.get('value') != '' && temp.get('value') != null){
                                        bw.groupHOI = String.valueOf(temp.get('value'));
                                    }
                                }
                                if(temp.get('fieldName') == 'Is Owner Selling? notes'){
                                    if(temp.get('value') != '' && temp.get('value') != null){
                                        System.debug('Is Owner Selling? notes: '+String.valueOf(temp.get('value')));
                                        bw.isOwnerSellingNotes = String.valueOf(temp.get('value'));
                                    }
                                }
                                if(temp.get('fieldName') == 'Is Owner Selling?'){
                                    if(temp.get('value') != '' && temp.get('value') != null){
                                        System.debug('Is Owner Selling?: '+String.valueOf(temp.get('value')));
                                        bw.isOwnerSelling = String.valueOf(temp.get('value'));
                                    }
                                }
                                if(temp.get('fieldName') == 'Is Owner Selling? Closing Date'){
                                    if(temp.get('value') != '' && temp.get('value') != null){
                                        System.debug('Is Owner Selling? Closing Date: '+String.valueOf(temp.get('value')));
                                        bw.isOwnerSellingClosingDate = String.valueOf(temp.get('value'));
                                    }
                                }
                            }
                        }
                    }
                    bw.PwCreatedDate = String.valueOf(building.get('createdDateTime'));
                    bw.PwLastModifiedDateTime = String.valueOf(building.get('lastModifiedDateTime'));
                    bw.propertyType = String.valueOf(building.get('type'));
                    bw.buildingEntityId = String.valueOf(building.get('id'));
                    bw.buildingIdNumber  = String.valueOf(building.get('idNumber'));
                    bw.portfolioID  = String.valueOf(building.get('portfolioID'));
                    bw.name = String.valueOf(building.get('name'));
                    bw.status = String.valueOf(building.get('status'));
                    bw.active = Boolean.valueOf(building.get('active'));
                    bw.yearBuilt  = String.valueOf(building.get('yearBuilt'));
                    bw.numberOfBedrooms  = Integer.valueOf(building.get('numberOfBedrooms'));
                    bw.numberOfBathrooms  = Double.valueOf(building.get('numberOfBathrooms'));
                    bw.totalArea = Double.valueOf(building.get('totalArea'));
                    
                    String fullAddress = bw.address + ', ' + bw.city + ', ' + bw.stateRegion + ' ' + bw.postalCode;
                    String placeId = GooglePlacesService.getPlaceIdFromAddress(fullAddress);
                    system.debug('placeId'+ placeId);
                    bw.googlePlaceId = placeId;

                    System.debug('id: '+ building.get('id'));
                    System.debug('idNumber: '+ building.get('idNumber'));
                    PWIdAndAddress.put(bw.buildingEntityId , bw);
                }

            }
        } catch (Exception e) {
            System.debug('Callout error: ' + e.getMessage());
        }

        System.debug('PWIdAndAddress: '+ PWIdAndAddress);

        ///Get Portfolios
        Map<String, PW_Portfolio__c> currentSFPWPortfolioMap = getCurrentPortfolios(PWIdAndAddress, PWPPMGCREDS);
        System.debug('currentSFPWPortfolioMap: '+ currentSFPWPortfolioMap);
        List<Database.UpsertResult> resultsPortfolio = Database.upsert(currentSFPWPortfolioMap.values(), false);

        set<string> upsertedPortfolioIds = new Set<string>();
         Map<String, PW_Portfolio__c> mapOfUpsertPortfoliosToPass = new  Map<String, PW_Portfolio__c>();
        // Now you can get the Ids
        for (Integer i = 0; i < resultsPortfolio.size(); i++) {
            if (resultsPortfolio[i].isSuccess()) {
                System.debug('Record was upserted with Id: ' + resultsPortfolio[i].getId());
                upsertedPortfolioIds.add(resultsPortfolio[i].getId());
            } else {
                // Handle errors
                for (Database.Error err : resultsPortfolio[i].getErrors()) {
                    System.debug('Error: ' + err.getMessage());
                }
            }
        }

         for(PW_Portfolio__c pw: [SELECT Id, Name, PW_Portfolio_Entity_ID__c, PW_Active__c, Investor_Owner__c
                                    FROM PW_Portfolio__c 
                                    WHERE Id IN: upsertedPortfolioIds ]){

             mapOfUpsertPortfoliosToPass.put(pw.PW_Portfolio_Entity_ID__c, pw);
         }

         //Get Houses
         Map<String, House__c> currentSFgooglePlaceIdToPWHouseMap = getCurrentHouses(PWIdAndAddress);
         System.debug('currentSFgooglePlaceIdToPWHouseMap: '+ currentSFgooglePlaceIdToPWHouseMap);
         
         List<Database.UpsertResult> resultsHouse = Database.upsert(currentSFgooglePlaceIdToPWHouseMap.values(), false);

         set<string> upsertedHouseIds = new Set<string>();
         Map<String, House__c> mapOfUpsertHousesToPass = new  Map<String, House__c>();
        // Now you can get the Ids
        for (Integer i = 0; i < resultsHouse.size(); i++) {
            if (resultsHouse[i].isSuccess()) {
                System.debug('Record was upserted with Id: ' + resultsHouse[i].getId());
                upsertedHouseIds.add(resultsHouse[i].getId());
            } else {
                // Handle errors
                for (Database.Error err : resultsHouse[i].getErrors()) {
                    System.debug('Error: ' + err.getMessage());
                }
            }
        }

        for(House__c h: [SELECT 
                                    Id,
                                    Name,
                                    Street_Address__c,
                                    City__c,
                                    State__c,
                                    Zip_Code__c,
                                    House_Type__c,
                                    Bedrooms__c,
                                    Bathrooms__c,
                                    Sq_Feet__c,
                                    Status__c,
                                    Google_Place_ID__c
                                FROM 
                                    House__c 
                                WHERE 
                                     Id IN :upsertedHouseIds]){
                                          
                                        mapOfUpsertHousesToPass.put(h.Google_Place_ID__c, h);
                                     }

        //Get Buildings
        List<Map<String, PW_Building__c>> currentSFPWBuildingMap = getCurrentPWBuildings(PWIdAndAddress, defaultPortfolio.Id, defaultHouse.Id, mapOfUpsertPortfoliosToPass, mapOfUpsertHousesToPass);


        
        System.debug('currentSFPWBuildingMap List 1: '+ currentSFPWBuildingMap[0]);
        System.debug('currentSFPWBuildingMap List 2: '+ currentSFPWBuildingMap[1]);

        List<PW_Building__c> buildingsToUpsert = new List<PW_Building__c>();

        for (Map<String, PW_Building__c> buildingMap : currentSFPWBuildingMap) {
            for (PW_Building__c building : buildingMap.values()) {
                buildingsToUpsert.add(building);
            }
        }
        system.debug('PropertyWareAPIUtility2 buildingsToUpsert.size(): '+buildingsToUpsert.size());
        List<Database.UpsertResult> resultsBuildings = Database.upsert(buildingsToUpsert, false);

    }
    
    public static List<Map<String, PW_Building__c>> getCurrentPWBuildings(Map<String, PWBuildingWrapper> buildings, 
                                                                            Id defaultPorfolioId, 
                                                                            Id defaultHouseId, 
                                                                            Map<String, PW_Portfolio__c> currentSFPWPortfolioMap,
                                                                            Map<String, House__c> currentSFgooglePlaceIdToPWHouseMap) {
        List<Map<String, PW_Building__c>> AllBuildingReturn = new List<Map<String, PW_Building__c>>();

        List<PW_Building__c> pwBuildingsToSync = [SELECT Id , Name, PW_Building_ID__c, PW_Building_Entity_ID1__c, Google_Place_ID__c, PW_Zip__c, PW_State__c, PW_City__c, PW_Address__c FROM PW_Building__c WHERE PW_Building_Entity_ID1__c IN :buildings.keySet()];
        System.debug('pwBuildingsToSync' +pwBuildingsToSync);

        ///map current buildings
        Map<String, PW_Building__c> currentBuildingMap = new Map<String, PW_Building__c>();
        for(PW_Building__c pwBuilding : pwBuildingsToSync){
            string houseId = defaultHouseId;
            string portfolioId = defaultPorfolioId;
            string investorOwnerId = null;
            
            System.debug('googleId from currentSFgooglePlaceIdToPWHouseMap: '+currentSFgooglePlaceIdToPWHouseMap.get(buildings.get(pwBuilding.PW_Building_Entity_ID1__c).googlePlaceID));
            System.debug('Building from currentSFPWPortfolioMap: '+currentSFPWPortfolioMap.get(buildings.get(pwBuilding.PW_Building_Entity_ID1__c).portfolioID));
            if(currentSFgooglePlaceIdToPWHouseMap.containsKey(buildings.get(pwBuilding.PW_Building_Entity_ID1__c).googlePlaceID)) {
                houseId = currentSFgooglePlaceIdToPWHouseMap.get(buildings.get(pwBuilding.PW_Building_Entity_ID1__c).googlePlaceID).Id;
            }
            if(currentSFPWPortfolioMap.containsKey(buildings.get(pwBuilding.PW_Building_Entity_ID1__c).portfolioID)) {
                portfolioId = currentSFPWPortfolioMap.get(buildings.get(pwBuilding.PW_Building_Entity_ID1__c).portfolioID).Id;
                investorOwnerId = currentSFPWPortfolioMap.get(buildings.get(pwBuilding.PW_Building_Entity_ID1__c).portfolioID).Investor_Owner__c;
            }

            string formattedPWCreatedDate = '';
            if(buildings.get(pwBuilding.PW_Building_Entity_ID1__c).PwCreatedDate != null){
                try{
                    string zuluCreateDate = buildings.get(pwBuilding.PW_Building_Entity_ID1__c).PwCreatedDate;
                    if(zuluCreateDate.contains('T')) {
                        zuluCreateDate = zuluCreateDate.replace('T',' ');
                    }
                    DateTime transformedPWCreatedDate = DateTime.valueOfGmt(zuluCreateDate);
                    formattedPWCreatedDate = transformedPWCreatedDate.format('M/d/yyyy h:mm a');
                } catch (Exception e) {
                    System.debug('Invalid datetime string: ' + buildings.get(pwBuilding.PW_Building_Entity_ID1__c).PwCreatedDate);
                    // Optionally set a fallback
                    formattedPWCreatedDate = buildings.get(pwBuilding.PW_Building_Entity_ID1__c).PwCreatedDate;
                }
            }

            string formattedPWLastModifiedDate = '';
            if(buildings.get(pwBuilding.PW_Building_Entity_ID1__c).PwLastModifiedDateTime != null){
                try{
                    string zuluLastModified = buildings.get(pwBuilding.PW_Building_Entity_ID1__c).PwLastModifiedDateTime;
                    if(zuluLastModified.contains('T')) {
                        zuluLastModified = zuluLastModified.replace('T',' ');
                    }
                    DateTime transformedPWLastModifiedDate = DateTime.valueOfGmt(zuluLastModified);
                    formattedPWLastModifiedDate = transformedPWLastModifiedDate.format('M/d/yyyy h:mm a');
                }  catch (Exception e) {
                    System.debug('Invalid datetime string: ' + buildings.get(pwBuilding.PW_Building_Entity_ID1__c).PwLastModifiedDateTime);
                    // Optionally set a fallback
                    formattedPWLastModifiedDate = buildings.get(pwBuilding.PW_Building_Entity_ID1__c).PwLastModifiedDateTime;
                }
            }

            pwBuilding.Name = buildings.get(pwBuilding.PW_Building_Entity_ID1__c).name;
            pwBuilding.PW_Status__c = buildings.get(pwBuilding.PW_Building_Entity_ID1__c).status;
            pwBuilding.PW_Active__c = buildings.get(pwBuilding.PW_Building_Entity_ID1__c).active;
            pwBuilding.House__c = houseId;
            pwBuilding.PW_Portfolio__c = portfolioId;
            pwBuilding.Investor_Owner_Account__c = investorOwnerId;
            pwBuilding.PW_Building_Market__c = buildings.get(pwBuilding.PW_Building_Entity_ID1__c).market;
            pwBuilding.PW_Address__c = buildings.get(pwBuilding.PW_Building_Entity_ID1__c).address;
            pwBuilding.PW_City__c = buildings.get(pwBuilding.PW_Building_Entity_ID1__c).city;
            pwBuilding.PW_State__c = buildings.get(pwBuilding.PW_Building_Entity_ID1__c).stateRegion;
            pwBuilding.PW_Zip__c = buildings.get(pwBuilding.PW_Building_Entity_ID1__c).postalCode;
            pwBuilding.PW_Year_Built1__c = String.valueOf(buildings.get(pwBuilding.PW_Building_Entity_ID1__c).yearBuilt);
            pwBuilding.PW_Bedrooms__c = buildings.get(pwBuilding.PW_Building_Entity_ID1__c).numberOfBedrooms;
            pwBuilding.PW_Bathroos__c = buildings.get(pwBuilding.PW_Building_Entity_ID1__c).numberOfBathrooms;
            pwBuilding.PW_Building_Entity_ID1__c = pwBuilding.PW_Building_Entity_ID1__c;
            pwBuilding.PW_Portfolio_Entity_ID1__c = String.valueOf(buildings.get(pwBuilding.PW_Building_Entity_ID1__c).portfolioID);
            pwBuilding.PW_Building_ID__c = String.valueOf(buildings.get(pwBuilding.PW_Building_Entity_ID1__c).buildingIdNumber);
            pwBuilding.PW_Created_Date_in_Propetyware__c = formattedPWCreatedDate;
            pwBuilding.PW_Last_Modified_in_Propertyware__c = formattedPWLastModifiedDate;
            pwBuilding.PW_Total_Area__c = buildings.get(pwBuilding.PW_Building_Entity_ID1__c).totalArea;
            pwBuilding.Published_For_Rent__c = buildings.get(pwBuilding.PW_Building_Entity_ID1__c).publishedForRent;
            pwBuilding.Group_HOI__c = buildings.get(pwBuilding.PW_Building_Entity_ID1__c).groupHOI;
            pwBuilding.Google_Place_ID__c = String.valueOf(buildings.get(pwBuilding.PW_Building_Entity_ID1__c).googlePlaceId);
            pwBuilding.Is_Owner_Selling_Notes__c = buildings.get(pwBuilding.PW_Building_Entity_ID1__c).isOwnerSellingNotes;
            pwBuilding.Is_Owner_Selling__c = buildings.get(pwBuilding.PW_Building_Entity_ID1__c).isOwnerSelling;
            pwBuilding.Is_Owner_Selling_Closing_Date__c = buildings.get(pwBuilding.PW_Building_Entity_ID1__c).isOwnerSellingClosingDate;


            // pwBuilding.PW_Status__c = buildings.get(pwBuilding.PW_Building_Entity_ID1__c).status;
            pwBuilding.PW_Last_Modified_in_Propertyware__c = formattedPWLastModifiedDate;
            currentBuildingMap.put(pwBuilding.PW_Building_Entity_ID1__c, pwBuilding);
        }

        Map<String, PW_Building__c> noBuildingsToMap = new Map<String, PW_Building__c>();
        for(string buildingId: buildings.keySet()){
            if(!currentBuildingMap.containsKey(buildingId)){
                string houseId = defaultHouseId;
                string portfolioId = defaultPorfolioId;
                string InvestorOwnerId = null;

                System.debug('googleId from currentSFgooglePlaceIdToPWHouseMap: '+currentSFgooglePlaceIdToPWHouseMap.get(buildings.get(buildingId).googlePlaceID));
                System.debug('Building from currentSFPWPortfolioMap: '+currentSFPWPortfolioMap.get(buildings.get(buildingId).portfolioID));
                if(currentSFgooglePlaceIdToPWHouseMap.containsKey(buildings.get(buildingId).googlePlaceID)) {
                    houseId = currentSFgooglePlaceIdToPWHouseMap.get(buildings.get(buildingId).googlePlaceID).Id;
                }
                if(currentSFPWPortfolioMap.containsKey(buildings.get(buildingId).portfolioID)) {
                    portfolioId = currentSFPWPortfolioMap.get(buildings.get(buildingId).portfolioID).Id;
                    investorOwnerId = currentSFPWPortfolioMap.get(buildings.get(buildingId).portfolioID).Investor_Owner__c;
                }
                string formattedPWCreatedDate = '';
                if(buildings.get(buildingId).PwCreatedDate != null){
                    try{
                        string zuluCreateDate = buildings.get(buildingId).PwCreatedDate;
                        if(zuluCreateDate.contains('T')) {
                            zuluCreateDate = zuluCreateDate.replace('T',' ');
                        }
                        DateTime transformedPWCreatedDate = DateTime.valueOfGmt(zuluCreateDate);
                        formattedPWCreatedDate = transformedPWCreatedDate.format('M/d/yyyy h:mm a');
                    } catch (Exception e) {
                        System.debug('Invalid datetime string: ' + buildings.get(buildingId).PwCreatedDate);
                        // Optionally set a fallback
                        formattedPWCreatedDate = buildings.get(buildingId).PwCreatedDate;
                    }
                }
                string formattedPWLastModifiedDate = '';
                if(buildings.get(buildingId).PwLastModifiedDateTime != null){
                    try{
                        string zuluLastModified = buildings.get(buildingId).PwLastModifiedDateTime;
                        if(zuluLastModified.contains('T')) {
                            zuluLastModified = zuluLastModified.replace('T',' ');
                        }
                        DateTime transformedPWLastModifiedDate = DateTime.valueOfGmt(zuluLastModified);
                        formattedPWLastModifiedDate = transformedPWLastModifiedDate.format('M/d/yyyy h:mm a');
                    }  catch (Exception e) {
                        System.debug('Invalid datetime string: ' + buildings.get(buildingId).PwLastModifiedDateTime);
                        // Optionally set a fallback
                        formattedPWLastModifiedDate = buildings.get(buildingId).PwLastModifiedDateTime;
                    }
                }

                System.debug( 'GOOGLE PLACE ID HERE: '+ String.valueOf(buildings.get(buildingId).googlePlaceId));
                PW_Building__c newBuilding = new PW_Building__c(
                        Name = buildings.get(buildingId).name,
                        PW_Status__c = buildings.get(buildingId).status,
                        PW_Active__c = buildings.get(buildingId).active,
                        House__c = houseId,
                        PW_Portfolio__c = portfolioId,
                        Investor_Owner_Account__c = investorOwnerId,
                        PW_Building_Market__c = buildings.get(buildingId).market,
                        PW_Address__c = buildings.get(buildingId).address,
                        PW_City__c = buildings.get(buildingId).city,
                        PW_State__c = buildings.get(buildingId).stateRegion,
                        PW_Zip__c = buildings.get(buildingId).postalCode,
                        PW_Year_Built1__c = String.valueOf(buildings.get(buildingId).yearBuilt),
                        PW_Bedrooms__c = buildings.get(buildingId).numberOfBedrooms,
                        PW_Bathroos__c = buildings.get(buildingId).numberOfBathrooms,
                        PW_Building_Entity_ID1__c = buildingId,
                        PW_Portfolio_Entity_ID1__c = String.valueOf(buildings.get(buildingId).portfolioID),
                        PW_Building_ID__c = String.valueOf(buildings.get(buildingId).buildingIdNumber),
                        PW_Created_Date_in_Propetyware__c = formattedPWCreatedDate,
                        PW_Last_Modified_in_Propertyware__c = formattedPWLastModifiedDate,
                        PW_Total_Area__c = buildings.get(buildingId).totalArea,
                        Published_For_Rent__c = buildings.get(buildingId).publishedForRent,
                        Group_HOI__c = buildings.get(buildingId).groupHOI,
                        Google_Place_ID__c = String.valueOf(buildings.get(buildingId).googlePlaceId),
                        Is_Owner_Selling_Notes__c = buildings.get(buildingId).isOwnerSellingNotes,
                        Is_Owner_Selling__c = buildings.get(buildingId).isOwnerSelling,
                        Is_Owner_Selling_Closing_Date__c = buildings.get(buildingId).isOwnerSellingClosingDate
                    );
                    noBuildingsToMap.put(buildingId, newBuilding);
            }
        
        }

        AllBuildingReturn.add(currentBuildingMap);
        AllBuildingReturn.add(noBuildingsToMap);

        return AllBuildingReturn;
    }

    public static Map<String, House__c> getCurrentHouses(Map<String, PWBuildingWrapper> buildings) {

        set<String> googleIdSet = new set<string>();
        for(string id: buildings.keySet()){
            googleIdSet.add(buildings.get(id).googlePlaceId);
        }

        List<House__c> pwBuildingsToSync = [SELECT Id , Name, PW_ID_Number__c, Google_Place_ID__c FROM House__c WHERE Google_Place_ID__c IN :googleIdSet];
        System.debug('pwBuildingsToSync' +pwBuildingsToSync);

        ///map current buildings
        Map<String, House__c> currentBuildingMap = new Map<String, House__c>();
        for(House__c pwBuilding : pwBuildingsToSync){
            currentBuildingMap.put(pwBuilding.Google_Place_ID__c, pwBuilding);
        }

        for(string buildingId: buildings.keySet()){
            if(!currentBuildingMap.containsKey(buildings.get(buildingId).googlePlaceId)){
                system.debug('buildingId'+ buildingId + ' number of bedrooms'+buildings.get(buildingId).numberOfBedrooms);
                string bathrooms = String.valueOf(buildings.get(buildingId).numberOfBathrooms);
                string bathroomTrimmed;
                switch on bathrooms {
                    when '1.0' {
                        bathroomTrimmed = '1';
                    }
                    when '2.0' {
                        bathroomTrimmed = '2';
                    }
                    when '3.0' {
                        bathroomTrimmed = '3';
                    }
                    when '4.0' {
                        bathroomTrimmed = '4';
                    }
                    when '5.0' {
                        bathroomTrimmed = '5';
                    }
                    when '6.0' {
                        bathroomTrimmed = '6';
                    }
                    when '7.0' {
                        bathroomTrimmed = '7';
                    }
                    when else {
                        bathroomTrimmed = '0';
                    }
                }
                
                // String fullAddress = buildings.get(buildingId).address + ', ' + buildings.get(buildingId).city + ', ' + buildings.get(buildingId).stateRegion + ' ' + buildings.get(buildingId).postalCode;
                // String placeId = GooglePlacesService.getPlaceIdFromAddress(fullAddress);

                House__c house = new House__c(
                    Market__c = buildings.get(buildingId).market,
                    Name = buildings.get(buildingId).name,
                    Street_Address__c = buildings.get(buildingId).address,
                    City__c = buildings.get(buildingId).city,
                    State__c = buildings.get(buildingId).stateRegion,
                    Zip_Code__c = buildings.get(buildingId).postalCode,
                    // House_Type__c = buildings.get(buildingId).PropertyType,
                    Bedrooms__c = String.valueOf(buildings.get(buildingId).numberOfBedrooms),
                    Bathrooms__c = String.valueOf(bathroomTrimmed),
                    // Car_Storage__c = null, // Set as needed
                    Sq_Feet__c = buildings.get(buildingId).TotalArea,
                    // Year_Built__c = buildings.get(buildingId).YearBuilt,
                    Status__c = 'Managed',
                    Google_Place_ID__c = ''
                );
                // Conditionally set Year_Built__c
                if (buildings.get(buildingId).YearBuilt != null) {
                    house.Year_Built__c = String.valueOf(buildings.get(buildingId).YearBuilt);
                }
                currentBuildingMap.put(buildings.get(buildingId).googlePlaceId, house);
            }
       
        }
        return currentBuildingMap;
    }

    private static Map<String, PW_Portfolio__c> getCurrentPortfolios(Map<String, PWBuildingWrapper> buildings, PropertyWare_Setting__mdt PWPPMGCREDS) {
        system.debug('building getOrCreatePortfolio'+ buildings);
        Set<String> protfolioIdSet = new Set<String>();
        for(string id: buildings.keySet()){
            protfolioIdSet.add(String.valueOf(buildings.get(id).portfolioID));
        }

        Map<String, PW_Portfolio__c> portfolioMap = new Map<String, PW_Portfolio__c>();
        for(PW_Portfolio__c p: [SELECT Id, PW_Portfolio_Entity_ID__c, Investor_Owner__c FROM PW_Portfolio__c WHERE PW_Portfolio_Entity_ID__c IN: protfolioIdSet]){
            portfolioMap.put(p.PW_Portfolio_Entity_ID__c, p);
        }
        for(string buildingId: buildings.keySet()){
            if(!portfolioMap.containsKey(buildings.get(buildingId).portfolioID)){

                PW_Portfolio__c newPortfolio = getPortfolioInPW(buildings.get(buildingId).portfolioID, PWPPMGCREDS);
                portfolioMap.put(newPortfolio.PW_Portfolio_Entity_ID__c, newPortfolio);
            }
       
        }
        
        return portfolioMap;
    }

    public static PW_Portfolio__c getPortfolioInPW(string portfolioId, PropertyWare_Setting__mdt PWPPMGCREDS) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        request.setEndpoint('https://api.propertyware.com/pw/api/rest/v1/portfolios/'+ portfolioId);
        request.setMethod('GET');

        // Set required headers
        request.setHeader('x-propertyware-client-id', PWPPMGCREDS.x_propertyware_client_id__c);
        request.setHeader('x-propertyware-client-secret', PWPPMGCREDS.x_propertyware_client_secret__c);
        request.setHeader('x-propertyware-system-id', PWPPMGCREDS.x_propertyware_system_id__c);

        // Optional common headers
        request.setHeader('Accept', '*/*');
        request.setHeader('Accept-Encoding', 'gzip, deflate, br');
        request.setHeader('Connection', 'keep-alive');


        PW_Portfolio__c newPortfolio = new PW_Portfolio__c();

        try {
            HttpResponse response = http.send(request);
            if(response.getStatusCode() == 200) {
                Object raw = (Object) JSON.deserializeUntyped(response.getBody());
                System.debug('Portfolio: '+raw);
                
                // for(Object o: raw){
                    Map<String, Object> Portfolio = (Map<String, Object>) raw;
                    newPortfolio.Name = String.valueOf(Portfolio.get('name'));
                    newPortfolio.PW_Portfolio_Entity_ID__c = String.valueOf(Portfolio.get('id'));
                    newPortfolio.PW_Active__c = Boolean.valueOf(Portfolio.get('active'));
                    newPortfolio.PW_Org__c = 'PPMG of Texas, LLC';
                // }
            }
        } catch (Exception e) {
            System.debug('Callout error: ' + e.getMessage());
        }
        
        return newPortfolio;
    }


    public class PWBuildingWrapper {
        public Boolean publishedForRent;
        public String buildingEntityId;
        public String address;
        public String PwCreatedDate;
        public String PwLastModifiedDateTime;
        public String groupHOI;
        // public String addressCont;
        public String city;
        public String stateRegion;
        public String postalCode;
        public String country;
        public String googlePlaceId;
        // public String lastModifiedBy;
        // public Datetime lastModifiedDateTime;
        // public String createdBy;
        // public Datetime createdDateTime;
        public String buildingIdNumber;
        public String portfolioID;
        // public Integer leaseID;
        public String name;
        // public String abbreviation;
        // public Address address;
        public String propertyType;
        // public String category;
        // public Integer floorNumber;
        // public Integer numberFloors;
        // public String neighborhood;
        public Double totalArea;
        // public String areaUnits;
        // public String county;
        // public Boolean ready;
        public Boolean active;
        // public Boolean rentable;
        public Integer numberOfBedrooms;
        public Double numberOfBathrooms;
        // public Double targetRent;
        // public String targetRentUnits;
        // public String searchTag;
        // public String targetDeposit;
        public String status;
        // public String maintenanceNotice;
        // public List<String> amenities;
        // public String maintenanceSpendingLimitTime;
        // public Boolean syndicate;
        // public String website;
        public String yearBuilt;
        public String market;
        public string isOwnerSellingNotes;
        public String isOwnerSellingClosingDate;
        public string isOwnerSelling;
        // public Marketing marketing;
        // public List<PropertyManager> propertyManagerList;
        // public Management management;
        // public String multiUnit;
        // public Integer countUnit;
        // public String propertyType;
        // public Double maintenanceLaborSurchargeAmount;
        // public String maintenanceLaborSurchargeType;
        // public String ftbWithholdingType;
        // public Double ftbWithholdingPercentage;
        // public Double ftbDeductable;
        // public Double maintenanceSpendingLimitAmount;
        // public String reasonForPropertyLost;
        // public String applicationFeeRule;
    }
    public class Address {
        public String address;
        // public String addressCont;
        public String city;
        public String stateRegion;
        public String postalCode;
        public String country;
    }

    // public class Marketing {
    //     public String marketingName;
    //     public String availableDate;
    //     public String comments;
    //     public Boolean featured;
    //     public Boolean featuredForRent;
    //     public Boolean forSale;
    //     public Boolean publishedForSale;
    //     public Boolean featuredForSale;
    //     public String mlsLeaseNumber;
    //     public String mlsNumber;
    //     public String otherTenantCharges;
    //     public String parcelNumber;
    //     public Boolean petsAllowed;
    //     public String postingTitle;
    //     public Integer leaseTerms;
    //     public String leaseTermsUnits;
    //     public Double latitude;
    //     public Double longitude;
    //     public Double salePrice;
    //     public String saleTerms;
    //     public String shortDescription;
    //     public Boolean smokingAllowed;
    //     public String specials;
    //     public Boolean publishedForRent;
    //     public Boolean syndicate;
    //     public Integer moveInDays;
    // }

    // public class PropertyManager {
    //     public String id;
    //     public String roleAsString;
    //     public String userID;
    //     public String name;
    //     public String email;
    // }

    // public class Management {
    //     public String managementContractStartDate;
    //     public String managementContractEndDate;
    //     public Double managementFlatFee;
    //     public String managementFeeType;
    //     public String managementFeesType;
    //     public List<ManagementFee> managementFees;
    // }

    // public class ManagementFee {
    //     // public Long id;
    //     public Double percentage;
    //     public Boolean passThrough;
    //     public Double managersCommissionPercentage;
    //     public String manager;
    //     public String accountNumber;
    //     public String accountCode;
    // }

    public class CustomFieldWrapper {
        public List<CustomField> customFields;
    }
    
    public class CustomField {
        public String dataType;
        public Long definitionID;
        public String fieldName;
        public Object value;
    }
}