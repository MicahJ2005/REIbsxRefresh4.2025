/**
    Name        : TestDataFactory 
    Date        : Feb 13, 2019
    Author      : Shweta Fulara(Cmentor)
    Description : This test class is used as a Utility for createing data of numerous sObjects to refer in test classes.
**/
@isTest
public class TestDataFactory {
    
    public static Account createAccount(String name, Id recordTypeId, String accType) {
        Account acc = new Account(Name=name, RecordTypeId=recordTypeId
        );
        return acc;
    }
    
    public static Contact createContact(String firstName, String lastName, String phone, String email, Id accId, Id recordTypeId) {
        Contact con = new Contact(FirstName=firstName, LastName=lastName, AccountId=accId, Phone=phone, Email=email, RecordTypeId=recordTypeId);
        return con;
    }
    
    public static Case createCase(Id recordTypeId, String status, Id conId, Id houseId, String descr, String phone, DateTime contactDt, Boolean anytime, DateTime closedDt, String category) {
        Case cs= new Case(RecordTypeId=recordTypeId, Status=status, ContactId=conId, Property__c=houseId, Description= descr, SuppliedPhone= phone, 
                        Contact_Date__c=contactDt, Anytime__c=anytime, ClosedDate=closedDt, CategoryGlobal__c=category);
        return cs;
    }
    
    public static House__c createHouse(String name, String street1, String street2, 
        String city, String state, String zip, String country)
    {
        House__c house = new House__c(Name=name, Street_Address__c=street1,
            Street_Address_Line_2__c=street2, City__c=city, State__c=state,
            Zip_Code__c=zip, Country__c=country
        );
        return house;
    }
    
    //Standard or Custom Objects Data
    public static Lead createLead(String firstName, String lastName, String email, String phone, String mobilePhone){
        Lead lead = new Lead(FirstName=firstName, LastName=lastName, Email=email, Phone=phone, 
                             MobilePhone=mobilePhone);
        return lead;
    }
        
    //This is temporarily commented as this data and objects might not be available in LIVE environment for GO LIVE 1
    
    /*
    //Custom Settings data
    public static DuplicateComparisonFieldAPI__c createDupComareField(String name, String leadField, String conField, Integer sequence){
        DuplicateComparisonFieldAPI__c dupCompare = new DuplicateComparisonFieldAPI__c(Name=name, Lead_Field__c=leadField, 
                                                            Contact_Field__c=conField, Sequence__c=sequence);
        return dupCompare;
    }
    
    public static Selected_Property__c createSelectedProperty(Id leadId, Id oppId, Id houseId){
        Selected_Property__c selProperty = new Selected_Property__c(Lead__c= leadId, Opportunity__c = oppId, Property__c=houseId);
        return selProperty;
    }
    
    public static Management_Fee__c createMgmtFee(String name, String feeType, Id mgmtFeeGlId, Decimal flatFee, Decimal mgmtFee, String frequency, Boolean isLateFee){
        Management_Fee__c mgmtFeeObj = new Management_Fee__c(Name=name,Fee_Type__c=feeType,MI_Fee_GL_Account__c=mgmtFeeGlId,
            Flat_Fee__c= flatFee, Frequency__c=frequency,MI_Fee__c=mgmtFee,Late_Fee__c=isLateFee
        );
        return mgmtFeeObj;
    }
    
    public static Property_Management_Fee__c createPropertyMgmtFee(String name, Id houseId, Id mgmtFeeGlId, Id mgmtFeeId, Id leaseId){
        Property_Management_Fee__c propertyMgmtFee = new Property_Management_Fee__c(Name=name, Property__c=houseId,MI_Fee_GL_Account__c=mgmtFeeGlId,
                                                                Management_Fee_Detail__c=mgmtFeeId,Lease__c = leaseId);
        return propertyMgmtFee;
    }
    
    public static Opportunity createOpportunity(Id accId, String name, String stage, Date closedDt, Id recordTypeId) {
        Opportunity opp = new Opportunity(AccountId=accId, Name=name, StageName=stage, CloseDate=closedDt, RecordTypeId=recordTypeId);
        return opp;
    }
    
    public static OpportunityContactRole createOppConRole(Id oppId, Id conId, boolean isPrimary){
        OpportunityContactRole oppConRole = new OpportunityContactRole(OpportunityId=oppId, ContactId=conId, IsPrimary=isPrimary);
        return oppConRole;
    }
    
    
    
    public static Property_Owner__c createPropertyOwner(Id accId, Id houseId, Decimal share, String status) {
        Property_Owner__c propertyOwner = new Property_Owner__c(Account__c =accId, Property__c=houseId, 
            Share__c=share, Status__c=status
        );
        return propertyOwner;
    }
    
    public static Lease__c createLease(String name, Id houseId, Id oppId, String status) 
    {
        Lease__c lease = new Lease__c(Name=name, Location__c = houseId, Opportunity__c=oppId, Status__c= status);
        return lease;
    }
    
    public static Project__c createProject(Id houseId, String category, String descr, Id accId, Id csId, Id recordTypeId, String source, Date createdDt, Date closedDt){
        Project__c project = new Project__c(House__c=houseId, CategoryGlobal__c=category, Description__c=descr, Account__c= accId,
                                                   Case__c=csId, RecordTypeId=recordTypeId, Source__c=source, Date_Created__c=createdDt,Date_Closed__c=closedDt);
        return project;
    }
    
    public static Project_Item__c createProjectItem(Id projectId, String category, String descr, String status){
        Project_Item__c projectItem = new Project_Item__c(Project__c=projectId, CategoryGlobal__c =category, Description__c=descr, Status__c=status);
        return projectItem;
    }
    
    // Accounting Data
    public static AcctSeed__Accounting_Period__c createAccountingPeriod(Date startDt, Date endDt, String name){
        AcctSeed__Accounting_Period__c acctPeriod = new AcctSeed__Accounting_Period__c(AcctSeed__Start_Date__c =startDt, AcctSeed__End_Date__c =endDt, Name=name);
        return acctPeriod;
    }
    
    public static AcctSeed__GL_Account__c createGlAccount(String name, Boolean isActive, String type, Boolean isBank, String subType1, String subType2){
        AcctSeed__GL_Account__c bankAcc = new AcctSeed__GL_Account__c(Name = name, AcctSeed__Active__c = isActive, AcctSeed__Type__c = type, AcctSeed__Bank__c = isBank,
            AcctSeed__Sub_Type_1__c = subType1, AcctSeed__Sub_Type_2__c = subType2);
        return bankAcc;
    }
    
    public static AcctSeed__Billing_Format__c createBillFormat(String name, String vfPage, String emailTemplateName, String type, String sortField, String replyEmail){
        AcctSeed__Billing_Format__c billFormat = new AcctSeed__Billing_Format__c(Name = name, AcctSeed__Visualforce_PDF_Page__c = vfPage,
                AcctSeed__Default_Email_Template__c = emailTemplateName, AcctSeed__Type__c = type, AcctSeed__Sort_Field__c = sortField, 
                AcctSeed__ReplyTo_Email__c = replyEmail);
        return billFormat;
    }
    
    public static AcctSeed__Ledger__c createLedger(String name, String type, Id bankGlAccId, Id billFormatId, Id outstandingStmntId, Id activityStmntId, Id poFormatId, Id packSlipId){
        AcctSeed__Ledger__c ledger= new AcctSeed__Ledger__c(Name = name, AcctSeed__Type__c = type, AcctSeed__Default_Bank_Account__c = bankGlAccId,
                AcctSeed__Default_Billing_Format__c = billFormatId, AcctSeed__Billing_Outstanding_Statement_Format__c = outstandingStmntId,
                AcctSeed__Billing_Activity_Statement_Format__c = activityStmntId, AcctSeed__Default_Purchase_Order_Format__c = poFormatId,
                AcctSeed__Default_Packing_Slip_Format__c  = packSlipId);
        return ledger;
    }
    
    public static AcctSeed__Accounting_Variable__c createAcctVariable(String name, Boolean isActive, String type){
        AcctSeed__Accounting_Variable__c variable1 = new AcctSeed__Accounting_Variable__c(
            Name=name, AcctSeed__Active__c= isActive, AcctSeed__Type__c=type
        );
        return variable1;
    }
    
    public static AcctSeed__Accounting_Settings__c createAcctSettings(Id glId, Id glAccountId, Id billingASId, Id billingOSId, Id ledgerId, Id billingFormatId){
        AcctSeed__Accounting_Settings__c accSetting = new AcctSeed__Accounting_Settings__c(
            AcctSeed__AP_Control_GL_Account__c = glId, AcctSeed__AR_Control_GL_Account__c = glId,
            AcctSeed__Billing_Activity_Statement_Format__c = billingASId, AcctSeed__Billing_Outstanding_Statement_Format__c = billingOSId,
            AcctSeed__Revenue_GL_Account__c = glId, AcctSeed__Current_Year_Earnings_GL_Account__c = glAccountId, 
            AcctSeed__Default_Bank_Account__c = glAccountId, AcctSeed__Default_Ledger__c = ledgerId, AcctSeed__Retained_Earnings_GL_Account__c = glAccountId, 
            AcctSeed__Unapplied_Cash_GL_Account__c = glId, AcctSeed__Default_Billing_Format__c = billingFormatId
        );

        return accSetting;
    }
    
    public static AcctSeed__Accounting_Settings__c createNewAcctSettings(List<AcctSeed__GL_Account__c> glAccounts, Id billingASId, Id billingOSId, Id ledgerId, Id billingFormatId){
        AcctSeed__Accounting_Settings__c accSetting = new AcctSeed__Accounting_Settings__c(
            AcctSeed__AR_Control_GL_Account__c = glAccounts[2].Id,
                AcctSeed__AP_Control_GL_Account__c = glAccounts[4].Id,
                AcctSeed__Labor_GL_Account__c = glAccounts[19].Id,
                AcctSeed__Payment_Discount_GL_Account__c = glAccounts[14].Id,
                AcctSeed__Unapplied_Cash_GL_Account__c = glAccounts[1].Id,
                AcctSeed__Retained_Earnings_GL_Account__c = glAccounts[8].Id,
                AcctSeed__Default_Ledger__c = ledgerId,
                AcctSeed__Default_Bank_Account__c = glAccounts[0].Id,
                AcctSeed__Revenue_GL_Account__c = glAccounts[10].Id,
                AcctSeed__Default_Project_Task_Labor_GL_Account__c = glAccounts[20].Id,
                AcctSeed__Default_Billing_Format__c = billingFormatId,
                AcctSeed__Billing_Outstanding_Statement_Format__c = billingOSId,
                AcctSeed__Billing_Activity_Statement_Format__c = billingASId,                          
                AcctSeed__Current_Year_Earnings_GL_Account__c = glAccounts[9].Id,
                AcctSeed__Enable_Product_Costing__c = true,
                AcctSeed__Work_in_Process_GL_Account__c = glAccounts[3].Id,
                AcctSeed__Vouchers_Payable_GL_Account__c = glAccounts[5].Id,
                AcctSeed__Inventory_Variance_GL_Account__c =  glAccounts[13].Id,
                AcctSeed__Customer_Payment_Adjustment_GL_Account__c = glAccounts[21].Id,
                AcctSeed__Display_Billable_Flag_in_Time_Card_Entry__c = true,
                AcctSeed__Enable_Billing_Period_Sensitive_Aging__c = true,
                AcctSeed__Enable_AP_Period_Sensitive_Aging__c = true
        );

        return accSetting;
    }
    
    public static AcctSeed__Billing__c createBilling(Id accId, Id objAccountingPeriodId, Id billingFormatId, Id oppId, Id ledgerId, Id leaseId, Id houseId, Id conId, Date dt, Decimal lateFee, String status, Date dueDt){
        AcctSeed__Billing__c billing = new AcctSeed__Billing__c(AcctSeed__Customer__c = accId, AcctSeed__Accounting_Period__c = objAccountingPeriodId, 
            AcctSeed__Billing_Format__c = billingFormatId, AcctSeed__Opportunity__c = oppId, AcctSeed__Ledger__c = ledgerId, Lease__c = leaseId, 
            House__c = houseId, AcctSeed__Billing_Contact__c = conId, AcctSeed__Date__c = dt, Late_Fees__c = lateFee, AcctSeed__Status__c = status,
            AcctSeed__Due_Date2__c = dueDt
        );
        return billing;
    }
    
    public static AcctSeed__Billing_Line__c createBillingLine(Id objBillingId, Decimal rate, Integer hrUnit, Id revenueGlId, Date dt){
        AcctSeed__Billing_Line__c billingLine = new AcctSeed__Billing_Line__c(AcctSeed__Billing__c = objBillingId, 
            AcctSeed__Rate__c = rate, AcctSeed__Hours_Units__c = hrUnit, AcctSeed__Revenue_GL_Account__c = revenueGlId, AcctSeed__Date__c = dt
        );
        return billingLine;
    }
    
    public static AcctSeed__Account_Payable__c createPayable(Id houseId, Id objAccountingPeriodId, Id conId, String payRef, Date dt, Id ledgerId, Id projectItemId){
        AcctSeed__Account_Payable__c payable = new AcctSeed__Account_Payable__c(House__c=houseId, AcctSeed__Accounting_Period__c=objAccountingPeriodId,
                                                    AcctSeed__Contact__c=conId, AcctSeed__Payee_Reference__c=payRef,
                                                    AcctSeed__Date__c=dt, AcctSeed__Ledger__c=ledgerId, Project_Item__c=projectItemId);
        return payable;
    }
    
    public static AcctSeed__Account_Payable_Line__c createPayableLine(Id payableId, Id expenseGlId, Decimal amount, Integer quantity, Id glVar1Id, Date dt, Id glVar2Id){
        AcctSeed__Account_Payable_Line__c payableLine = new AcctSeed__Account_Payable_Line__c(AcctSeed__Account_Payable__c=payableId,
            AcctSeed__Expense_GL_Account__c=expenseGlId,AcctSeed__Amount__c=amount,
            AcctSeed__Quantity__c=quantity,AcctSeed__GL_Account_Variable_1__c=glVar1Id, AcctSeed__Date__c=dt,AcctSeed__GL_Account_Variable_2__c=glVar2Id 
        );
        return payableLine;
    }
    
    public static AcctSeed__Cash_Receipt__c createCashReceipt(Id accId, Id conId, String status, Date receiptDt, String payRef, Decimal amount, Id leaseId, String paymentType, Id creditGlId, Id oppId, Id ledgerId, Id bankGlId){
        AcctSeed__Cash_Receipt__c cashReceipt = new AcctSeed__Cash_Receipt__c(
            AcctSeed__Account__c = accId, Contact__c = conId, AcctSeed__Status__c = status,
            AcctSeed__Receipt_Date__c = receiptDt, AcctSeed__Payment_Reference__c = payRef,
            AcctSeed__Amount__c = amount,Lease__c=leaseId, Payment_Type__c = paymentType, AcctSeed__Credit_GL_Account__c = creditGlId,
            Opportunity__c = oppId,AcctSeed__Ledger__c = ledgerId,AcctSeed__Bank_Account__c = bankGlId
        );
        return cashReceipt;
    }
    
    public static AcctSeed__Billing_Cash_Receipt__c createBillingCashReceipt(Id cashReceiptId, Id billId, Id objAccountingPeriod, Decimal appliedAmt, Id billLineId){
        AcctSeed__Billing_Cash_Receipt__c billingCashReceipt = new AcctSeed__Billing_Cash_Receipt__c(
            AcctSeed__Cash_Receipt__c = cashReceiptId, AcctSeed__Billing__c = billId, AcctSeed__Accounting_Period__c = objAccountingPeriod,
            AcctSeed__Applied_Amount__c = appliedAmt, Billing_Line__c = billLineId
        );
        return billingCashReceipt;
    }
    
    public static AcctSeed__Cash_Disbursement_Batch__c createCDBatch(String name){
        AcctSeed__Cash_Disbursement_Batch__c cdBatch = new AcctSeed__Cash_Disbursement_Batch__c(name=name);
        return cdBatch;
    }
    
    public static AcctSeed__Cash_Disbursement__c createCashDisburse(Id cdBatchId, String payRef, Decimal amount, Id debitGlId, Date disburseDt, Id glVar1Id, Id glVar2Id, Id bankAccId, Id ledgerId, Id oppId, Id houseId, Id leaseId, Id conId){
        AcctSeed__Cash_Disbursement__c cashDisburse = new AcctSeed__Cash_Disbursement__c(AcctSeed__Cash_Disbursement_Batch__c=cdBatchId,
            AcctSeed__Reference__c=payRef, AcctSeed__Amount__c=amount,
            AcctSeed__Debit_GL_Account__c=debitGlId, AcctSeed__Disbursement_Date__c=disburseDt,
            AcctSeed__GL_Account_Variable_1__c=glVar1Id, AcctSeed__GL_Account_Variable_2__c=glVar2Id, 
            AcctSeed__Bank_Account__c=bankAccId, AcctSeed__Ledger__c = ledgerId, 
            Opportunity__c = oppId, House__c = houseId, Lease__c= leaseId, AcctSeed__Contact__c=conId
        );
        return cashDisburse;
    }
    */
}