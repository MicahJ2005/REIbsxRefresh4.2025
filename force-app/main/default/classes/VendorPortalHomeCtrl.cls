public with sharing class VendorPortalHomeCtrl
{  

    //public List<PieWedgeData> amountBarData {get; set;}
    //public List<PieWedgeData> statusPieData {get; set;}
    public List<Portal_Message__c> portalMessages {get; set;}
    public Id acctId {get; set;}
    
    public VendorPortalHomeCtrl(){
        //amountBarData = new List<PieWedgeData>();
        //statusPieData = new List<PieWedgeData>();
        portalMessages = new List<Portal_Message__c>();
        Date today = System.today();        
        portalMessages = [SELECT Id, Message__c FROM Portal_Message__c WHERE (Notify__c = 'Community' OR (Notify__c = 'User' AND User__c =: UserInfo.getUserId())) AND Tab__c = 'Home' AND Start_Date__c <=: today AND End_Date__c >=: today ORDER BY Name];
        System.debug('portalMessages----'+portalMessages);
        User usr = [SELECT Id, AccountId__c FROM User WHERE Id=: UserInfo.getUserId()];
        
        acctId = usr.AccountId__c;
        
        /*
        System.debug('amountBarData----'+amountBarData);
        
        List<AcctSeed__Account_Payable__c> payables = new List<AcctSeed__Account_Payable__c>();  
        
        
        Integer thisMonth = System.today().month();
        Integer thisYear = System.today().year();
        
        //AND AcctSeed__Vendor__c != NULL 
        String sql = 'SELECT Name, AcctSeed__Total__c, AcctSeed__Status__c, AcctSeed__Due_Date__c FROM AcctSeed__Account_Payable__c WHERE AcctSeed__Vendor__c =: acctId '+
                        'AND CALENDAR_YEAR(AcctSeed__Due_Date__c) =: thisYear';
                        
                        //AND CALENDAR_MONTH(AcctSeed__Date__c) =: thisMonth  
                        
        payables = Database.Query(sql);
        
        Map<String, Integer> dataMap = new Map<String, Integer>();
        
        Map<String, Decimal> dataAmountMap = new Map<String, Decimal>();
        
        for(AcctSeed__Account_Payable__c temp: payables)
        {  
            if(dataMap.containsKey(temp.AcctSeed__Status__c)){
                Integer dataValue = dataMap.get(temp.AcctSeed__Status__c);
                dataValue++;
                dataMap.put(temp.AcctSeed__Status__c, dataValue);
            }
            else{         
                dataMap.put(temp.AcctSeed__Status__c, 1);
            }
            
            String month = String.valueOf(temp.AcctSeed__Due_Date__c.month());
            System.debug('month----'+month+'---'+temp.AcctSeed__Total__c);
            
            if(dataAmountMap.containsKey(month)){
                Decimal dataValue = dataAmountMap.get(month);
                dataValue += temp.AcctSeed__Total__c;
                dataAmountMap.put(month, dataValue);
            }
            else{         
                dataAmountMap.put(month, temp.AcctSeed__Total__c);
            }
        }
        
        for(String key: dataMap.keySet())
        {
            statusPieData.add(new PieWedgeData(key, dataMap.get(key)));
        }
        
        System.debug('dataAmountMap----'+dataAmountMap);
        
        for(String key: dataAmountMap.keySet())
        {
            amountBarData.add(new PieWedgeData(key, dataAmountMap.get(key)));
        }
        
        
        System.debug('amountBarData----'+amountBarData);
        */
    }
    
    /*
    public List<PieWedgeData> getPieData() 
    {  
        List<PieWedgeData> data = new List<PieWedgeData>();
        List<AcctSeed__Account_Payable__c> payables = new List<AcctSeed__Account_Payable__c>();  
        
        User usr = [SELECT Id, AccountId__c FROM User WHERE Id=: UserInfo.getUserId()];
        
        Id acctId = usr.AccountId__c;
        Integer thisMonth = System.today().month();
        Integer thisYear = System.today().year();
        
        //AND AcctSeed__Vendor__c != NULL 
        String sql = 'SELECT Name, AcctSeed__Total__c, AcctSeed__Status__c, AcctSeed__Due_Date__c FROM AcctSeed__Account_Payable__c WHERE AcctSeed__Vendor__c =: acctId '+
                        'AND CALENDAR_YEAR(AcctSeed__Due_Date__c) =: thisYear';
                        
                        //AND CALENDAR_MONTH(AcctSeed__Date__c) =: thisMonth  
                        
        payables = Database.Query(sql);
        
        Map<String, Integer> dataMap = new Map<String, Integer>();
        
        Map<String, Decimal> dataAmountMap = new Map<String, Decimal>();
        
        for(AcctSeed__Account_Payable__c temp: payables)
        {  
            if(dataMap.containsKey(temp.AcctSeed__Status__c)){
                Integer dataValue = dataMap.get(temp.AcctSeed__Status__c);
                dataValue++;
                dataMap.put(temp.AcctSeed__Status__c, dataValue);
            }
            else{         
                dataMap.put(temp.AcctSeed__Status__c, 1);
            }
            
            String month = String.valueOf(temp.AcctSeed__Due_Date__c.month());
            System.debug('month----'+month+'---'+temp.AcctSeed__Total__c);
            
            if(dataAmountMap.containsKey(month)){
                Decimal dataValue = dataAmountMap.get(month);
                dataValue += temp.AcctSeed__Total__c;
                dataAmountMap.put(month, dataValue);
            }
            else{         
                dataAmountMap.put(month, temp.AcctSeed__Total__c);
            }
        }
        
        for(String key: dataMap.keySet())
        {
            data.add(new PieWedgeData(key, dataMap.get(key)));
        }
        
        System.debug('dataAmountMap----'+dataAmountMap);
        
        for(String key: dataAmountMap.keySet())
        {
            amountBarData.add(new PieWedgeData(key, dataMap.get(key)));
        }
        
        return data;  
    }  
    
    // Wrapper class  
    public class PieWedgeData 
    {  
        public String name { get; set; }  
        public Decimal data { get; set; }  
        
        public PieWedgeData(String name, Decimal data) 
        {  
            this.name = name;  
            this.data = data;  
        }  
    }  
    */
}