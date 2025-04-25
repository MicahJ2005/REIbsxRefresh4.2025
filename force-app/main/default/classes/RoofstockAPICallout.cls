public class RoofstockAPICallout {
    
    // Method to auth into Roofstock to get jwtToken
    public static string getJwtTocket(){
        
        RoofstockRestAPI__c credential = RoofstockRestAPI__c.getValues('Roofstock'); 
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse response = new HttpResponse();
        req.setEndpoint(credential.End_Point__c + '/auth');
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('POST');
        req.setTimeout(120000);
        String json = '{'+
            '"userName": "'+credential.Username__c+'",'+
            '"password": "'+credential.Password__c+'"'+
            '}';
        req.setBody(json);
        if(!Test.isRunningTest()){
            response = http.send(req);
        }else{
            String mockjson = '{'+
                '    \"isAuthenticated\": true,'+
                '    \"jwtToken\": \"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoiUm9vZnN0b2NrQVBJQHJlaW5hdGlvbi5jb20iLCJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9naXZlbm5hbWUiOiJNZW1waGlzIFJFSSBUZXN0IEFQSSIsImh0dHA6Ly9zY2hlbWFzLnhtbHNvYXAub3JnL3dzLzIwMDUvMDUvaWRlbnRpdHkvY2xhaW1zL25hbWVpZGVudGlmaWVyIjoiMjQwNDAyIiwiQWNjb3VudElkIjoiMjEzOTYyIiwiVXNlcklkIjoiMjQwNDAyIiwiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy9yb2xlIjpbIkN1c3RvbWVyIiwiUmVndWxhciBVc2VyIl0sImV4cCI6MTYxNDMyMjU5MiwiaXNzIjoiaHR0cHM6Ly93d3cucm9vZnN0b2NrLmNvbS9qd3QiLCJhdWQiOiJodHRwczovL3d3dy5yb29mc3RvY2suY29tL2p3dCJ9.kP1qcgrIx0t_gJmKAdsF4-CuJOxBXHP-3jhmfn9-Nuc\"'+
                '}';
            response.setBody(mockjson);
        }
        return response.getBody();
    }   
    
    public static HttpRequest supply() {
        
        RoofstockRestAPI__c credential = RoofstockRestAPI__c.getValues('Roofstock');
        HttpRequest req = new HttpRequest();
        req.setEndpoint(credential.End_Point__c + '/partners/Supply'); // End Point
        JSON2Apex obj = JSON2Apex.parse(getJwtTocket());
        req.setHeader('Authorization', 'Bearer '+obj.jwtToken);            
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('POST');
        req.setTimeout(120000);
        
        return req; 
    } 
}