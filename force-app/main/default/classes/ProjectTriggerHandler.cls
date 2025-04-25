public class ProjectTriggerHandler {

    // Pay Account Field Required Validation For Renovation Project
    public static void beforeInsert(List<Project__c> projectList) {
        Id recordTypeId = Schema.SObjectType.Project__c.getRecordTypeInfosByName().get('Renovation').getRecordTypeId();
        for(Project__c proj : projectList){
            if(proj.RecordTypeId == recordTypeId && String.isBlank(proj.Pay_Account__c)) {
                proj.Pay_Account__c.addError('For a Rehab Project, A Pay Account is required prior to Save');
            }
        }
    }
    
    
    // In this method we are getting Project fields from market table object
    public static void afterInsert(List<Project__c> projectList){
        
        List<Project__c> updateProjectList = new List<Project__c>();
        Map<String,Market_Table__c> marketMap = new Map<String,Market_Table__c>();
        
        for(Market_Table__c market : [SELECT Id,Market__c,Vacancy_Rate__c,Maintenance_Rate__c,Annual_Appreciation__c,Rental_Revenue_Appreciation__c,
                                      Annual_Operating_Expense_Increase__c,Downpayment__c,Mortgage_Year__c,Interest_Rate__c,Property_Rate_by_Geography__c
                                      ,GL_Rate__c,Umbrella_Rate__c,Tech_Admin__c,Admin_Fees__c,Tax_Variable_For_GL_Tax__c,Tax_Variable_For_SL_Tax__c,Tax_Variable_For_UM_Tax__c	
                                      FROM Market_Table__c WHERE Market__c != '']){
                                          if(!marketMap.containsKey(market.Market__c)){
                                              marketMap.put(String.valueOf(market.Market__c),market);
                                          }
                                      }
        for(Project__c project : projectList){
            if(String.isNotBlank(project.Market__c)){
                Project__c newObj = new Project__c();
                newObj.id = project.id;
                if(marketMap.containsKey(project.Market__c))
                {
                    if(marketMap.get(project.Market__c).Vacancy_Rate__c != null){
                        newObj.Vacancy_Rate__c = marketMap.get(project.Market__c).Vacancy_Rate__c;
                    }
                    
                    if(marketMap.get(project.Market__c).Maintenance_Rate__c != null){
                        newObj.Maintenance_Rate__c = marketMap.get(project.Market__c).Maintenance_Rate__c;
                    }
                    
                    if(marketMap.get(project.Market__c).Annual_Appreciation__c != null){
                        newObj.Appreciation_Rate__c = marketMap.get(project.Market__c).Annual_Appreciation__c;
                    }
                    
                    if(marketMap.get(project.Market__c).Vacancy_Rate__c != null){
                        newObj.Vacancy_Rate__c = marketMap.get(project.Market__c).Vacancy_Rate__c;
                    }
                    
                    if(marketMap.get(project.Market__c).Rental_Revenue_Appreciation__c != null){
                        newObj.Rental_Revenue_Appreciation__c = marketMap.get(project.Market__c).Rental_Revenue_Appreciation__c;
                    }
                    
                    if(marketMap.get(project.Market__c).Annual_Operating_Expense_Increase__c != null){
                        newObj.Annual_Operating_Expense_Increase__c = marketMap.get(project.Market__c).Annual_Operating_Expense_Increase__c;
                    }
                    if(project.Rent_Assumption_for_Calculations__c != null){
                        newObj.Estimated_Annual_Management_Fee_10__c =  project.Rent_Assumption_for_Calculations__c * 12 * 0.1;
                    }  
                    if(marketMap.get(project.Market__c).Downpayment__c != null){
                        newObj.Downpayment__c = marketMap.get(project.Market__c).Downpayment__c;
                    }  
                    if(marketMap.get(project.Market__c).Mortgage_Year__c != null){
                        newObj.Mortgage_Year__c = marketMap.get(project.Market__c).Mortgage_Year__c;
                    }  
                    if(marketMap.get(project.Market__c).Interest_Rate__c != null){
                        newObj.Interest_Rate__c = marketMap.get(project.Market__c).Interest_Rate__c;
                    }  
                    if(marketMap.get(project.Market__c).Property_Rate_by_Geography__c != null){
                        newObj.Property_Rate_by_Geography__c = marketMap.get(project.Market__c).Property_Rate_by_Geography__c;
                    }  
                    if(marketMap.get(project.Market__c).GL_Rate__c != null){
                        newObj.GL_Rate__c = marketMap.get(project.Market__c).GL_Rate__c;
                    }  
                    if(marketMap.get(project.Market__c).Umbrella_Rate__c != null){
                        newObj.Umbrella_Rate__c = marketMap.get(project.Market__c).Umbrella_Rate__c;
                    }  
                    if(marketMap.get(project.Market__c).Tech_Admin__c != null){
                        newObj.Tech_Admin__c = marketMap.get(project.Market__c).Tech_Admin__c;
                    }
                    if(marketMap.get(project.Market__c).Admin_Fees__c != null){
                        newObj.Admin_Fees__c = marketMap.get(project.Market__c).Admin_Fees__c;
                    }
                    if(marketMap.get(project.Market__c).Tax_Variable_For_GL_Tax__c != null){
                        newObj.GL_Tax__c = marketMap.get(project.Market__c).Tax_Variable_For_GL_Tax__c;
                    }
                    if(marketMap.get(project.Market__c).Tax_Variable_For_SL_Tax__c != null){
                        newObj.SL_Tax__c = marketMap.get(project.Market__c).Tax_Variable_For_SL_Tax__c;
                    }
                    if(marketMap.get(project.Market__c).Tax_Variable_For_UM_Tax__c != null){
                        newObj.UM_Tax__c = marketMap.get(project.Market__c).Tax_Variable_For_UM_Tax__c;
                    }
                }
                updateProjectList.add(newObj);
            }
        }
        
        if(updateProjectList.size() > 0 ){
            Update updateProjectList;
        }
    }   
    
    public static void calculateInvestmentProperty(List<Project__c> newList, Map<id,Project__c> oldMap){
        Map<String,Market_Table__c> marketMap = new Map<String,Market_Table__c>();
        for(Market_Table__c market : [SELECT Id,Market__c,Vacancy_Rate__c,Maintenance_Rate__c,Annual_Appreciation__c,Rental_Revenue_Appreciation__c,
                                      Annual_Operating_Expense_Increase__c,Downpayment__c,Mortgage_Year__c,Interest_Rate__c,Property_Rate_by_Geography__c
                                      ,GL_Rate__c,Umbrella_Rate__c,Tech_Admin__c,Admin_Fees__c,Tax_Variable_For_GL_Tax__c,Tax_Variable_For_SL_Tax__c,Tax_Variable_For_UM_Tax__c	
                                      FROM Market_Table__c WHERE Market__c != ''])
        {
            if(!marketMap.containsKey(market.Market__c)){
                marketMap.put(String.valueOf(market.Market__c),market);
            }
        }
        
        for(Project__c project : newList){
            if(project.Refresh__c && project.Calculate__c){
                project.addError('You cannot select calculate and refresh at the same time');
            }else if(project.Calculate__c){
                calculateInvestmentProperty1(newList);
                project.Calculate__c = false;
                Decimal askingPrice = project.Asking_Price__c; 
                Decimal downPayment_Amount = 0 ;
                
                if(project.Asking_Price__c != null && project.Downpayment__c != null)
                {
                    downPayment_Amount = (project.Downpayment__c * askingPrice) / 100; 
                    project.Downpayment_Amount__c = downPayment_Amount;
                }
                System.debug('downPayment_Amount '+downPayment_Amount);
                
                Decimal finance_Amount = 0;
                if(askingPrice != null && downPayment_Amount != null)
                {
                    finance_Amount = askingPrice - downPayment_Amount;
                }
                System.debug('finance_Amount '+finance_Amount);
                
                if(finance_Amount != null)
                {
                    project.PE_Loan_Amount__c = finance_Amount;
                }
                System.debug('project.PE_Loan_Amount__c '+project.PE_Loan_Amount__c);
                
                Decimal interestRate = 0;
                if(project.Interest_Rate__c != null)
                {
                    interestRate = project.Interest_Rate__c;
                }
                System.debug('interestRate '+interestRate);
                
                String mortgageYear = '';
                if(String.isNotBlank(project.Mortgage_Year__c)){
                    mortgageYear = project.Mortgage_Year__c;
                }
                System.debug('mortgageYear '+mortgageYear);
                
                Decimal mortgage_Payment = 0;
                if(finance_Amount != null && interestRate != null && String.isNotBlank(mortgageYear) && finance_Amount > 0 && interestRate > 0){
                    mortgage_Payment = ((finance_Amount * ((interestRate / 12 )/ 100)) * math.pow( double.valueOf((1+((interestRate/12) / 100))), double.valueOf((Integer.valueOf(mortgageYear)*12))) / (math.pow( double.valueOf((1+((interestRate /12 ) / 100))), double.valueOf((Integer.valueOf(mortgageYear)*12))) - 1 )).setScale(2);
                }
                System.debug('mortgage_Payment '+mortgage_Payment);
                
                if(mortgage_Payment != null){
                    project.PITI__c =  mortgage_Payment; 
                }
                
                Decimal total_Rent_Per_Month = 0;
                if(project.Rent_Assumption_for_Calculations__c != null)
                {
                    total_Rent_Per_Month = project.Rent_Assumption_for_Calculations__c;
                }
                
                Decimal gross_Rent_Per_Year = 0;
                if(total_Rent_Per_Month != null)
                {
                    gross_Rent_Per_Year = total_Rent_Per_Month * 12;
                }
                
                Decimal vacancyRate = 0;
                if(project.Vacancy_Rate__c != null && project.Vacancy_Rate__c > 0)
                {
                    vacancyRate = (project.Vacancy_Rate__c / 100);
                }
                
                // Rates %
                Decimal annual_Appreciation = 0; 
                Decimal annual_Operating_Expense_Increase = 0;
                Decimal annual_Revenue_Increase = 0;
                
                if(project.Appreciation_Rate__c != null)
                {
                    annual_Appreciation = project.Appreciation_Rate__c / 100;
                }
                
                System.debug('annual_Appreciation '+annual_Appreciation);
                
                if(project.Annual_Operating_Expense_Increase__c != null){
                    annual_Operating_Expense_Increase = project.Annual_Operating_Expense_Increase__c; 
                }
                
                if(project.Rental_Revenue_Appreciation__c != null){
                    annual_Revenue_Increase = project.Rental_Revenue_Appreciation__c;
                }
                
                Decimal rental_Income_Year_5 = 0;
                Decimal rental_Income_Year_7 = 0;
                Decimal rental_Income_Year_10 = 0;
                
                Decimal vacany_Rate_Year_5 = 0;
                Decimal vacany_Rate_Year_7 = 0;
                Decimal vacany_Rate_Year_10 = 0;
                
                Decimal net_Rental_Income_Year_5 = 0;
                Decimal net_Rental_Income_Year_7 = 0;
                Decimal net_Rental_Income_Year_10 = 0;
                
                System.debug('annual_Appreciation  '+annual_Appreciation);
                System.debug('rent  '+project.Rent_Assumption_for_Calculations__c);
                
                if(project.Rent_Assumption_for_Calculations__c != null){
                    
                    rental_Income_Year_5 = math.ceil(calculateAmountYearWise((project.Rent_Assumption_for_Calculations__c * 12), 5, annual_Appreciation ));
                    vacany_Rate_Year_5 = (- math.ceil(rental_Income_Year_5 * vacancyRate )); 
                    net_Rental_Income_Year_5 = rental_Income_Year_5 + vacany_Rate_Year_5;
                    
                    rental_Income_Year_7 = math.ceil(calculateAmountYearWise(project.Rent_Assumption_for_Calculations__c * 12, 7, annual_Appreciation ));
                    vacany_Rate_Year_7 = (- math.ceil(rental_Income_Year_7 * vacancyRate )); 
                    net_Rental_Income_Year_7 = rental_Income_Year_7 + vacany_Rate_Year_7;
                    
                    rental_Income_Year_10 = math.ceil(calculateAmountYearWise(project.Rent_Assumption_for_Calculations__c * 12, 10, annual_Appreciation ));
                    vacany_Rate_Year_10 = (- math.ceil(rental_Income_Year_10 * vacancyRate )); 
                    net_Rental_Income_Year_10 = rental_Income_Year_10 + vacany_Rate_Year_10;
                }
                
                System.debug('rental_Income_Year_5  '+rental_Income_Year_5);
                System.debug('rental_Income_Year_7  '+rental_Income_Year_7);
                System.debug('rental_Income_Year_10  '+rental_Income_Year_10);
                
                System.debug('vacany_Rate_Year_5  '+vacany_Rate_Year_5);
                System.debug('vacany_Rate_Year_7  '+vacany_Rate_Year_7);
                System.debug('vacany_Rate_Year_10  '+vacany_Rate_Year_10);
                
                System.debug('net_Rental_Income_Year_5  '+net_Rental_Income_Year_5);
                System.debug('net_Rental_Income_Year_7  '+net_Rental_Income_Year_7);
                System.debug('net_Rental_Income_Year_10  '+net_Rental_Income_Year_10);
                
                Decimal property_Tax_Year_5 = 0;
                Decimal property_Tax_Year_7 = 0;
                Decimal property_Tax_Year_10 = 0;
                if(project.Estimated_Annual_Property_Taxes__c != null)
                { 
                    property_Tax_Year_5 = calculateAmountYearWise(project.Estimated_Annual_Property_Taxes__c, 5, (annual_Operating_Expense_Increase / 100));
                    property_Tax_Year_7 = calculateAmountYearWise(project.Estimated_Annual_Property_Taxes__c, 7, (annual_Operating_Expense_Increase / 100));
                    property_Tax_Year_10 = calculateAmountYearWise(project.Estimated_Annual_Property_Taxes__c, 10,( annual_Operating_Expense_Increase / 100));
                }
                
                System.debug('property_Tax_Year_5  '+property_Tax_Year_5);
                System.debug('property_Tax_Year_7  '+property_Tax_Year_7);
                System.debug('property_Tax_Year_10  '+property_Tax_Year_10);
                
                
                Decimal insurance_Year_5 = 0;
                Decimal insurance_Year_7 = 0;
                Decimal insurance_Year_10 = 0;
                if(project.Estimated_Annual_Home_owners_Insurance__c != null)
                {
                    insurance_Year_5 = calculateAmountYearWise(project.Estimated_Annual_Home_owners_Insurance__c, 5, (annual_Operating_Expense_Increase / 100));
                    insurance_Year_7 = calculateAmountYearWise(project.Estimated_Annual_Home_owners_Insurance__c, 7, (annual_Operating_Expense_Increase / 100));
                    insurance_Year_10 = calculateAmountYearWise(project.Estimated_Annual_Home_owners_Insurance__c, 10, (annual_Operating_Expense_Increase / 100));
                }
                
                System.debug('insurance_Year_5  '+insurance_Year_5);
                System.debug('insurance_Year_7  '+insurance_Year_7);
                System.debug('insurance_Year_10  '+insurance_Year_10);
                
                
                Decimal property_Management_Year_5 = 0;
                Decimal property_Management_Year_7 = 0;
                Decimal property_Management_Year_10 = 0;
                
                if(project.Estimated_Annual_Management_Fee_10__c != null)
                {
                    property_Management_Year_5 = calculateAmountYearWise(project.Estimated_Annual_Management_Fee_10__c, 5, (annual_Operating_Expense_Increase / 100));
                    property_Management_Year_7 = calculateAmountYearWise(project.Estimated_Annual_Management_Fee_10__c, 7, (annual_Operating_Expense_Increase / 100));
                    property_Management_Year_10 = calculateAmountYearWise(project.Estimated_Annual_Management_Fee_10__c, 10, (annual_Operating_Expense_Increase / 100));
                }
                
                System.debug('property_Management_Year_5  '+property_Management_Year_5);
                System.debug('property_Management_Year_7  '+property_Management_Year_7);
                System.debug('property_Management_Year_10  '+property_Management_Year_10);
                
                Decimal lease_Fee = 0;
                if(project.Rent_Assumption_for_Calculations__c != null)
                {
                    //lease_Fee = ((project.Rent_Assumption_for_Calculations__c * 2) / 10);
                }
                System.debug('lease_Fee  '+lease_Fee);
                
                Decimal hoa_Year_5 = 0;
                Decimal hoa_Year_7 = 0;
                Decimal hoa_Year_10 = 0;
                if(project.Estimated_Annual_HOA_Dues__c != null)
                {
                    hoa_Year_5 = calculateAmountYearWise(project.Estimated_Annual_HOA_Dues__c, 5, (annual_Operating_Expense_Increase / 100));
                    hoa_Year_7 = calculateAmountYearWise(project.Estimated_Annual_HOA_Dues__c, 7, (annual_Operating_Expense_Increase / 100));
                    hoa_Year_10 = calculateAmountYearWise(project.Estimated_Annual_HOA_Dues__c, 10, (annual_Operating_Expense_Increase / 100));
                }
                
                System.debug('hoa_Year_5  '+hoa_Year_5);
                System.debug('hoa_Year_7  '+hoa_Year_7);
                System.debug('hoa_Year_10  '+hoa_Year_10);
                
                Decimal maintenance_And_Repairs_Year_5 = 0;
                Decimal maintenance_And_Repairs_Year_7 = 0;
                Decimal maintenance_And_Repairs_Year_10 = 0;
                
                if(project.Rent_Assumption_for_Calculations__c != null && project.Maintenance_Rate__c != null )
                {
                    maintenance_And_Repairs_Year_5 = calculateAmountYearWise((project.Rent_Assumption_for_Calculations__c * (project.Maintenance_Rate__c / 100) * 12), 5, (annual_Operating_Expense_Increase / 100));
                    maintenance_And_Repairs_Year_7 = calculateAmountYearWise((project.Rent_Assumption_for_Calculations__c * (project.Maintenance_Rate__c / 100) * 12), 7, (annual_Operating_Expense_Increase / 100));
                    maintenance_And_Repairs_Year_10 = calculateAmountYearWise((project.Rent_Assumption_for_Calculations__c * (project.Maintenance_Rate__c / 100) * 12), 10, (annual_Operating_Expense_Increase / 100));
                }
                
                System.debug('maintenance_And_Repairs_Year_5  '+maintenance_And_Repairs_Year_5);
                System.debug('maintenance_And_Repairs_Year_7  '+maintenance_And_Repairs_Year_7);
                System.debug('maintenance_And_Repairs_Year_10  '+maintenance_And_Repairs_Year_10);
                
                Decimal total_Expenses_Year_5 = property_Tax_Year_5 + insurance_Year_5 + property_Management_Year_5 + lease_Fee + hoa_Year_5 +maintenance_And_Repairs_Year_5;
                Decimal total_Expenses_Year_7 = property_Tax_Year_7 + insurance_Year_7 + property_Management_Year_7 + lease_Fee + hoa_Year_7 +maintenance_And_Repairs_Year_7;
                Decimal total_Expenses_Year_10 = property_Tax_Year_10 + insurance_Year_10 + property_Management_Year_10 + lease_Fee + hoa_Year_10 +maintenance_And_Repairs_Year_10;
                
                System.debug('total_Expenses_Year_5  '+total_Expenses_Year_5);
                System.debug('total_Expenses_Year_7  '+total_Expenses_Year_7);
                System.debug('total_Expenses_Year_10  '+total_Expenses_Year_10);
                
                
                
                Decimal net_Operating_Income_Year_5 = net_Rental_Income_Year_5 - total_Expenses_Year_5;
                Decimal net_Operating_Income_Year_7 = net_Rental_Income_Year_7 - total_Expenses_Year_7;
                Decimal net_Operating_Income_Year_10 = net_Rental_Income_Year_10 - total_Expenses_Year_10;
                
                System.debug('net_Operating_Income_Year_5 '+net_Operating_Income_Year_5);
                System.debug('net_Operating_Income_Year_7 '+net_Operating_Income_Year_7);
                System.debug('net_Operating_Income_Year_10 '+net_Operating_Income_Year_10);
                
                
                
                Decimal mortgage = (mortgage_Payment * 12);
                
                System.debug('mortgage '+mortgage);
                
                Decimal total_Cash_Flow_Year_5 = net_Operating_Income_Year_5 - mortgage ;
                Decimal total_Cash_Flow_Year_7 = net_Operating_Income_Year_7 - mortgage ;
                Decimal total_Cash_Flow_Year_10 = net_Operating_Income_Year_10 - mortgage;
                
                System.debug('total_Cash_Flow_Year_5  '+total_Cash_Flow_Year_5);
                System.debug('total_Cash_Flow_Year_7  '+total_Cash_Flow_Year_7);
                System.debug('total_Cash_Flow_Year_10 '+total_Cash_Flow_Year_10);
                
                
                Decimal cash_Roi_Year_5 = 0;
                Decimal cash_Roi_Year_7 = 0;
                Decimal cash_Roi_Year_10 = 0;
                if(downPayment_Amount != null && downPayment_Amount > 0)
                {
                    cash_Roi_Year_5 = ((total_Cash_Flow_Year_5 / downPayment_Amount) * 100).setScale(2);
                    cash_Roi_Year_7 = ((total_Cash_Flow_Year_7 / downPayment_Amount) * 100).setScale(2);
                    cash_Roi_Year_10 = ((total_Cash_Flow_Year_10 / downPayment_Amount) * 100).setScale(2);
                }
                
                System.debug('cash_Roi_Year_5 '+cash_Roi_Year_5);
                System.debug('cash_Roi_Year_7 '+cash_Roi_Year_7);
                System.debug('cash_Roi_Year_10 '+cash_Roi_Year_10); 
                
                Decimal equity_Accrued_Year_5  = math.ceil(calculateRemainingAmount(finance_Amount, 12 * 4, ((interestRate/12).setScale(3) / 100), mortgage_Payment) - calculateRemainingAmount(finance_Amount, 12 * 5, ((interestRate/12).setScale(3) / 100), mortgage_Payment));
                Decimal equity_Accrued_Year_7  = math.ceil(calculateRemainingAmount(finance_Amount, 12 * 6, ((interestRate/12).setScale(3) / 100), mortgage_Payment) - calculateRemainingAmount(finance_Amount, 12 * 7, ((interestRate/12).setScale(3) / 100), mortgage_Payment));
                Decimal equity_Accrued_Year_10 = math.ceil(calculateRemainingAmount(finance_Amount, 12 * 9, ((interestRate/12).setScale(3) / 100), mortgage_Payment) - calculateRemainingAmount(finance_Amount,12 * 10,((interestRate/12).setScale(3) / 100), mortgage_Payment));
                
                System.debug('equity_Accrued_Year_5 '+equity_Accrued_Year_5);
                System.debug('equity_Accrued_Year_7 '+equity_Accrued_Year_7);
                System.debug('equity_Accrued_Year_10 '+equity_Accrued_Year_10);
                
                Decimal appreciation_Year_5 = 0;
                Decimal appreciation_Year_7 = 0;
                Decimal appreciation_Year_10 = 0;
                if(project.Asking_Price__c != null && project.Rental_Revenue_Appreciation__c != null)
                {
                    appreciation_Year_5 = calculateAmountYearWise(project.Asking_Price__c * (project.Rental_Revenue_Appreciation__c / 100), 5 , (project.Rental_Revenue_Appreciation__c / 100));
                    appreciation_Year_7 = calculateAmountYearWise(project.Asking_Price__c * (project.Rental_Revenue_Appreciation__c / 100), 7 , (project.Rental_Revenue_Appreciation__c / 100));
                    appreciation_Year_10 = calculateAmountYearWise(project.Asking_Price__c * (project.Rental_Revenue_Appreciation__c / 100), 10 , (project.Rental_Revenue_Appreciation__c / 100));
                }
                
                System.debug('appreciation_Year_5  '+appreciation_Year_5);
                System.debug('appreciation_Year_7  '+appreciation_Year_7);
                System.debug('appreciation_Year_10  '+appreciation_Year_10);
                
                Decimal total_Return_Year_5 = total_Cash_Flow_Year_5 + equity_Accrued_Year_5 + appreciation_Year_5;
                Decimal total_Return_Year_7 = total_Cash_Flow_Year_7 + equity_Accrued_Year_7 + appreciation_Year_7;
                Decimal total_Return_Year_10 = total_Cash_Flow_Year_10 + equity_Accrued_Year_10 + appreciation_Year_10;
                
                System.debug('total_Return_Year_5  '+total_Return_Year_5);
                System.debug('total_Return_Year_7  '+total_Return_Year_7);
                System.debug('total_Return_Year_10  '+total_Return_Year_10);
                
                Decimal total_Roi_Year_5  = 0;
                Decimal total_Roi_Year_7  = 0;
                Decimal total_Roi_Year_10 = 0;
                if(downPayment_Amount != null && total_Return_Year_5 != null && downPayment_Amount > 0)
                {
                    total_Roi_Year_5  = ((total_Return_Year_5 / downPayment_Amount) * 100).setScale(2);
                    total_Roi_Year_7  = ((total_Return_Year_7 / downPayment_Amount) * 100).setScale(2);
                    total_Roi_Year_10 = ((total_Return_Year_10/ downPayment_Amount) * 100).setScale(2);
                }                
                
                System.debug('total_Roi_Year_5  '+total_Roi_Year_5);
                System.debug('total_Roi_Year_7  '+total_Roi_Year_7);
                System.debug('total_Roi_Year_10  '+total_Roi_Year_10);
                
                project.Financing_5_Year_Expectations__c = total_Roi_Year_5;
                project.Financing_7_Year_Expectations__c = total_Roi_Year_7;
                project.Financing_10_Year_Expectations__c = total_Roi_Year_10;
                
                Decimal total_Expense_Per_Month =  math.ceil(calculateOneYearAmount(total_Expenses_Year_5, 5, (annual_Operating_Expense_Increase / 100)) / 12);
                System.debug('total_Expense_Per_Month '+total_Expense_Per_Month);
                
                Decimal maintenance_And_Repair_per_Month = 0;
                if(project.Rent_Assumption_for_Calculations__c != null && project.Maintenance_Rate__c != null){
                    maintenance_And_Repair_per_Month = (project.Rent_Assumption_for_Calculations__c * (project.Maintenance_Rate__c / 100)).setScale(2);
                }
                System.debug('maintenance_And_Repair_per_Month '+maintenance_And_Repair_per_Month);
                
                if(project.Rent_Assumption_for_Calculations__c != null && total_Expense_Per_Month != null && maintenance_And_Repair_per_Month != null && mortgage_Payment != null){
                    Project.Monthly_Cash_Flow__c= (project.Rent_Assumption_for_Calculations__c - total_Expense_Per_Month) + (maintenance_And_Repair_per_Month - mortgage_Payment);
                }
            }else if(project.Refresh__c){
                project.Refresh__c = false;
                if(String.isNotBlank(project.Market__c)){
                    if(marketMap.containsKey(project.Market__c))
                    {
                        if(marketMap.get(project.Market__c).Vacancy_Rate__c != null){
                            project.Vacancy_Rate__c = marketMap.get(project.Market__c).Vacancy_Rate__c;
                        }
                        
                        if(marketMap.get(project.Market__c).Maintenance_Rate__c != null){
                            project.Maintenance_Rate__c = marketMap.get(project.Market__c).Maintenance_Rate__c;
                        }
                        
                        if(marketMap.get(project.Market__c).Annual_Appreciation__c != null){
                            project.Appreciation_Rate__c = marketMap.get(project.Market__c).Annual_Appreciation__c;
                        }
                        
                        if(marketMap.get(project.Market__c).Vacancy_Rate__c != null){
                            project.Vacancy_Rate__c = marketMap.get(project.Market__c).Vacancy_Rate__c;
                        }
                        
                        if(marketMap.get(project.Market__c).Rental_Revenue_Appreciation__c != null){
                            project.Rental_Revenue_Appreciation__c = marketMap.get(project.Market__c).Rental_Revenue_Appreciation__c;
                        }
                        
                        if(marketMap.get(project.Market__c).Annual_Operating_Expense_Increase__c != null){
                            project.Annual_Operating_Expense_Increase__c = marketMap.get(project.Market__c).Annual_Operating_Expense_Increase__c;
                        }
                        if(project.Rent_Assumption_for_Calculations__c != null){
                            project.Estimated_Annual_Management_Fee_10__c =  project.Rent_Assumption_for_Calculations__c * 12 * 0.1;
                        }  
                        if(marketMap.get(project.Market__c).Downpayment__c != null){
                            project.Downpayment__c = marketMap.get(project.Market__c).Downpayment__c;
                        }  
                        if(marketMap.get(project.Market__c).Mortgage_Year__c != null){
                            project.Mortgage_Year__c = marketMap.get(project.Market__c).Mortgage_Year__c;
                        }  
                        if(marketMap.get(project.Market__c).Interest_Rate__c != null){
                            project.Interest_Rate__c = marketMap.get(project.Market__c).Interest_Rate__c;
                        }  
                        if(marketMap.get(project.Market__c).Property_Rate_by_Geography__c != null){
                            project.Property_Rate_by_Geography__c = marketMap.get(project.Market__c).Property_Rate_by_Geography__c;
                        }  
                        if(marketMap.get(project.Market__c).GL_Rate__c != null){
                            project.GL_Rate__c = marketMap.get(project.Market__c).GL_Rate__c;
                        }  
                        if(marketMap.get(project.Market__c).Umbrella_Rate__c != null){
                            project.Umbrella_Rate__c = marketMap.get(project.Market__c).Umbrella_Rate__c;
                        }  
                        if(marketMap.get(project.Market__c).Tech_Admin__c != null){
                            project.Tech_Admin__c = marketMap.get(project.Market__c).Tech_Admin__c;
                        }
                        if(marketMap.get(project.Market__c).Admin_Fees__c != null){
                            project.Admin_Fees__c = marketMap.get(project.Market__c).Admin_Fees__c;
                        }
                        if(marketMap.get(project.Market__c).Tax_Variable_For_GL_Tax__c != null){
                            project.GL_Tax__c = marketMap.get(project.Market__c).Tax_Variable_For_GL_Tax__c;
                        }
                        if(marketMap.get(project.Market__c).Tax_Variable_For_SL_Tax__c != null){
                            project.SL_Tax__c = marketMap.get(project.Market__c).Tax_Variable_For_SL_Tax__c;
                        }
                        if(marketMap.get(project.Market__c).Tax_Variable_For_UM_Tax__c != null){
                            project.UM_Tax__c = marketMap.get(project.Market__c).Tax_Variable_For_UM_Tax__c;
                        }
                        project.Downpayment_Amount__c = null;
                        project.PE_Loan_Amount__c = null;
                        project.PITI__c = null;
                        project.Monthly_Cash_Flow__c = null;
                        project.Financing_10_Year_Expectations__c = null;
                        project.Financing_5_Year_Expectations__c = null;
                        project.Financing_7_Year_Expectations__c = null;
                        project.Cash_Purchase_Estimated_Return_Year_10__c = null;
                        project.Cash_Purchase_Estimated_Return_Year_5__c = null;
                        project.Cash_Purchase_Estimated_Return_Year_7__c = null;
                    }
                }
            }
        }
    }
    
    
    public static void calculateInvestmentProperty1(List<Project__c> newList){
        for(Project__c project : newList){
            if(project.Calculate__c){
                Decimal askingPrice = project.Asking_Price__c; 
                Decimal downPayment_Amount = 0 ;
                
                if(project.Asking_Price__c != null)
                {
                    downPayment_Amount = project.Asking_Price__c;
                    project.Cash_Purchase_Downpayment_Amnt__c = downPayment_Amount;
                }
                System.debug('downPayment_Amount '+downPayment_Amount);
                
                Decimal finance_Amount = 0;
                if(askingPrice != null && downPayment_Amount != null)
                {
                    finance_Amount = askingPrice - downPayment_Amount;
                }
                System.debug('finance_Amount '+finance_Amount);
                
                if(finance_Amount != null)
                {
                    // project.PE_Loan_Amount__c = finance_Amount;
                }
                System.debug('project.PE_Loan_Amount__c '+project.PE_Loan_Amount__c);
                
                Decimal interestRate = 0;
                if(project.Interest_Rate__c != null)
                {
                    interestRate = project.Interest_Rate__c;
                }
                System.debug('interestRate '+interestRate);
                
                String mortgageYear = '';
                if(String.isNotBlank(project.Mortgage_Year__c)){
                    mortgageYear = project.Mortgage_Year__c;
                }
                System.debug('mortgageYear '+mortgageYear);
                
                Decimal mortgage_Payment = 0;
                if(finance_Amount != null && interestRate != null && String.isNotBlank(mortgageYear) && finance_Amount > 0 && interestRate > 0){
                    mortgage_Payment = ((finance_Amount * ((interestRate / 12 )/ 100)) * math.pow( double.valueOf((1+((interestRate/12) / 100))), double.valueOf((Integer.valueOf(mortgageYear)*12))) / (math.pow( double.valueOf((1+((interestRate /12 ) / 100))), double.valueOf((Integer.valueOf(mortgageYear)*12))) - 1 )).setScale(2);
                }
                System.debug('mortgage_Payment '+mortgage_Payment);
                
                if(mortgage_Payment != null){
                    //project.PITI__c =  mortgage_Payment; 
                }
                
                Decimal total_Rent_Per_Month = 0;
                if(project.Rent_Assumption_for_Calculations__c != null)
                {
                    total_Rent_Per_Month = project.Rent_Assumption_for_Calculations__c;
                }
                
                Decimal gross_Rent_Per_Year = 0;
                if(total_Rent_Per_Month != null)
                {
                    gross_Rent_Per_Year = total_Rent_Per_Month * 12;
                }
                
                Decimal vacancyRate = 0;
                if(project.Vacancy_Rate__c != null && project.Vacancy_Rate__c > 0)
                {
                    vacancyRate = (project.Vacancy_Rate__c / 100);
                }
                
                // Rates %
                Decimal annual_Appreciation = 0; 
                Decimal annual_Operating_Expense_Increase = 0;
                Decimal annual_Revenue_Increase = 0;
                
                if(project.Appreciation_Rate__c != null)
                {
                    annual_Appreciation = project.Appreciation_Rate__c / 100;
                }
                
                System.debug('annual_Appreciation '+annual_Appreciation);
                
                if(project.Annual_Operating_Expense_Increase__c != null){
                    annual_Operating_Expense_Increase = project.Annual_Operating_Expense_Increase__c; 
                }
                
                if(project.Rental_Revenue_Appreciation__c != null){
                    annual_Revenue_Increase = project.Rental_Revenue_Appreciation__c;
                }
                
                Decimal rental_Income_Year_5 = 0;
                Decimal rental_Income_Year_7 = 0;
                Decimal rental_Income_Year_10 = 0;
                
                Decimal vacany_Rate_Year_5 = 0;
                Decimal vacany_Rate_Year_7 = 0;
                Decimal vacany_Rate_Year_10 = 0;
                
                Decimal net_Rental_Income_Year_5 = 0;
                Decimal net_Rental_Income_Year_7 = 0;
                Decimal net_Rental_Income_Year_10 = 0;
                
                System.debug('annual_Appreciation  '+annual_Appreciation);
                System.debug('rent  '+project.Rent_Assumption_for_Calculations__c);
                
                if(project.Rent_Assumption_for_Calculations__c != null){
                    
                    rental_Income_Year_5 = math.ceil(calculateAmountYearWise((project.Rent_Assumption_for_Calculations__c * 12), 5, annual_Appreciation ));
                    vacany_Rate_Year_5 = (- math.ceil(rental_Income_Year_5 * vacancyRate )); 
                    net_Rental_Income_Year_5 = rental_Income_Year_5 + vacany_Rate_Year_5;
                    
                    rental_Income_Year_7 = math.ceil(calculateAmountYearWise(project.Rent_Assumption_for_Calculations__c * 12, 7, annual_Appreciation ));
                    vacany_Rate_Year_7 = (- math.ceil(rental_Income_Year_7 * vacancyRate )); 
                    net_Rental_Income_Year_7 = rental_Income_Year_7 + vacany_Rate_Year_7;
                    
                    rental_Income_Year_10 = math.ceil(calculateAmountYearWise(project.Rent_Assumption_for_Calculations__c * 12, 10, annual_Appreciation ));
                    vacany_Rate_Year_10 = (- math.ceil(rental_Income_Year_10 * vacancyRate )); 
                    net_Rental_Income_Year_10 = rental_Income_Year_10 + vacany_Rate_Year_10;
                }
                
                System.debug('rental_Income_Year_5  '+rental_Income_Year_5);
                System.debug('rental_Income_Year_7  '+rental_Income_Year_7);
                System.debug('rental_Income_Year_10  '+rental_Income_Year_10);
                
                System.debug('vacany_Rate_Year_5  '+vacany_Rate_Year_5);
                System.debug('vacany_Rate_Year_7  '+vacany_Rate_Year_7);
                System.debug('vacany_Rate_Year_10  '+vacany_Rate_Year_10);
                
                System.debug('net_Rental_Income_Year_5  '+net_Rental_Income_Year_5);
                System.debug('net_Rental_Income_Year_7  '+net_Rental_Income_Year_7);
                System.debug('net_Rental_Income_Year_10  '+net_Rental_Income_Year_10);
                
                Decimal property_Tax_Year_5 = 0;
                Decimal property_Tax_Year_7 = 0;
                Decimal property_Tax_Year_10 = 0;
                if(project.Estimated_Annual_Property_Taxes__c != null)
                { 
                    property_Tax_Year_5 = calculateAmountYearWise(project.Estimated_Annual_Property_Taxes__c, 5, (annual_Operating_Expense_Increase / 100));
                    property_Tax_Year_7 = calculateAmountYearWise(project.Estimated_Annual_Property_Taxes__c, 7, (annual_Operating_Expense_Increase / 100));
                    property_Tax_Year_10 = calculateAmountYearWise(project.Estimated_Annual_Property_Taxes__c, 10,( annual_Operating_Expense_Increase / 100));
                }
                
                System.debug('property_Tax_Year_5  '+property_Tax_Year_5);
                System.debug('property_Tax_Year_7  '+property_Tax_Year_7);
                System.debug('property_Tax_Year_10  '+property_Tax_Year_10);
                
                
                Decimal insurance_Year_5 = 0;
                Decimal insurance_Year_7 = 0;
                Decimal insurance_Year_10 = 0;
                if(project.Estimated_Annual_Home_owners_Insurance__c != null)
                {
                    insurance_Year_5 = calculateAmountYearWise(project.Estimated_Annual_Home_owners_Insurance__c, 5, (annual_Operating_Expense_Increase / 100));
                    insurance_Year_7 = calculateAmountYearWise(project.Estimated_Annual_Home_owners_Insurance__c, 7, (annual_Operating_Expense_Increase / 100));
                    insurance_Year_10 = calculateAmountYearWise(project.Estimated_Annual_Home_owners_Insurance__c, 10, (annual_Operating_Expense_Increase / 100));
                }
                
                System.debug('insurance_Year_5  '+insurance_Year_5);
                System.debug('insurance_Year_7  '+insurance_Year_7);
                System.debug('insurance_Year_10  '+insurance_Year_10);
                
                
                Decimal property_Management_Year_5 = 0;
                Decimal property_Management_Year_7 = 0;
                Decimal property_Management_Year_10 = 0;
                
                if(project.Estimated_Annual_Management_Fee_10__c != null)
                {
                    property_Management_Year_5 = calculateAmountYearWise(project.Estimated_Annual_Management_Fee_10__c, 5, (annual_Operating_Expense_Increase / 100));
                    property_Management_Year_7 = calculateAmountYearWise(project.Estimated_Annual_Management_Fee_10__c, 7, (annual_Operating_Expense_Increase / 100));
                    property_Management_Year_10 = calculateAmountYearWise(project.Estimated_Annual_Management_Fee_10__c, 10, (annual_Operating_Expense_Increase / 100));
                }
                
                System.debug('property_Management_Year_5  '+property_Management_Year_5);
                System.debug('property_Management_Year_7  '+property_Management_Year_7);
                System.debug('property_Management_Year_10  '+property_Management_Year_10);
                
                Decimal lease_Fee = 0;
                if(project.Rent_Assumption_for_Calculations__c != null)
                {
                    //lease_Fee = ((project.Rent_Assumption_for_Calculations__c * 2) / 10);
                }
                System.debug('lease_Fee  '+lease_Fee);
                
                Decimal hoa_Year_5 = 0;
                Decimal hoa_Year_7 = 0;
                Decimal hoa_Year_10 = 0;
                if(project.Estimated_Annual_HOA_Dues__c != null)
                {
                    hoa_Year_5 = calculateAmountYearWise(project.Estimated_Annual_HOA_Dues__c, 5, (annual_Operating_Expense_Increase / 100));
                    hoa_Year_7 = calculateAmountYearWise(project.Estimated_Annual_HOA_Dues__c, 7, (annual_Operating_Expense_Increase / 100));
                    hoa_Year_10 = calculateAmountYearWise(project.Estimated_Annual_HOA_Dues__c, 10, (annual_Operating_Expense_Increase / 100));
                }
                
                System.debug('hoa_Year_5  '+hoa_Year_5);
                System.debug('hoa_Year_7  '+hoa_Year_7);
                System.debug('hoa_Year_10  '+hoa_Year_10);
                
                Decimal maintenance_And_Repairs_Year_5 = 0;
                Decimal maintenance_And_Repairs_Year_7 = 0;
                Decimal maintenance_And_Repairs_Year_10 = 0;
                
                if(project.Rent_Assumption_for_Calculations__c != null && project.Maintenance_Rate__c != null )
                {
                    maintenance_And_Repairs_Year_5 = calculateAmountYearWise((project.Rent_Assumption_for_Calculations__c * (project.Maintenance_Rate__c / 100) * 12), 5, (annual_Operating_Expense_Increase / 100));
                    maintenance_And_Repairs_Year_7 = calculateAmountYearWise((project.Rent_Assumption_for_Calculations__c * (project.Maintenance_Rate__c / 100) * 12), 7, (annual_Operating_Expense_Increase / 100));
                    maintenance_And_Repairs_Year_10 = calculateAmountYearWise((project.Rent_Assumption_for_Calculations__c * (project.Maintenance_Rate__c / 100) * 12), 10, (annual_Operating_Expense_Increase / 100));
                }
                
                System.debug('maintenance_And_Repairs_Year_5  '+maintenance_And_Repairs_Year_5);
                System.debug('maintenance_And_Repairs_Year_7  '+maintenance_And_Repairs_Year_7);
                System.debug('maintenance_And_Repairs_Year_10  '+maintenance_And_Repairs_Year_10);
                
                Decimal total_Expenses_Year_5 = property_Tax_Year_5 + insurance_Year_5 + property_Management_Year_5 + lease_Fee + hoa_Year_5 +maintenance_And_Repairs_Year_5;
                Decimal total_Expenses_Year_7 = property_Tax_Year_7 + insurance_Year_7 + property_Management_Year_7 + lease_Fee + hoa_Year_7 +maintenance_And_Repairs_Year_7;
                Decimal total_Expenses_Year_10 = property_Tax_Year_10 + insurance_Year_10 + property_Management_Year_10 + lease_Fee + hoa_Year_10 +maintenance_And_Repairs_Year_10;
                
                System.debug('total_Expenses_Year_5  '+total_Expenses_Year_5);
                System.debug('total_Expenses_Year_7  '+total_Expenses_Year_7);
                System.debug('total_Expenses_Year_10  '+total_Expenses_Year_10);
                
                
                
                Decimal net_Operating_Income_Year_5 = net_Rental_Income_Year_5 - total_Expenses_Year_5;
                Decimal net_Operating_Income_Year_7 = net_Rental_Income_Year_7 - total_Expenses_Year_7;
                Decimal net_Operating_Income_Year_10 = net_Rental_Income_Year_10 - total_Expenses_Year_10;
                
                System.debug('net_Operating_Income_Year_5 '+net_Operating_Income_Year_5);
                System.debug('net_Operating_Income_Year_7 '+net_Operating_Income_Year_7);
                System.debug('net_Operating_Income_Year_10 '+net_Operating_Income_Year_10);
                
                
                
                Decimal mortgage = (mortgage_Payment * 12);
                
                System.debug('mortgage '+mortgage);
                
                Decimal total_Cash_Flow_Year_5 = net_Operating_Income_Year_5 - mortgage ;
                Decimal total_Cash_Flow_Year_7 = net_Operating_Income_Year_7 - mortgage ;
                Decimal total_Cash_Flow_Year_10 = net_Operating_Income_Year_10 - mortgage;
                
                System.debug('total_Cash_Flow_Year_5  '+total_Cash_Flow_Year_5);
                System.debug('total_Cash_Flow_Year_7  '+total_Cash_Flow_Year_7);
                System.debug('total_Cash_Flow_Year_10 '+total_Cash_Flow_Year_10);
                
                
                Decimal cash_Roi_Year_5 = 0;
                Decimal cash_Roi_Year_7 = 0;
                Decimal cash_Roi_Year_10 = 0;
                if(downPayment_Amount != null && downPayment_Amount > 0)
                {
                    cash_Roi_Year_5 = ((total_Cash_Flow_Year_5 / downPayment_Amount) * 100).setScale(2);
                    cash_Roi_Year_7 = ((total_Cash_Flow_Year_7 / downPayment_Amount) * 100).setScale(2);
                    cash_Roi_Year_10 = ((total_Cash_Flow_Year_10 / downPayment_Amount) * 100).setScale(2);
                }
                
                System.debug('cash_Roi_Year_5 '+cash_Roi_Year_5);
                System.debug('cash_Roi_Year_7 '+cash_Roi_Year_7);
                System.debug('cash_Roi_Year_10 '+cash_Roi_Year_10); 
                
                Decimal equity_Accrued_Year_5  = math.ceil(calculateRemainingAmount(finance_Amount, 12 * 4, ((interestRate/12).setScale(3) / 100), mortgage_Payment) - calculateRemainingAmount(finance_Amount, 12 * 5, ((interestRate/12).setScale(3) / 100), mortgage_Payment));
                Decimal equity_Accrued_Year_7  = math.ceil(calculateRemainingAmount(finance_Amount, 12 * 6, ((interestRate/12).setScale(3) / 100), mortgage_Payment) - calculateRemainingAmount(finance_Amount, 12 * 7, ((interestRate/12).setScale(3) / 100), mortgage_Payment));
                Decimal equity_Accrued_Year_10 = math.ceil(calculateRemainingAmount(finance_Amount, 12 * 9, ((interestRate/12).setScale(3) / 100), mortgage_Payment) - calculateRemainingAmount(finance_Amount,12 * 10,((interestRate/12).setScale(3) / 100), mortgage_Payment));
                
                System.debug('equity_Accrued_Year_5 '+equity_Accrued_Year_5);
                System.debug('equity_Accrued_Year_7 '+equity_Accrued_Year_7);
                System.debug('equity_Accrued_Year_10 '+equity_Accrued_Year_10);
                
                Decimal appreciation_Year_5 = 0;
                Decimal appreciation_Year_7 = 0;
                Decimal appreciation_Year_10 = 0;
                if(project.Asking_Price__c != null && project.Rental_Revenue_Appreciation__c != null)
                {
                    appreciation_Year_5 = calculateAmountYearWise(project.Asking_Price__c * (project.Rental_Revenue_Appreciation__c / 100), 5 , (project.Rental_Revenue_Appreciation__c / 100));
                    appreciation_Year_7 = calculateAmountYearWise(project.Asking_Price__c * (project.Rental_Revenue_Appreciation__c / 100), 7 , (project.Rental_Revenue_Appreciation__c / 100));
                    appreciation_Year_10 = calculateAmountYearWise(project.Asking_Price__c * (project.Rental_Revenue_Appreciation__c / 100), 10 , (project.Rental_Revenue_Appreciation__c / 100));
                }
                
                System.debug('appreciation_Year_5  '+appreciation_Year_5);
                System.debug('appreciation_Year_7  '+appreciation_Year_7);
                System.debug('appreciation_Year_10  '+appreciation_Year_10);
                
                Decimal total_Return_Year_5 = total_Cash_Flow_Year_5 + equity_Accrued_Year_5 + appreciation_Year_5;
                Decimal total_Return_Year_7 = total_Cash_Flow_Year_7 + equity_Accrued_Year_7 + appreciation_Year_7;
                Decimal total_Return_Year_10 = total_Cash_Flow_Year_10 + equity_Accrued_Year_10 + appreciation_Year_10;
                
                System.debug('total_Return_Year_5  '+total_Return_Year_5);
                System.debug('total_Return_Year_7  '+total_Return_Year_7);
                System.debug('total_Return_Year_10  '+total_Return_Year_10);
                
                Decimal total_Roi_Year_5  = 0;
                Decimal total_Roi_Year_7  = 0;
                Decimal total_Roi_Year_10 = 0;
                if(downPayment_Amount != null && total_Return_Year_5 != null && downPayment_Amount > 0)
                {
                    total_Roi_Year_5  = ((total_Return_Year_5 / downPayment_Amount) * 100).setScale(2);
                    total_Roi_Year_7  = ((total_Return_Year_7 / downPayment_Amount) * 100).setScale(2);
                    total_Roi_Year_10 = ((total_Return_Year_10/ downPayment_Amount) * 100).setScale(2);
                }                
                
                System.debug('total_Roi_Year_5  '+total_Roi_Year_5);
                System.debug('total_Roi_Year_7  '+total_Roi_Year_7);
                System.debug('total_Roi_Year_10  '+total_Roi_Year_10);
                
                project.Cash_Purchase_Estimated_Return_Year_5__c = total_Roi_Year_5;
                project.Cash_Purchase_Estimated_Return_Year_7__c = total_Roi_Year_7;
                project.Cash_Purchase_Estimated_Return_Year_10__c = total_Roi_Year_10;
                
                
                Decimal total_Expense_Per_Month =  math.ceil(calculateOneYearAmount(total_Expenses_Year_5, 5, (annual_Operating_Expense_Increase / 100)) / 12);
                System.debug('total_Expense_Per_Month '+total_Expense_Per_Month);
                
                Decimal maintenance_And_Repair_per_Month = 0;
                if(project.Rent_Assumption_for_Calculations__c != null && project.Maintenance_Rate__c != null){
                    maintenance_And_Repair_per_Month = (project.Rent_Assumption_for_Calculations__c * (project.Maintenance_Rate__c / 100)).setScale(2);
                }
                System.debug('maintenance_And_Repair_per_Month '+maintenance_And_Repair_per_Month);
                
                if(project.Rent_Assumption_for_Calculations__c != null && total_Expense_Per_Month != null && maintenance_And_Repair_per_Month != null && mortgage_Payment != null){
                    Project.Cash_Purchase_Monthly_Cashflow__c = (project.Rent_Assumption_for_Calculations__c - total_Expense_Per_Month) + (maintenance_And_Repair_per_Month - mortgage_Payment);
                }
            }
        }
    }
    
    
    
    public static decimal calculateAmountYearWise(Decimal yearAmount, Integer year, Decimal rate){
        if(yearAmount != null && year != null && rate != null){
            for(Integer i=1; i<year; i++){
                yearAmount += yearAmount * rate;
            }
            return math.ceil(yearAmount);
        }
        return null;
    }
    
    public static decimal calculateOneYearAmount(Decimal yearAmount, Integer year, Decimal rate){
        if(yearAmount != null && year != null && rate != null){
            for(Integer i=1; i<year; i++){
                yearAmount -= yearAmount * rate;
            }
            return math.ceil(yearAmount);
        }
        return null;
    }
    
    public static decimal calculateRemainingAmount(Decimal loan_Amount, Integer year, Decimal rate, Decimal monthly_Payment){
        if(loan_Amount != null && year != null && rate != null && monthly_Payment != null){
            for(Integer i=0; i<year; i++){
                loan_Amount -= ( monthly_Payment - (loan_Amount * rate)) ;
            }
            return loan_Amount;
        }
        return null;
    }
    
}