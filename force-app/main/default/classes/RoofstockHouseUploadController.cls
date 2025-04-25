public class RoofstockHouseUploadController {
    
    
    @AuraEnabled
    public static Project__c getProjectRecord(String recordId) {
        
        if(String.isNotBlank(recordId)){
            List<Project__c> proList = [SELECT Id,Asking_Price__c,Rent_Assumption_for_Calculations__c,Street_Address__c,City__c,State__c,
                                        Zip_Code__c,House__c,House__r.Name,House__r.House_Type__c,Shareable_Image_Folder_Link__c,Sales_Status__c,
                                        Bedrooms__c,Bathrooms__c,Sq_Feet__c,Year_Built__c,House__r.Marketing_Description__c,Make_Available__c,
                                        Type_of_Air__c,Type_of_Heat__c,Project__c,Parking__c,House__r.HOA_Type__c,
                                        House__r.HOA__c,House__r.Car_Storage_Parking__c,House__r.Occupancy_Status__c,House__r.Street_Address__c,
                                        RoofStock_Status__c,House__r.Current_Rent__c
                                        FROM Project__c 
                                        WHERE Id=: recordId];
            if(proList !=null && !proList.isEmpty()){
                return proList[0];
            }
        }
        
        return null;
    }
    
    @AuraEnabled
    public static void uploadHouse(Project__c project) {
        try{
            if(project != null){
                Boolean newContruction = false;
                Integer carParking = 0;
                Boolean hoaYN = false;
                String propertyType = '';
                if(project.Project__c == 'New Build'){
                    newContruction = true;
                }
                
                if(String.isNotBlank(project.House__r.House_Type__c))
                {
                    if(project.House__r.House_Type__c == 'Condo'){
                        propertyType = 'Condominium';
                    }else if(project.House__r.House_Type__c == 'Duplex'){
                        propertyType = 'Duplex';
                    }else if(project.House__r.House_Type__c == 'Fourplex'){
                        propertyType = 'Quadruplex';
                    }else if(project.House__r.House_Type__c == 'Lot'){
                        propertyType = 'Lot';
                    }else if(project.House__r.House_Type__c == 'Single Family Detached'){
                        propertyType = 'Single Family Residence';
                    }else if(project.House__r.House_Type__c == 'Townhouse'){
                        propertyType = 'Townhouse';
                    }
                }
                
                if(project.House__r.Car_Storage_Parking__c == 'PL' || project.House__r.Car_Storage_Parking__c == 'ST' || project.House__r.Car_Storage_Parking__c == 'DR' ||
                   project.House__r.Car_Storage_Parking__c == '1GA' || project.House__r.Car_Storage_Parking__c == '1GD' || project.House__r.Car_Storage_Parking__c == '1CA'||
                   project.House__r.Car_Storage_Parking__c == '1CD'){
                       carParking = 1;
                   }else if(project.House__r.Car_Storage_Parking__c == '1CA1GD' || project.House__r.Car_Storage_Parking__c == '1GA1CA' || project.House__r.Car_Storage_Parking__c == '1GA1CD' ||
                            project.House__r.Car_Storage_Parking__c == '2GA' || project.House__r.Car_Storage_Parking__c == '2GD' || project.House__r.Car_Storage_Parking__c == '2CA'||
                            project.House__r.Car_Storage_Parking__c == '2CD'){
                                carParking = 2;
                            }else if(project.House__r.Car_Storage_Parking__c == '1CA2GD' || project.House__r.Car_Storage_Parking__c == '1CA2GA' || project.House__r.Car_Storage_Parking__c == '1GA2CD' ||
                                     project.House__r.Car_Storage_Parking__c == '3CA' || project.House__r.Car_Storage_Parking__c == '3GA' || project.House__r.Car_Storage_Parking__c == '3GD'||
                                     project.House__r.Car_Storage_Parking__c == '1GA2CA' || project.House__r.Car_Storage_Parking__c == '2CA1GD' || project.House__r.Car_Storage_Parking__c == '2GA1CD'){
                                         carParking = 3;
                                     }else if(project.House__r.Car_Storage_Parking__c == '2CA2GD' || project.House__r.Car_Storage_Parking__c == '2GD2CD' || project.House__r.Car_Storage_Parking__c == '4GA'){
                                         carParking = 4;
                                     }
                
                if(project.House__r.HOA_Type__c == 'YES'){
                    hoaYN = true;
                }
                DateTime DT;
                if(project.Make_Available__c != NULL){
                    DT = (Datetime)project.Make_Available__c;
                }else{
                    Date d = system.today();
                    DT = (Datetime)d;
                }
                
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                HttpResponse response = new HttpResponse();
                String json ='{'+
                    '"properties": ['+
                    ' {'+
                    '"listingId": "'+project.id+'",'+
                    '"listPrice": '+project.Asking_Price__c+','+
                    '"address1": "'+string.valueOf(project.House__r.Street_Address__c)+'",'+
                    '"city": "'+project.City__c+'",'+
                    '"state": "'+project.State__c+'",'+
                    '"zip": "'+Integer.valueOf(project.Zip_Code__c)+'",'+
                    '"unparsedAddress": "",'+
                    '"propertyType": "'+propertyType+'",'+
                    '"standardStatus": "'+project.RoofStock_Status__c+'",'+
                    '"sourceListingStatus": "Active",'+
                    '"bedrooms": '+integer.valueOf(project.Bedrooms__c)+','+
                    '"bathrooms": '+integer.valueOf(project.Bathrooms__c)+','+
                    '"stories": 0,'+
                    '"publicRemarks": "",'+
                    '"privateRemarks": "",'+
                    '"squareFeet": '+project.Sq_Feet__c+','+
                    '"yearBuilt": '+project.Year_Built__c+','+
                    '"lotSizeSqFt": 0,'+
                    '"lotSizeAcres": 0,'+
                    '"closePrice": 0,'+
                    '"closeDate": "2020-12-14T10:25:25.825Z",'+
                    '"contractPrice": 0,'+
                    '"contractDate": "2020-12-14T10:25:25.825Z",'+
                    '"cancelationDate": "2020-12-14T10:25:25.825Z",'+
                    '"onMarketDate": "'+DT.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'')+'",'+
                    '"ownership": "",'+
                    '"flooring": ['+
                    ' ""'+
                    '],'+
                    '"coolingYN": true,'+
                    '"cooling": ['+
                    '  "'+project.Type_of_Air__c+'"'+
                    '],'+
                    '"heatingYN": true,'+
                    '"heating": ['+
                    '  "'+project.Type_of_Heat__c+'"'+
                    '],'+
                    '"poolPrivateVN": true,'+
                    '"roof": ['+
                    ' ""'+
                    '],'+
                    '"sewer": ['+
                    '  ""'+
                    '],'+
                    '"newConstructionYN": '+newContruction+','+
                    ' "basement": "string",'+
                    ' "parcelNumber": "",'+
                    ' "propertyAttachedYN": true,'+
                    ' "garageYN": true,'+
                    ' "attachedGarageYN": true,'+
                    ' "parkingTotal": '+carParking+','+
                    ' "propertyCondition": "",'+
                    ' "associationYN": '+hoaYN+','+
                    ' "associationName": "",'+
                    ' "associationFee": '+project.House__r.HOA__c+','+
                    ' "associationFeeFrequency": "Annually",'+
                    ' "associationFeeIncludes": ['+
                    '   ""'+
                    ' ],'+
                    ' "associationPhone": "",'+
                    ' "associationEmail": "",'+
                    ' "marketRent": '+project.Rent_Assumption_for_Calculations__c+','+
                    ' "occupancy": "'+project.House__r.Occupancy_Status__c+'",'+
                    ' "monthlyRent": '+project.House__r.Current_Rent__c+','+
                    ' "securityDeposit": 0,'+
                    ' "leaseTerm": "",'+
                    ' "leaseStartDate": "2020-12-14T10:25:25.825Z",'+
                    ' "leaseEndDate": "2020-12-14T10:25:25.825Z",'+
                    ' "section8YN": true,'+
                    ' "petFeeYN": true,'+
                    ' "petFeeMonthlyAmount": 0,'+
                    ' "petFeeDeposit": 0,'+
                    ' "totalActualRent": 0,'+
                    ' "rentPaymentStatus": "",'+
                    ' "transactionBrokerCompensation": 0,'+
                    ' "transactionBrokerCompensationType": "",'+
                    ' "roofstockAutoPublish": true,'+
                    ' "RoofstockPriceFloor": '+project.Asking_Price__c+','+
                    ' "url": "",'+
                    ' "photosCount": 0,'+
                    ' "media": ['+
                    '  {'+
                    '   "mediaUrl": "'+project.Shareable_Image_Folder_Link__c+'",'+
                    '  "mediaObjectId": "ME_5af601c3fc76173b34829126",'+
                    ' "order": 1,'+
                    ' "mimeType": "image/jpeg",'+
                    ' "shortDescription": "shared folder"'+
                    ' }'+
                    ' ],'+
                    '   "mainImageUrl": ""'+
                    '  }'+
                    ' ]'+
                    '}';
                if(!Test.isRunningTest()){
                    request = RoofstockAPICallout.supply();
                    request.setBody(json); 
                    response = http.send(request);
                    if(response.getStatusCode() == 200){}
                }
            }
        }catch(Exception e){
            System.debug('ERROR '+e.getLineNumber() +'--'+e.getMessage());
            throw new AuraHandledException('Darn it! Something went wrong: '+ e.getMessage());  
        }
    }
    
}