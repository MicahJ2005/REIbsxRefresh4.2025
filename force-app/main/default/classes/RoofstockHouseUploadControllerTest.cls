@isTest
public class RoofstockHouseUploadControllerTest {
    @testSetup
    static void testData(){
        
        RoofstockRestAPI__c cs = new RoofstockRestAPI__c();
        cs.Name = 'Roofstock';
        cs.End_Point__c = 'https://staging-api.roofstock.com';
        cs.Password__c = 'Rstest123$';
        cs.Username__c = 'mcarmichael@reination.com';
        Insert cs;
        
        Market_Table__c marketTableObj = new Market_Table__c();
        marketTableObj.Vacancy_Rate__c =2 ;
        marketTableObj.Maintenance_Rate__c =4;
        marketTableObj.Annual_Appreciation__c =3;
        marketTableObj.Annual_Operating_Expense_Increase__c =5;
        marketTableObj.Market__c ='MEM';
        Insert marketTableObj;   
        
        
        List<House__c> houseList = new List<House__c>();
        houseList.add(
            new House__c(
                Name = 'Test House',
                City__c = 'Test City',
                State__c = 'MS',
                Zip_Code__c = '12345',
                Street_Address__c = 'Test Street Address',
                Market__c ='MEM',
                House_Type__c = 'Duplex',
                HOA_Type__c = 'YES'
            )
        );
        
        houseList.add(
            new House__c(
                Name = 'Test House',
                City__c = 'Test City',
                State__c = 'MS',
                Zip_Code__c = '12345',
                Street_Address__c = 'Test Street Address',
                Market__c ='MEM',
                House_Type__c = 'Condo'
            )
        );
        
        houseList.add(
            new House__c(
                Name = 'Test House',
                City__c = 'Test City',
                State__c = 'MS',
                Zip_Code__c = '12345',
                Street_Address__c = 'Test Street Address',
                Market__c ='MEM',
                House_Type__c = 'Fourplex'
            )
        );
        
        houseList.add(
            new House__c(
                Name = 'Test House',
                City__c = 'Test City',
                State__c = 'MS',
                Zip_Code__c = '12345',
                Street_Address__c = 'Test Street Address',
                Market__c ='MEM',
                House_Type__c = 'Lot'
            )
        );
        
        houseList.add(
            new House__c(
                Name = 'Test House',
                City__c = 'Test City',
                State__c = 'MS',
                Zip_Code__c = '12345',
                Street_Address__c = 'Test Street Address',
                Market__c ='MEM',
                House_Type__c = 'Single Family Detached'
            )
        );
        
        houseList.add(
            new House__c(
                Name = 'Test House',
                City__c = 'Test City',
                State__c = 'MS',
                Zip_Code__c = '12345',
                Street_Address__c = 'Test Street Address',
                Market__c ='MEM',
                House_Type__c = 'Townhouse'
            )
        );
        insert houseList;
        
        List<Project__c> projectList = new List<Project__c>();
        for(House__c hs : houseList){
            Project__c obj = new Project__c();
            obj.House__c = hs.id;
            obj.Project__c = 'New Build';
            obj.Asking_Price__c = 18500;
            obj.Downpayment__c = 25;
            obj.Interest_Rate__c = 4.25;
            obj.Mortgage_Year__c = '30';
            obj.Vacancy_Rate__c = 4.0;
            obj.Maintenance_Rate__c = 4.0;
            obj.Rent_Assumption_for_Calculations__c = 1245;
            obj.Estimated_Annual_Property_Taxes__c = 1394;
            obj.Estimated_Annual_HOA_Dues__c = 435;
            obj.Estimated_Annual_Management_Fee_10__c = 1494;
            obj.Estimated_Annual_Homeowners_Insurance__c = 754;
            obj.Appreciation_Rate__c = 1.0;
            obj.Pay_Account__c = 'New MEM';
            projectList.add(obj);
        }
        Insert projectList;
    }
    
    @isTest
    static void test1(){
        List<Project__c> projectList = [Select id from Project__c WHERE House__r.House_Type__c =: 'Condo'];
        Project__c pObj =  RoofstockHouseUploadController.getProjectRecord(projectList[0].Id);
        RoofstockHouseUploadController.uploadHouse(pObj);
    }
    
    @isTest
    static void test2(){
        List<Project__c> projectList = [Select id from Project__c WHERE House__r.House_Type__c =: 'Duplex'];
        Project__c pObj =  RoofstockHouseUploadController.getProjectRecord(projectList[0].Id);
        RoofstockHouseUploadController.uploadHouse(pObj);
    }
    
    @isTest
    static void test3(){
        List<Project__c> projectList = [Select id from Project__c WHERE House__r.House_Type__c =: 'Lot'];
        Project__c pObj =  RoofstockHouseUploadController.getProjectRecord(projectList[0].Id);
        RoofstockHouseUploadController.uploadHouse(pObj);
    }
    
    @isTest
    static void test4(){
        List<Project__c> projectList = [Select id from Project__c WHERE House__r.House_Type__c =: 'Single Family Detached'];
        Project__c pObj =  RoofstockHouseUploadController.getProjectRecord(projectList[0].Id);
        RoofstockHouseUploadController.uploadHouse(pObj);
    }
    
    @isTest
    static void test5(){
        List<Project__c> projectList = [Select id from Project__c WHERE House__r.House_Type__c =: 'Townhouse'];
        Project__c pObj =  RoofstockHouseUploadController.getProjectRecord(projectList[0].Id);
        RoofstockHouseUploadController.uploadHouse(pObj);
    }
    
    @isTest
    static void test6(){
        List<Project__c> projectList = [Select id from Project__c WHERE House__r.House_Type__c =: 'Fourplex'];
        Project__c pObj =  RoofstockHouseUploadController.getProjectRecord(projectList[0].Id);
        RoofstockHouseUploadController.uploadHouse(pObj);
    }
}