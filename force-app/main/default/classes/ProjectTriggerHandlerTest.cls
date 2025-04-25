@isTest
public class ProjectTriggerHandlerTest {   
    
    
    @isTest
    static void testData() {
        
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
                Market__c ='MEM'
            )
        );
        insert houseList;
        
        Project__c obj = new Project__c();
        obj.House__c = houseList[0].id;
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
        Insert obj;
        
        obj.Refresh__c = True;
        Update obj;
        
    }
    
    @isTest
    static void test_Method_1() {
        
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
                Market__c ='MEM'
            )
        );
        insert houseList;
        
        Project__c obj = new Project__c();
        obj.House__c = houseList[0].id;
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
        Insert obj;
        
        obj.Calculate__c = True;
        Update obj;
        
    }
    
    @isTest
    static void test_Method_3() {
        
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
                Market__c ='MEM'
            )
        );
        insert houseList;
        
        List<Project__c> projectList = new List<Project__c>();
        Project__c obj = new Project__c();
        obj.House__c = houseList[0].id;
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
        projectList.add(obj);
        
        Test.startTest();
        Database.SaveResult[] srList = Database.insert(projectList, false);
 
        Test.stopTest(); 
        // Verify // In this case the deletion should have been stopped by the trigger, 
        // so verify that we got back an error. 
        System.assert(!srList[0].isSuccess());
        System.assert(srList[0].getErrors().size() > 0); 
        System.assertEquals('For a Rehab Project, A Pay Account is required prior to Save', srList[0].getErrors()[0].getMessage()); 
        
        
    }
    
   /* @isTest
    static void test_Method(){
        List<Project__c> projectList = [SELECT Id FROM Project__c];
        projectList[0].Calculate__c = True;
        Update projectList[0];
        
    }
    
    @isTest
    static void test_Method_1(){
        
        List<Project__c> projectList = [SELECT Id FROM Project__c];
        projectList[0].Refresh__c = True;
        Update projectList[0];
    }*/
    
    
    
}