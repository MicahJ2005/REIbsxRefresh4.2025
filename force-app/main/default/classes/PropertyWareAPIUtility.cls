public with sharing class PropertyWareAPIUtility implements Schedulable, Database.AllowsCallouts{

    public void execute(SchedulableContext ctx) {
        getBuildings();
    }

    public static void getBuildings() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        Datetime now = Datetime.now(); // Current datetime
        // String toDateTime = now.addHours(-1).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''); // 1 hour ago
        String fromDateTime = now.addHours(-2).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''); // 24 hours ago

        string dateTimeParameters = '?lastModifiedDateTimeStart='+ EncodingUtil.urlEncode(fromDateTime, 'UTF-8');
        System.debug(dateTimeParameters);

        request.setEndpoint('https://api.propertyware.com/pw/api/rest/v1/buildings'+ dateTimeParameters);
        request.setMethod('GET');

        // Set required headers
        request.setHeader('x-propertyware-client-id', '5654c21f-3490-49bb-9521-251b7e8d547c');
        request.setHeader('x-propertyware-client-secret', '57bb14b8-3659-4cc8-8f4e-dd778a7b3a66');
        request.setHeader('x-propertyware-system-id', '20348933');

        // Optional common headers
        request.setHeader('Accept', '*/*');
        request.setHeader('Accept-Encoding', 'gzip, deflate, br');
        request.setHeader('Connection', 'keep-alive');

        Map<String, PWBuildingWrapper> PWIdAndAddress = new Map<String, PWBuildingWrapper>();



        try {
            HttpResponse response = http.send(request);
            if(response.getStatusCode() == 200) {
                // System.debug('Response body: ' + response.getBody());
                List<Object> raw = (List<Object>) JSON.deserializeUntyped(response.getBody());
                System.debug(raw);
                for(Object o: raw){
                    Map<String, Object> building = (Map<String, Object>) o;
                    System.debug(building);
                    PWBuildingWrapper bw = new PWBuildingWrapper();
                    for(String key: building.keySet()){
                        Address addressWrapper = new Address();
                        // System.debug(key + ': ' + building.get(key));
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
                    }
                    bw.buildingEntityId = String.valueOf(building.get('id'));
                    bw.buildingIdNumber  = String.valueOf(building.get('idNumber'));
                    bw.portfolioID  = String.valueOf(building.get('portfolioID'));
                    bw.name = String.valueOf(building.get('name'));
                    bw.status = String.valueOf(building.get('status'));
                    bw.active = Boolean.valueOf(building.get('active'));
                    bw.yearBuilt  = String.valueOf(building.get('yearBuilt'));
                    bw.numberOfBedrooms  = Integer.valueOf(building.get('numberOfBedrooms'));
                    bw.numberOfBathrooms  = Double.valueOf(building.get('numberOfBathrooms'));
                    
                    System.debug('id: '+ building.get('id'));
                    System.debug('idNumber: '+ building.get('idNumber'));
                    PWIdAndAddress.put(bw.buildingEntityId , bw);
                }
                // List<PWBuildingWrapper> PWBuildings = (List<PWBuildingWrapper>) JSON.deserialize(response.getBody(), List<PWBuildingWrapper>.class);
                // System.debug(PWBuildings);
                // syncBuildingsFromPW(PWBuildings);
                // List<Object> buildings = (List<Object>) responseMap.get('buildings');

                // System.debug(buildings);

            }
        } catch (Exception e) {
            System.debug('Callout error: ' + e.getMessage());
        }



        System.debug('PWIdAndAddress: '+ PWIdAndAddress);
        map<string, PW_Building__c> currentFSPWBuildingMap = getCurrentPRBuildings(PWIdAndAddress);
        // map<string, House__c> currentFSPWHouseMap = getCurrentHouses(PWIdAndAddress);
        map<string, PW_Portfolio__c> pwIdToSFPortfolio = new map<string, PW_Portfolio__c>();
        List<PW_Building__c> buildingsToUpsert = syncBuildingsFromPW(PWIdAndAddress);
        system.debug('buildingsToUpsert: '+buildingsToUpsert);
        if(buildingsToUpsert.size() > 0){
            insert buildingsToUpsert;
        }
        // getPWBuildingByPWId(PWIdAndAddress);
    }
    
    // public static void getPWBuildingByPWId(Map<String, PWBuildingWrapper> PWIdAndAddress){
    //     System.debug('PWIdAndAddress: '+ PWIdAndAddress);
    //     ////Need to Select buildings by PW Id
    // }
    public static Map<String, PW_Building__c> getCurrentPRBuildings(Map<String, PWBuildingWrapper> buildings) {
        List<PW_Building__c> pwBuildingsToSync = [SELECT Id , Name, PW_Building_ID__c FROM PW_Building__c WHERE PW_Building_Entity_ID1__c IN :buildings.keySet()];
        // List<PW_Building__c> pwBuildingsToSync = [SELECT Id , Name, PW_Building_ID__c, PW_Building_Entity_ID1__c FROM PW_Building__c WHERE PW_Building_Entity_ID1__c = '253001846'];
        System.debug('pwBuildingsToSync' +pwBuildingsToSync);

        ///map current buildings
        Map<String, PW_Building__c> currentBuildingMap = new Map<String, PW_Building__c>();
        for(PW_Building__c pwBuilding : pwBuildingsToSync){
            currentBuildingMap.put(pwBuilding.PW_Building_ID__c, pwBuilding);
        }

        return currentBuildingMap;
    }

    // public static Map<String, House__c> getCurrentHouses(Map<String, PWBuildingWrapper> buildings) {

    //     List<PW_Building__c> pwBuildingsToSync = [SELECT Id , Name, PW_Building_ID__c FROM PW_Building__c WHERE PW_Building_Entity_ID1__c IN :buildings.keySet()];
    //     // List<PW_Building__c> pwBuildingsToSync = [SELECT Id , Name, PW_Building_ID__c, PW_Building_Entity_ID1__c FROM PW_Building__c WHERE PW_Building_Entity_ID1__c = '253001846'];
    //     System.debug('pwBuildingsToSync' +pwBuildingsToSync);

    //     ///map current buildings
    //     Map<String, PW_Building__c> currentBuildingMap = new Map<String, PW_Building__c>();
    //     for(PW_Building__c pwBuilding : pwBuildingsToSync){
    //         currentBuildingMap.put(pwBuilding.PW_Building_ID__c, pwBuilding);
    //     }

    //     return currentBuildingMap;
    // }

    public static List<PW_Building__c> syncBuildingsFromPW(Map<String, PWBuildingWrapper> buildings) {
        system.debug('buildings syncBuildingsFromPW:'+ buildings);
        List<PW_Building__c> buildingsToReturn = new List<PW_Building__c>();

        List<PW_Building__c> pwBuildingsToSync = [SELECT Id , Name, PW_Building_ID__c FROM PW_Building__c WHERE PW_Building_Entity_ID1__c IN :buildings.keySet()];
        // List<PW_Building__c> pwBuildingsToSync = [SELECT Id , Name, PW_Building_ID__c, PW_Building_Entity_ID1__c FROM PW_Building__c WHERE PW_Building_Entity_ID1__c = '253001846'];
        System.debug('pwBuildingsToSync' +pwBuildingsToSync);

        ///map current buildings
        Map<String, PW_Building__c> currentBuildingMap = new Map<String, PW_Building__c>();
        for(PW_Building__c pwBuilding : pwBuildingsToSync){
            currentBuildingMap.put(pwBuilding.PW_Building_ID__c, pwBuilding);
        }
        
        ///map new buildings
        // Map<String, PWBuildingWrapper> newBuildingMap = new Map<String, PWBuildingWrapper>();
        // for(String buildingId : buildings.keySet()){
        //     if(!buildingMap.containsKey(buildingId)){
        //         newBuildingMap.put(buildingId, buildings.get(buildingId));
        //     }
        // }



        for (String buildingId : buildings.keySet()) {
            system.debug('buildingId:'+ buildingId);
            System.debug(buildings.get(buildingId));
            // Step 1: Ensure Portfolio Exists or Create It
            PW_Portfolio__c portfolio = getOrCreatePortfolio(buildings.get(buildingId));
            system.debug('portfolio'+ portfolio);

            // Step 2: Ensure House Exists or Create It
            House__c house = getOrCreateHouse(buildings.get(buildingId));
            system.debug('house'+ house);

            // // Step 3: Check if PW Building exists
            if(buildingId != null){
                PW_Building__c existingBuilding = getBuildingByEntityId(buildingId);
                system.debug('existingBuilding: '+ existingBuilding + 'with Building Id: '+ buildingId);
                if (existingBuilding == null) {
                    PW_Building__c newBuilding = new PW_Building__c(
                        Name = buildings.get(buildingId).name,
                        PW_Status__c = buildings.get(buildingId).status,
                        PW_Active__c = buildings.get(buildingId).active,
                        House__c = house.Id,
                        PW_Portfolio__c = portfolio.Id,
                        PW_Building_Market__c = '',
                        PW_Address__c = buildings.get(buildingId).address,
                        PW_City__c = buildings.get(buildingId).city,
                        PW_State__c = buildings.get(buildingId).stateRegion,
                        PW_Zip__c = buildings.get(buildingId).postalCode,
                        // PW_Year_Built__c = Integer.valueOf(buildings.get(buildingId).yearBuilt),
                        PW_Bedrooms__c = buildings.get(buildingId).numberOfBedrooms,
                        PW_Bathroos__c = buildings.get(buildingId).numberOfBathrooms,
                        PW_Building_Entity_ID1__c = buildingId,
                        PW_Portfolio_Entity_ID1__c = String.valueOf(buildings.get(buildingId).portfolioID),
                        PW_Portfolio_Entity_ID__c = Double.valueOf(buildings.get(buildingId).portfolioID),
                        PW_Building_ID_Number__c = Integer.valueOf(buildings.get(buildingId).buildingIdNumber)
                        // PW_Portfolio__c = portfolio.Id
                    );
                    buildingsToReturn.add(newBuilding);
                }
            }
            
        }
        return buildingsToReturn;
    }

    // private static PW_Portfolio__c getOrCreatePortfolio(PWBuildingWrapper building) {
    private static PW_Portfolio__c getOrCreatePortfolio(PWBuildingWrapper building) {
        system.debug('building getOrCreatePortfolio'+ building);
        PW_Portfolio__c portfolio = new PW_Portfolio__c();
        List<PW_Portfolio__c> existing = [
            SELECT Id, PW_Portfolio_Entity_ID__c FROM PW_Portfolio__c WHERE PW_Portfolio_Entity_ID__c = :building.portfolioID LIMIT 1
        ];
        if (!existing.isEmpty()){
            portfolio = existing[0];
        } 
        else{
            List<PW_Portfolio__c> defaultPortfolio = [
                SELECT Id, PW_Portfolio_Entity_ID__c FROM PW_Portfolio__c WHERE Name = 'Default PW Portfolio' LIMIT 1
            ];
            portfolio = defaultPortfolio[0];
        }
        
        return portfolio;
    }

    private static House__c getOrCreateHouse(PWBuildingWrapper building) {
        String fullAddress = building.address + ', ' + building.city + ', ' + building.stateRegion + ' ' + building.postalCode;
        String placeId = GooglePlacesService.getPlaceIdFromAddress(fullAddress);
        system.debug('placeId'+ placeId);
        House__c houseToReturn = new House__c();

        List<House__c> existing = [
            SELECT Id FROM House__c WHERE Google_Place_ID__c = :placeId LIMIT 1
        ];
        system.debug('existing house'+ existing);
        if (!existing.isEmpty()){
            houseToReturn = existing[0];
        } 
        else{
            List<House__c> defaultHouse = [
                SELECT Id, Name FROM House__c WHERE Name = 'Default House' LIMIT 1
            ];
            houseToReturn = defaultHouse[0];
        }
        return houseToReturn;
    //     House__c house = new House__c(
    //         // Market__c = building.Market,
    //         Name = building.Name,
    //         Street_Address__c = building.Address,
    //         City__c = building.City,
    //         State__c = building.State,
    //         Zip_Code__c = building.postalCode,
    //         // House_Type__c = building.PropertyType,
    //         // Bedrooms__c = building.Bedrooms,
    //         // Bathrooms__c = building.Bathrooms,
    //         // Car_Storage__c = null, // Set as needed
    //         // Sq_Feet__c = building.TotalArea,
    //         // Year_Built__c = building.YearBuilt,
    //         Status__c = 'Managed',
    //         Google_Place_ID__c = placeId
    //     );
    //     insert house;
    //     return house;
    }

    private static PW_Building__c getBuildingByEntityId(String entityId) {
        List<PW_Building__c> records = [
            SELECT Id, PW_Building_ID__c FROM PW_Building__c WHERE PW_Building_ID__c = :entityId LIMIT 1
        ];
        return records.isEmpty() ? null : records[0];
    }


    public class PWBuildingWrapper {
        public String buildingEntityId;
        public String address;
        // public String addressCont;
        public String city;
        public String stateRegion;
        public String postalCode;
        public String country;
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
        // public String type;
        // public String category;
        // public Integer floorNumber;
        // public Integer numberFloors;
        // public String neighborhood;
        // public Double totalArea;
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
}