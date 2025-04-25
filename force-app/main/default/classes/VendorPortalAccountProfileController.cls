public without sharing class VendorPortalAccountProfileController{
    
    //public List<Account> accProfileList{get;set;} 
    public List<MarketWrapper> marketWrapList{get;set;}
    public List<RehabTradeWrapper> lst_rehabContractorTrades{get;set;}
    public List<RehabTradeWrapper> lst_maintenanceProviderTrades{get;set;} 
    //public Account currentProfileAccount{get;set;}
    //public Contact primaryContact{get;set;}
    public ContactWrapper wrapperObj{get;set;}
    public set<id> deleteContactIdSet{get;set;}
    public Id currentUserContactId;
    public Id currentUserAccountId;
    public id ContactRollId;
    //Attachment section
    public String attachTypeVal{get;set;}
    public String error{get;set;}
    public String noerror{get;set;}
    public boolean bypassValidation{get;set;}
    public List<Id> attachmentIdList;
    public Id attachId{get;set;}
    public List<ContentWrapper> cvWrapList{get;set;}
    public List<ContentWrapper> cvWrapAdditionalList{get;set;}
    public Id selectedContentId{get;set;}
    public set<id> deleteContentDocumentSet{get;set;}
    public ContentVersion conversion {get;set;}
    public Date expireDt{get;set;}
    public String expirationDate {get;set;}
    public Map<String,String> langconvertMap{get;set;}
    public Boolean langRehabContractorCheck{get;set;}
    public Boolean isSave{get;set;}
    public Boolean attachmentCheck{get;set;}
    public String ITINString{get;set;}
    public String marketString{get;set;}
    public String rehabCatString{get;set;}
    public String maintCatString{get;set;}
    public String tinNum{get;set;}
    
    Set<String> attachTypesToAdd;
    Set<String> attachTypesToAddTemp;
    
    Boolean isUploaded;
    Boolean isDDAUploaded;
    Boolean isVCUploaded;
    Boolean isLicenseUploaded;
    Boolean isPermitsUploaded;
    //Shipping Address Copy In Billing Address
    public boolean shippingAddressCheck{get;set;}
    public Boolean isFieldDisabled{get;set;}
    
    public VendorPortalAccountProfileController() {
        shippingAddressCheck = false;
        isUploaded = false;
        isDDAUploaded = false;
        isVCUploaded = false;
        isLicenseUploaded = false;
        isPermitsUploaded = false;
        marketString = '';
        rehabCatString = '';
        maintCatString = '';
        attachmentCheck = false;
        langRehabContractorCheck = false;
        isSave = false;
        expireDt = null;
        expirationDate = null;
        attachTypeVal = '';  
        tinNum = '';
        wrapperObj = new ContactWrapper();
        deleteContactIdSet = new set<id>();
        conversion = new ContentVersion();  
        attachmentIdList = new List<Id>(); 
        cvWrapList = new List<ContentWrapper>();
        cvWrapAdditionalList = new List<ContentWrapper>();
        attachTypesToAdd = new Set<String>();
        attachTypesToAddTemp = new Set<String>();
        deleteContentDocumentSet = new set<id>();
        marketWrapList = new List<MarketWrapper>();
        lst_rehabContractorTrades = new List<RehabTradeWrapper>();
        lst_maintenanceProviderTrades = new List<RehabTradeWrapper>();       
        langconvertMap = new Map<String,String>();
        isFieldDisabled = false;
        
        string userType  = UserInfo.getUserType();
        
        if(!(userType == 'CspLitePortal' || userType == 'CustomerSuccess')) { isFieldDisabled = true;
        }
        
        List<User> usrList = [SELECT Id, AccountId__c,Account.Business_Type__c,ContactId FROM User WHERE Id=: UserInfo.getUserId()];       
        if(!usrList.isEmpty()) {       
            currentUserContactId = usrList[0].ContactId;
            currentUserAccountId = usrList[0].AccountId__c;    
        }        
        
        
        conAccountMethod();
        EnglishLangChange();
        
        System.debug('cvWrapList-----'+cvWrapList);
        
    }  
    
    //English langvage Method
    public pageReference EnglishLangChange() {
        langRehabContractorCheck = false;
        attachmentCheck = false;
        ITINString = 'An ITIN, or Individual Taxpayer Identification Number, is a tax processing number only available for certain nonresident and resident aliens, their spouses, and dependents who cannot get a Social Security Number (SSN). It is a 9-digit number, beginning with the number "9", formatted like an SSN (NNN-NN-NNNN).';
        lst_rehabContractorTrades = rehabContractorTrades();
        lst_maintenanceProviderTrades = maintenanceProviderTrades();               
        langconvertMap = new Map<String,String>();
        for (Language_Converter__mdt iter: [Select DeveloperName, MasterLabel, English__c, Spanish__c From Language_Converter__mdt]) {            
            if(iter.MasterLabel.containsIgnoreCase('Profile')) {                                                    
                langconvertMap.put(iter.English__c,iter.English__c);                                
            }            
        }
        //langconvertMap.put('The Primary Contact will have the authority to change, modify, or create new Contacts, Banking Information, Business Address & Phone Numbers, along with all filed documents to this Vendor Master Record. Please carefully consider the Primary Contact assignment.', SpanishUtil.primaryConInfo('The Primary Contact will have the authority to change, modify, or create new Contacts, Banking Information, Business Address & Phone Numbers, along with all filed documents to this Vendor Master Record. Please carefully consider the Primary Contact assignment.'));
        attachFileFunction();
        return null;
    }
    
    //Spanish langvage Method
    public pageReference SpanishLangChange() {
        langRehabContractorCheck = true;
        attachmentCheck = true; 
        ITINString = 'Un ITIN, o Número de Identificación de Contribuyente Individual, es un número de procesamiento de impuestos solo disponible para ciertos extranjeros residentes y no residentes, sus cónyuges y dependientes que no pueden obtener un Número de Seguro Social (SSN). Es un número de 9 dígitos, que comienza con el número "9", formateado como un SSN (NNN-NN-NNNN).';
        lst_rehabContractorTrades = rehabContractorTrades();
        lst_maintenanceProviderTrades = maintenanceProviderTrades();                   
        langconvertMap = new Map<String,String>();
        for (Language_Converter__mdt iter: [Select DeveloperName, MasterLabel, English__c, Spanish__c From Language_Converter__mdt]) {            
            if(iter.MasterLabel.containsIgnoreCase('Profile')) {                                     
                langconvertMap.put(iter.English__c,iter.Spanish__c);                                
            }            
        }
        //langconvertMap.put('The Primary Contact will have the authority to change, modify, or create new Contacts, Banking Information, Business Address & Phone Numbers, along with all filed documents to this Vendor Master Record. Please carefully consider the Primary Contact assignment.', SpanishUtil.primaryConInfo('The Primary Contact will have the authority to change, modify, or create new Contacts, Banking Information, Business Address & Phone Numbers, along with all filed documents to this Vendor Master Record. Please carefully consider the Primary Contact assignment.'));
        attachFileFunction();    
        rehabCatValues();
        maintCatValues();    
        return null;
    }  
    
    
    public List<SelectOption> getDepartment(){
        List<SelectOption> optionsCon = new List<SelectOption>();
        if(langRehabContractorCheck) {           
            optionsCon.add(new SelectOption('--None--', '--None--'));
            optionsCon.add(new SelectOption('Administration', 'Administración'));
            optionsCon.add(new SelectOption('Accounting', 'Contabilidad'));
            optionsCon.add(new SelectOption('Dispatching', 'Despacho'));
            optionsCon.add(new SelectOption('Executive/Management', 'Ejecutivo/Gerencia'));
            optionsCon.add(new SelectOption('Operations', 'Operaciones')); 
        } else {            
            Schema.DescribeFieldResult fieldResult = Contact.Department__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry f : ple)
            {
                optionsCon.add(new SelectOption(f.getLabel(),f.getValue()));
            }
        }
        return optionsCon;
    } 
    
    public void conAccountMethod() {
        
        for(Account acc : [SELECT Id,Name,Website, Type, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode,
                           BillingStreet, BillingCity, BillingState, BillingPostalCode, Billing_Email__c,
                           Primary_Contact_Email__c,
                           Approval_Status__c, Vendor_Email__c,Phone, Market__c,Temp_Market__c,
                           Rehab_Contractor_Trade_s__c , Category_1__c, 
                           Maint_Category_1__c, Property_Maintenance_Trade_s__c, Taxpayer_Identification_Number__c,
                           Account_Type__c, Account_Number__c,Routing_Number__c, Bank_Name__c, Legal_Acknowledgment__c,
                           Business_Name__c, Is_Uploaded__c,Status__c,
                           Home_Depot_Rapid_Pass_Acknowledgement__c, License__c
                           FROM Account WHERE Id =: currentUserAccountId]) 
        {            
            wrapperObj.accWrap = acc;    
            tinNum = wrapperObj.accWrap.Taxpayer_Identification_Number__c;
            wrapperObj.accWrap.Legal_Acknowledgment__c = false;
            wrapperObj.accWrap.Temp_Market__c = acc.Market__c;
            wrapperObj.accWrap.Rehab_Contractor_Trade_s__c = acc.Category_1__c;
            wrapperObj.accWrap.Property_Maintenance_Trade_s__c = acc.Maint_Category_1__c;
        } 
        
        marketWrapList = marketList();
        lst_rehabContractorTrades = rehabContractorTrades();
        lst_maintenanceProviderTrades = maintenanceProviderTrades();       
        
        integer count = 0;
        
        for(Contact con: [SELECT Id,Name,AccountId,Is_Primary__c,LastName,FirstName,SSN__c,Department__c,Phone,HomePhone,MobilePhone,Email,MailingStreet,MailingCity, MailingState,MailingPostalCode,MailingCountry FROM Contact WHERE  AccountId =: currentUserAccountId]) {                     
            if(con.Is_Primary__c) {
                wrapperObj.primaryConWrap = con;             
            }
            else if(isFieldDisabled == false || (isFieldDisabled == true && count <5)){ 
                wrapperObj.conListWrap.add(con);
                count++;
            }             
        } 
        
        if(wrapperObj.conListWrap.size() <= 0) { wrapperObj.conListWrap.add(new Contact());
        }                  
    }
    
    public List<MarketWrapper> marketList(){        
        
        List<SelectOption> options = new List<SelectOption>();        
        options.add(new SelectOption('MEM', 'Memphis, TN')); 
        options.add(new SelectOption('SAN', 'San Antonio, TX')); 
        options.add(new SelectOption('STL', 'St. Louis, MO'));
        options.add(new SelectOption('DFW', 'Dallas - Ft. Worth, TX'));
        options.add(new SelectOption('HOU', 'Houston, TX'));
        options.add(new SelectOption('LIT', 'Little Rock, AR'));
        options.add(new SelectOption('OKC', 'Oklahoma City, OK'));
        options.add(new SelectOption('TUL', 'Tulsa, OK'));
        options.add(new SelectOption('BHM', 'Birmingham, AL'));
        options.add(new SelectOption('HSV', 'Huntsville, AL'));
        /* 05/07/2021 - Isaac A. Huicochea
			Adding new markets
		*/
        options.add(new SelectOption('TUS', 'Tuscaloosa, AL'));
        options.add(new SelectOption('TLH', 'Tallahassee, FL'));
        options.add(new SelectOption('JKT', 'Jackson, TN'));
        options.add(new SelectOption('JAN', 'Jackson, MS'));
        options.add(new SelectOption('CHA', 'Chattanooga, TN'));
        options.add(new SelectOption('AUS', 'Austin, TX'));
        options.add(new SelectOption('BNA', 'Nashville, TN'));
        

        for(SelectOption  f : options)
        {
            MarketWrapper wrap = new MarketWrapper(false, f.getLabel(), f.getValue());
            if(String.isNotBlank(wrapperObj.accWrap.Market__c)){
                if(wrapperObj.accWrap.Market__c.contains(wrap.value)){
                    if(String.isBlank(marketString)){
                        marketString = wrap.label;
                    }
                    else{
                        marketString += ';' + wrap.label;
                    }
                    wrap.isSelected = true;
                }
            }
            marketWrapList.add(wrap);
        }        
        return marketWrapList;
    }
    
    
    //This method is used to add a new row on the VF Page.
    public void addWrapperRow(){              
        wrapperObj.conListWrap.add(new Contact());        
    }
    
    //This method is used to remove a row from the VF page.
    public void removeWrapperRow() {    
        Integer listIndex = Integer.valueOf(ApexPages.currentPage().getParameters().get('listIndex'));
        
        if(wrapperObj.conListWrap.size() > listIndex) {
            if(wrapperObj.conListWrap[listIndex].id != null) {                 
                deleteContactIdSet.add(wrapperObj.conListWrap[listIndex].id);                
            }
            wrapperObj.conListWrap.remove(listIndex);
        }                 
    }
    
    //Shipping Address Copy In Billing Address
    public void shippingAddressCopy() {
        
        if(shippingAddressCheck) { 
            wrapperObj.accWrap.BillingStreet = wrapperObj.accWrap.ShippingStreet;
            wrapperObj.accWrap.BillingCity = wrapperObj.accWrap.ShippingCity;
            wrapperObj.accWrap.BillingState = wrapperObj.accWrap.ShippingState;
            wrapperObj.accWrap.BillingPostalCode = wrapperObj.accWrap.ShippingPostalCode;
            wrapperObj.accWrap.Billing_Email__c = wrapperObj.accWrap.Vendor_Email__c;                
        } else {
            wrapperObj.accWrap.BillingStreet = null;
            wrapperObj.accWrap.BillingCity = null;
            wrapperObj.accWrap.BillingState = null;
            wrapperObj.accWrap.BillingPostalCode = null;
            wrapperObj.accWrap.Billing_Email__c = null;
        }
        
    }
    
    public void marketValues(){
        marketString = '';
        for(MarketWrapper wrp: marketWrapList){
            if(wrp.isSelected){
                if(String.isBlank(marketString)){
                    marketString = wrp.label;
                }
                else{
                    marketString += ';' + wrp.label;
                }
            }
        }
        createReqDocTable();
    }
    
    public void rehabCatValues(){
        rehabCatString = '';
        for(RehabTradeWrapper wrp: lst_rehabContractorTrades){
            if(wrp.isSelected){
                if(String.isBlank(rehabCatString)){
                    rehabCatString = langRehabContractorCheck ? wrp.label : wrp.value;
                }
                else{
                    rehabCatString += ';' + (langRehabContractorCheck ? wrp.label : wrp.value);
                }
            }
        }
        System.debug('rehabCatString-----'+rehabCatString);
        createReqDocTable();
    }
    
    public void maintCatValues(){
        maintCatString = '';
        for(RehabTradeWrapper wrp: lst_maintenanceProviderTrades){
            if(wrp.isSelected){
                if(String.isBlank(maintCatString)){
                    maintCatString = langRehabContractorCheck ? wrp.label : wrp.value;
                }
                else{
                    maintCatString += ';' + (langRehabContractorCheck ? wrp.label : wrp.value);
                }
            }
        }
        createReqDocTable();
    }
    
    public void callMethod() {
    }
    
    public void callMethodNew() {
        
        rehabCatString = '';
        maintCatString = '';
        if(wrapperObj.accWrap.Type == 'Rehab'){
            for(RehabTradeWrapper wrp: lst_maintenanceProviderTrades){
                wrp.isSelected = false;
            }
        }
        else if(wrapperObj.accWrap.Type == 'Maintenance'){ for(RehabTradeWrapper wrp: lst_rehabContractorTrades){ wrp.isSelected = false;
            }
        }
        System.debug('rehabCatString-----'+rehabCatString);
        if(wrapperObj.accWrap.Type == 'Rehab & Maintenance' || wrapperObj.accWrap.Type == 'Rehab'){
            if(!lst_rehabContractorTrades.isEmpty()){
                for(RehabTradeWrapper wrp: lst_rehabContractorTrades){
                    if(String.isNotBlank(wrapperObj.accWrap.Category_1__c)){
                        if(wrapperObj.accWrap.Category_1__c.contains(wrp.value)){
                            if(String.isBlank(rehabCatString)){
                                rehabCatString = langRehabContractorCheck ? SpanishUtil.spanishRehabTradeVal(wrp.value) : wrp.value;
                            }
                            else{
                                rehabCatString += ';' + (langRehabContractorCheck ? SpanishUtil.spanishRehabTradeVal(wrp.value) : wrp.value);
                            }
                            wrp.isSelected = true;
                        }
                    }
                }
            }
        } 
        System.debug('rehabCatString-----'+rehabCatString);
        if(wrapperObj.accWrap.Type == 'Rehab & Maintenance' || wrapperObj.accWrap.Type == 'Maintenance'){    
            if(!lst_maintenanceProviderTrades.isEmpty()){
                for(RehabTradeWrapper wrp: lst_maintenanceProviderTrades){
                    if(String.isNotBlank(wrapperObj.accWrap.Maint_Category_1__c)){
                        if(wrapperObj.accWrap.Maint_Category_1__c.contains(wrp.value)){
                            if(String.isBlank(maintCatString)){
                                maintCatString = langRehabContractorCheck ? SpanishUtil.spanishRehabTradeVal(wrp.value) : wrp.value;
                            }
                            else{
                                maintCatString += ';' + (langRehabContractorCheck ? SpanishUtil.spanishRehabTradeVal(wrp.value) : wrp.value);
                            }
                            wrp.isSelected = true;
                        }
                    }
                }
            } 
        }
        createReqDocTable();
    }
    public PageReference submitForm() {
        bypassValidation = true;
        return doSubmitVendorProfile();
        //return null;
    }
    // This method is used to update vender profile account and upsert contact.
    public PageReference doSubmitVendorProfile() {
        //system.assert(false, wrapperObj.accWrap.Category_1__c + '@@' + wrapperObj.accWrap.Maint_Category_1__c);
        error = '';
        
        List<Address_Verifier__c> addressList = new List<Address_Verifier__c>();
        
        if(String.isNotBlank(wrapperObj.accWrap.ShippingCity) && (String.isNotBlank(wrapperObj.accWrap.ShippingState) || String.isNotBlank(wrapperObj.accWrap.ShippingPostalCode)))
        {
            addressList = [SELECT Id, City__c, Abbreviation__c, Zip_Code__c FROM Address_Verifier__c WHERE City__c=: wrapperObj.accWrap.ShippingCity];
            if(!addressList.isEmpty()){
                if(String.isNotBlank(wrapperObj.accWrap.ShippingState)){
                    addressList = [SELECT Id, City__c, Abbreviation__c, Zip_Code__c FROM Address_Verifier__c WHERE City__c=: wrapperObj.accWrap.ShippingCity AND Abbreviation__c=: wrapperObj.accWrap.ShippingState];
                    if(!addressList.isEmpty()){
                        addressList = [SELECT Id, City__c, Abbreviation__c, Zip_Code__c FROM Address_Verifier__c WHERE City__c=: wrapperObj.accWrap.ShippingCity AND Abbreviation__c=: wrapperObj.accWrap.ShippingState AND Zip_Code__c =: wrapperObj.accWrap.ShippingPostalCode];
                        if(addressList.isEmpty()){
                            error = 'error';
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please provide correct Zip Code.'));
                            
                        }
                    }
                    else{
                        error = 'error';
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please provide correct State.'));
                        
                    }
                }
                else{
                    addressList = [SELECT Id, City__c, Abbreviation__c, Zip_Code__c FROM Address_Verifier__c WHERE City__c=: wrapperObj.accWrap.ShippingCity AND Zip_Code__c =: wrapperObj.accWrap.ShippingPostalCode];
                    if(addressList.isEmpty()){
                        error = 'error';
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please provide correct Zip Code.'));
                        
                    }    
                }
            }
            /*else{
                error = 'error';
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please provide correct City.'));
                
            } */
        }
        
        if(wrapperObj.accWrap.Type == 'Rehab & Maintenance'){
            if(String.isBlank(wrapperObj.accWrap.Category_1__c) || String.isBlank(wrapperObj.accWrap.Maint_Category_1__c)){            error = 'error';
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Both Rehab Categories and Maintenance Categories must be selected.'));
                
            }
        }
        
        
        if(wrapperObj.accWrap.Type == 'Rehab'){
            if(String.isBlank(wrapperObj.accWrap.Category_1__c)){  error = 'error';
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Rehab Category must be selected.'));
                
            }
        }
        
        if(wrapperObj.accWrap.Type == 'Maintenance'){
            if(String.isBlank(wrapperObj.accWrap.Maint_Category_1__c)){  error = 'error';
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Maintenance Categories must be selected.'));
                
            }
        }
        
        if(String.isBlank(wrapperObj.accWrap.Bank_Name__c) || String.isBlank(wrapperObj.accWrap.Account_Type__c) || 
           wrapperObj.accWrap.Routing_Number__c == null || wrapperObj.accWrap.Account_Number__c == null)
        {
            error = 'error';
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'EPAYMENT/BANKING INFORMATION is required.'));
            
        }
           
        wrapperObj.accWrap.Taxpayer_Identification_Number__c = tinNum;

       // system.debug('ManishManish' + wrapperObj.accWrap.Taxpayer_Identification_Number__c);
		if(String.isBlank(wrapperObj.accWrap.Taxpayer_Identification_Number__c))
        {
            error = 'error';
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Tax Identification Number is Mandatory'));
            
        }

        if(String.isNotBlank(wrapperObj.accWrap.Routing_Number__c) && wrapperObj.accWrap.Routing_Number__c.length() < 9)
        {
            error = 'error';
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Routing number must be of 9 characters.'));
            
        }
        
        if(String.isBlank(wrapperObj.accWrap.BillingStreet) || String.isBlank(wrapperObj.accWrap.BillingCity) || 
           String.isBlank(wrapperObj.accWrap.BillingState) || String.isBlank(wrapperObj.accWrap.BillingPostalCode) ||
           String.isBlank(wrapperObj.accWrap.Billing_Email__c))
        {
            error = 'error';
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Billing Information is required.'));
            
        }
        
        if(String.isNotBlank(wrapperObj.accWrap.BillingCity) && (String.isNotBlank(wrapperObj.accWrap.BillingState) || String.isNotBlank(wrapperObj.accWrap.BillingPostalCode)))
        {
            addressList = [SELECT Id, City__c, Abbreviation__c, Zip_Code__c FROM Address_Verifier__c WHERE City__c=: wrapperObj.accWrap.BillingCity];
            if(!addressList.isEmpty()){
                if(String.isNotBlank(wrapperObj.accWrap.ShippingState)){
                    addressList = [SELECT Id, City__c, Abbreviation__c, Zip_Code__c FROM Address_Verifier__c WHERE City__c=: wrapperObj.accWrap.BillingCity AND Abbreviation__c=: wrapperObj.accWrap.BillingState];
                    if(!addressList.isEmpty()){
                        addressList = [SELECT Id, City__c, Abbreviation__c, Zip_Code__c FROM Address_Verifier__c WHERE City__c=: wrapperObj.accWrap.BillingCity AND Abbreviation__c=: wrapperObj.accWrap.BillingState AND Zip_Code__c =: wrapperObj.accWrap.BillingPostalCode];
                        if(addressList.isEmpty()){                            error = 'error';
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please provide correct Billing PostalCode.'));
                            
                        }
                    }
                    else{
                        error = 'error';
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please provide correct Billing State.'));
                        
                    }
                }
                else{ addressList = [SELECT Id, City__c, Abbreviation__c, Zip_Code__c FROM Address_Verifier__c WHERE City__c=: wrapperObj.accWrap.BillingCity AND Zip_Code__c =: wrapperObj.accWrap.BillingPostalCode];
                    if(addressList.isEmpty()){  error = 'error';
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please provide correct Billing PostalCode.'));
                        
                    }    
                }
            }
           /* else{
                error = 'error';
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please provide correct Billing City.'));
                
            } */
        }

        if(String.isBlank(wrapperObj.primaryConWrap.FirstName)){            error = 'error';
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'First Name is required.'));
            
        }
        
        if(String.isBlank(wrapperObj.primaryConWrap.LastName)){            error = 'error';
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Last Name is required.'));
            
        }
        
        if(String.isBlank(wrapperObj.primaryConWrap.Email)) {
            error = 'error';
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Email is required.'));
            
        }
        
        
        /*if(!wrapperObj.accWrap.Home_Depot_Rapid_Pass_Acknowledgement__c){
error = 'error';
ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'You must select Home Depot Rapid Pass Acknowledgment'));

}*/
        if(!wrapperObj.accWrap.Legal_Acknowledgment__c){
            //error = 'error';
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'You must select Legal Acknowledgment'));
            
        }
        
        if(wrapperObj.accWrap.Type == 'Rehab & Maintenance'){
            if(String.isBlank(wrapperObj.accWrap.Category_1__c) && String.isBlank(wrapperObj.accWrap.Maint_Category_1__c)){               error = 'error';
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Both Rehab Categories and Maintenance Categories must be selected.'));
                
            }
        }
        
        for(ContentWrapper contver: cvWrapList){
            if(contver.status == 'Uploaded'){
                isUploaded = true;
            }
            if(!Test.isRunningTest() && contver.recId == null || contver.status == 'Rejected' || contver.status == 'Expired'){                 error = 'error';
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please provide "'+contver.attachType+'"'));
                
            }
            if(!Test.isRunningTest() && (contver.attachType == 'Driver’s License/Photo Id' || contver.attachType == 'Certificate of Insurance - General Liability' || contver.attachType == 'Certificate of Insurance or Waiver - Workers Comp' || contver.attachType == 'License') && contver.expDt == null){           error = 'error';
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please provide both Expiration Date and "'+contver.attachType+'"'));
                
            }
        }
        
        if(String.isNotBlank(wrapperObj.accWrap.Category_1__c) && String.isBlank(wrapperObj.accWrap.License__c)){
            if(wrapperObj.accWrap.Category_1__c.contains('Electrical') || 
               wrapperObj.accWrap.Category_1__c.contains('HVAC') ||
               wrapperObj.accWrap.Category_1__c.contains('Locks') ||
               wrapperObj.accWrap.Category_1__c.contains('Plumbing') ||
               wrapperObj.accWrap.Category_1__c.contains('Pest Control') ||
               wrapperObj.accWrap.Category_1__c.contains('Engineer') ||
               wrapperObj.accWrap.Category_1__c.contains('Chimneys') ||
               wrapperObj.accWrap.Category_1__c.contains('Foundation')
              )
            {                error = 'error';
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'License# is required.'));
                
            }
        }
        
        if(String.isNotBlank(wrapperObj.accWrap.Maint_Category_1__c) && String.isBlank(wrapperObj.accWrap.License__c)){
            if(wrapperObj.accWrap.Maint_Category_1__c.contains('Electrical') || 
               wrapperObj.accWrap.Maint_Category_1__c.contains('HVAC') ||
               wrapperObj.accWrap.Maint_Category_1__c.contains('Locks') ||
               wrapperObj.accWrap.Maint_Category_1__c.contains('Plumbing') ||
               wrapperObj.accWrap.Maint_Category_1__c.contains('Pest Control') ||
               wrapperObj.accWrap.Maint_Category_1__c.contains('Engineer')||
               wrapperObj.accWrap.Maint_Category_1__c.contains('Chimneys')||
               wrapperObj.accWrap.Maint_Category_1__c.contains('Foundation')
              )
            {                error = 'error';
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'License# is required.'));
                
            }
        }
        
        List<Contact> contactUpsertList = new List<Contact>();    
        System.debug('wrapperObj.conListWrap-----'+wrapperObj.conListWrap);    
        for(Contact objconWrap: wrapperObj.conListWrap) {  
            if(String.isNotBlank(objconWrap.Department__c) || 
               String.isNotBlank(objconWrap.FirstName) || String.isNotBlank(objconWrap.LastName) || 
               String.isNotBlank(objconWrap.Phone) || String.isNotBlank(objconWrap.Email) )
            {           
                if(objconWrap.Email == null || objconWrap.Email == '') {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Email is required.'));
                    
                }   
                if(String.isBlank(objconWrap.LastName)) {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'ADDITIONAL CONTACTS: LastName is required.'));
                    
                }  
                
                if(String.isBlank(objconWrap.FirstName)) {
                    error = 'error';
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'ADDITIONAL CONTACTS: FirstName is required.'));
                    
                }  
                
                if(objconWrap.Phone == null) {
                    error = 'error';
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'ADDITIONAL CONTACTS: Phone is required.'));
                    
                }  
                
                Contact conObj = new Contact();                
                if(objconWrap != null && objconWrap.Id != null) {
                    conObj.id = objconWrap.Id;
                }
                if(objconWrap != null && objconWrap.AccountId != null) {
                    conObj.AccountId = objconWrap.AccountId;
                }
                else{ conObj.AccountId = currentUserAccountId;
                }
                conObj.Department__c = objconWrap.Department__c;
                conObj.FirstName = objconWrap.FirstName;
                conObj.LastName = objconWrap.LastName;
                conObj.Email = objconWrap.Email;
                conObj.Phone = objconWrap.Phone;
                
                contactUpsertList.add(conObj);
            }
        }
       
        
        
        if(bypassValidation != true){            noerror = 'error';
            return null;
        }
        /*
wrapperObj.accWrap.Market__c = null;
wrapperObj.accWrap.Category_1__c = null;
wrapperObj.accWrap.Maint_Category_1__c = null;
for(MarketWrapper wrp: marketWrapList){
if(wrp.isSelected){
if(String.isBlank(wrapperObj.accWrap.Market__c)){
wrapperObj.accWrap.Market__c = wrp.value;
}
else{
wrapperObj.accWrap.Market__c += ';' + wrp.value;
}
}
} 
for(RehabTradeWrapper wrp: lst_rehabContractorTrades){
if(wrp.isSelected){
if(String.isBlank(wrapperObj.accWrap.Category_1__c)){
wrapperObj.accWrap.Category_1__c = wrp.value;
}
else{
wrapperObj.accWrap.Category_1__c += ';' + wrp.value;
}
}
}

for(RehabTradeWrapper wrp: lst_maintenanceProviderTrades){
if(wrp.isSelected){
if(String.isBlank(wrapperObj.accWrap.Maint_Category_1__c)){
wrapperObj.accWrap.Maint_Category_1__c = wrp.value;
}
else{
wrapperObj.accWrap.Maint_Category_1__c += ';' + wrp.value;
}
}
}
*/      
        
        Boolean sendForApproval = false;
        
        Account accNew = [SELECT Id,Name,Website, Type, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode,
                          BillingStreet, BillingCity, BillingState, BillingPostalCode, Billing_Email__c,
                          Approval_Status__c, Vendor_Email__c,Status__c, Phone, Market__c,
                          Category_1__c, Maint_Category_1__c, Taxpayer_Identification_Number__c,
                          Account_Type__c, Account_Number__c,Routing_Number__c, Bank_Name__c, Legal_Acknowledgment__c,
                          Business_Name__c, Is_Uploaded__c, Primary_Contact_Email__c,
                          Home_Depot_Rapid_Pass_Acknowledgement__c, License__c   FROM Account WHERE Id =: wrapperObj.accWrap.id];
        if(error == 'error'){return null;}
        //doUpdateVendorProfile();
        
        Account acc = new Account();
        acc = wrapperObj.accWrap;
        
        if(wrapperObj.accWrap.Is_Uploaded__c || accNew.Category_1__c != wrapperObj.accWrap.Category_1__c ||         accNew.Market__c != wrapperObj.accWrap.Market__c || accNew.Maint_Category_1__c != wrapperObj.accWrap.Maint_Category_1__c ||           accNew.Bank_Name__c != wrapperObj.accWrap.Bank_Name__c || accNew.Account_Type__c != wrapperObj.accWrap.Account_Type__c ||            accNew.Account_Number__c != wrapperObj.accWrap.Account_Number__c || accNew.Routing_Number__c != wrapperObj.accWrap.Routing_Number__c ||           accNew.BillingStreet != wrapperObj.accWrap.BillingStreet || accNew.BillingCity != wrapperObj.accWrap.BillingCity ||           accNew.BillingState != wrapperObj.accWrap.BillingState || accNew.BillingPostalCode != wrapperObj.accWrap.BillingPostalCode ||           accNew.Billing_Email__c != wrapperObj.accWrap.Billing_Email__c || accNew.License__c != wrapperObj.accWrap.License__c)
        {            sendForApproval = true;
            
if((accNew.Bank_Name__c != wrapperObj.accWrap.Bank_Name__c || accNew.Account_Type__c != wrapperObj.accWrap.Account_Type__c || accNew.Account_Number__c != wrapperObj.accWrap.Account_Number__c || accNew.Routing_Number__c != wrapperObj.accWrap.Routing_Number__c)&& (!isDDAUploaded || !isVCUploaded))
{error = 'error';
if(!isDDAUploaded){ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please upload New Version of Direct Deposit Agreement.'));
//return null; 
}
if(!isVCUploaded){ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please upload New Version of Voided Check.'));
return null; 
}   
}
/*if(accNew.License__c != wrapperObj.accWrap.License__c && (!isLicenseUploaded || !isPermitsUploaded))
{
error = 'error';
if(!isLicenseUploaded){
ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please upload License.'));
return null; 
}
if(!isPermitsUploaded){
ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please upload Permits.'));
return null; 
}   
} */
        }
        
        acc.Taxpayer_Identification_Number__c = tinNum;
        acc.Is_Uploaded__c = isUploaded;
        acc.Primary_Contact_Email__c = wrapperObj.primaryConWrap.Email;
        acc.AccountUpdateFromPortal__c = 'YES';
        update acc;
        
        Contact con = new Contact();
        con = wrapperObj.primaryConWrap;
        con.Is_Primary__c = true;
        con.MailingStreet = wrapperObj.accWrap.BillingStreet;
        con.MailingCity = wrapperObj.accWrap.BillingCity;
        con.MailingState = wrapperObj.accWrap.BillingState;
        con.MailingPostalCode = wrapperObj.accWrap.BillingPostalCode;
        upsert con;              
        
        if(!contactUpsertList.isEmpty() ) {Database.upsert(contactUpsertList, false);
        }  
        
        isSave = false;
        //pgRef.getParameters().put('hasSaved', 'false');
        if(sendForApproval){
            try{
                // Create an approval request for the account
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setComments('Submitting request for approval.');
                req1.setObjectId(wrapperObj.accWrap.Id);
                
                // Submit on behalf of a specific submitter
                req1.setSubmitterId(UserInfo.getUserId()); 
                req1.setProcessDefinitionNameOrId('Finance_Vendor_Profile_Update_Approval');                
                
                // Submit the approval request for the account
                Approval.ProcessResult result = Approval.process(req1);
                system.debug('result-----'+result);
                
            }
            catch(DMLException e){ error = e.getMessage(); 
                system.debug('======error====='+error +'==========='+ e.getLineNumber());
            }
        }
        
        return new PageReference('/apex/VendorThankYou?lang='+langRehabContractorCheck+'&hasSaved='+isSave);
    }
    
    // This method is used to update vender profile account and upsert contact.
    public PageReference doUpdateVendorProfile() {
        error = '';
        
        List<Address_Verifier__c> addressList = new List<Address_Verifier__c>();
        
        /* if(String.isNotBlank(wrapperObj.accWrap.ShippingCity) && (String.isNotBlank(wrapperObj.accWrap.ShippingState) || String.isNotBlank(wrapperObj.accWrap.ShippingPostalCode)))
{
addressList = [SELECT Id, City__c, Abbreviation__c, Zip_Code__c FROM Address_Verifier__c WHERE City__c=: wrapperObj.accWrap.ShippingCity];
if(!addressList.isEmpty()){
if(String.isNotBlank(wrapperObj.accWrap.ShippingState)){
addressList = [SELECT Id, City__c, Abbreviation__c, Zip_Code__c FROM Address_Verifier__c WHERE City__c=: wrapperObj.accWrap.ShippingCity AND Abbreviation__c=: wrapperObj.accWrap.ShippingState];
if(!addressList.isEmpty()){
addressList = [SELECT Id, City__c, Abbreviation__c, Zip_Code__c FROM Address_Verifier__c WHERE City__c=: wrapperObj.accWrap.ShippingCity AND Abbreviation__c=: wrapperObj.accWrap.ShippingState AND Zip_Code__c =: wrapperObj.accWrap.ShippingPostalCode];
if(addressList.isEmpty()){
error = 'error';
ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please provide correct Zip Code.'));
return null;
}
}
else{
error = 'error';
ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please provide correct State.'));
return null;
}
}
else{
addressList = [SELECT Id, City__c, Abbreviation__c, Zip_Code__c FROM Address_Verifier__c WHERE City__c=: wrapperObj.accWrap.ShippingCity AND Zip_Code__c =: wrapperObj.accWrap.ShippingPostalCode];
if(addressList.isEmpty()){
error = 'error';
ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please provide correct Zip Code.'));
return null;
}    
}
}
else{
error = 'error';
ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please provide correct City.'));
return null;
}
}

/* if(String.isBlank(wrapperObj.accWrap.Bank_Name__c) || String.isBlank(wrapperObj.accWrap.Account_Type__c) || 
wrapperObj.accWrap.Routing_Number__c == null || wrapperObj.accWrap.Account_Number__c == null)
{
error = 'error';
ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'EPAYMENT/BANKING INFORMATION is required.'));
return null;
}

if(String.isNotBlank(wrapperObj.accWrap.Routing_Number__c) && wrapperObj.accWrap.Routing_Number__c.length() < 9)
{
error = 'error';
ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Routing number must be of 9 characters.'));
return null;
}

if(String.isBlank(wrapperObj.accWrap.BillingStreet) || String.isBlank(wrapperObj.accWrap.BillingCity) || 
String.isBlank(wrapperObj.accWrap.BillingState) || String.isBlank(wrapperObj.accWrap.BillingPostalCode) ||
String.isBlank(wrapperObj.accWrap.Billing_Email__c))
{
error = 'error';
ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Billing Information is required.'));
return null;
}

if(String.isNotBlank(wrapperObj.accWrap.BillingCity) && (String.isNotBlank(wrapperObj.accWrap.BillingState) || String.isNotBlank(wrapperObj.accWrap.BillingPostalCode)))
{
addressList = [SELECT Id, City__c, Abbreviation__c, Zip_Code__c FROM Address_Verifier__c WHERE City__c=: wrapperObj.accWrap.BillingCity];
if(!addressList.isEmpty()){
if(String.isNotBlank(wrapperObj.accWrap.ShippingState)){
addressList = [SELECT Id, City__c, Abbreviation__c, Zip_Code__c FROM Address_Verifier__c WHERE City__c=: wrapperObj.accWrap.BillingCity AND Abbreviation__c=: wrapperObj.accWrap.BillingState];
if(!addressList.isEmpty()){
addressList = [SELECT Id, City__c, Abbreviation__c, Zip_Code__c FROM Address_Verifier__c WHERE City__c=: wrapperObj.accWrap.BillingCity AND Abbreviation__c=: wrapperObj.accWrap.BillingState AND Zip_Code__c =: wrapperObj.accWrap.BillingPostalCode];
if(addressList.isEmpty()){
error = 'error';
ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please provide correct Billing PostalCode.'));
return null;
}
}
else{
error = 'error';
ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please provide correct Billing State.'));
return null;
}
}
else{
addressList = [SELECT Id, City__c, Abbreviation__c, Zip_Code__c FROM Address_Verifier__c WHERE City__c=: wrapperObj.accWrap.BillingCity AND Zip_Code__c =: wrapperObj.accWrap.BillingPostalCode];
if(addressList.isEmpty()){
error = 'error';
ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please provide correct Billing PostalCode.'));
return null;
}    
}
}
else{
error = 'error';
ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please provide correct Billing City.'));
return null;
}
}

if(String.isBlank(wrapperObj.primaryConWrap.LastName)){
error = 'error';
ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Last Name is required.'));
return null;
}

if(wrapperObj.primaryConWrap.Email == null || wrapperObj.primaryConWrap.Email == '') {
error = 'error';
ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Email is required.'));
return null;
}

if(wrapperObj.accWrap.Type == 'Rehab & Maintenance'){
if(String.isBlank(wrapperObj.accWrap.Category_1__c) || String.isBlank(wrapperObj.accWrap.Maint_Category_1__c)){
error = 'error';
ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Both Rehab Categories and Maintenance Categories must be selected.'));
return null;
}
}


if(wrapperObj.accWrap.Type == 'Rehab'){
if(String.isBlank(wrapperObj.accWrap.Category_1__c)){

error = 'error';
ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Rehab Category must be selected.'));
return null;
}
}

if(wrapperObj.accWrap.Type == 'Maintenance'){
if(String.isBlank(wrapperObj.accWrap.Maint_Category_1__c)){
error = 'error';
ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Maintenance Categories must be selected.'));
return null;
}
}*/
        
        wrapperObj.accWrap.Market__c = null;
        for(MarketWrapper wrp: marketWrapList){
            if(wrp.isSelected){
                if(String.isBlank(wrapperObj.accWrap.Market__c)){
                    wrapperObj.accWrap.Market__c = wrp.value;
                }
                else{
                    wrapperObj.accWrap.Market__c += ';' + wrp.value;
                }
            }
        }
        
        /*if(String.isNotBlank(wrapperObj.accWrap.Category_1__c) && String.isBlank(wrapperObj.accWrap.License__c)){
if(wrapperObj.accWrap.Category_1__c.contains('Electrical') || 
wrapperObj.accWrap.Category_1__c.contains('HVAC') ||
wrapperObj.accWrap.Category_1__c.contains('Locks') ||
wrapperObj.accWrap.Category_1__c.contains('Plumbing') ||
wrapperObj.accWrap.Category_1__c.contains('Pest Control')
)
{
error = 'error';
ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'License# is required.'));
return null;    
}
}

if(String.isNotBlank(wrapperObj.accWrap.Maint_Category_1__c) && String.isBlank(wrapperObj.accWrap.License__c)){
if(wrapperObj.accWrap.Maint_Category_1__c.contains('Electrical') || 
wrapperObj.accWrap.Maint_Category_1__c.contains('HVAC') ||
wrapperObj.accWrap.Maint_Category_1__c.contains('Locks') ||
wrapperObj.accWrap.Maint_Category_1__c.contains('Plumbing') ||
wrapperObj.accWrap.Maint_Category_1__c.contains('Pest Control')
)
{
error = 'error';
ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'License# is required.'));
return null;    
}
}*/
        
        Account acc = new Account();
        acc = wrapperObj.accWrap;
        
        Boolean sendForApproval = false;
        Account accNew = [SELECT Id,Name,Website, Type, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode,
                          BillingStreet, BillingCity, BillingState, BillingPostalCode, Billing_Email__c,
                          Approval_Status__c, Vendor_Email__c,Phone, Market__c,Primary_Contact_Email__c,
                          Category_1__c, Maint_Category_1__c,Status__c, Taxpayer_Identification_Number__c,
                          Account_Type__c, Account_Number__c,Routing_Number__c, Bank_Name__c, Legal_Acknowledgment__c,
                          Business_Name__c, Is_Uploaded__c, Home_Depot_Rapid_Pass_Acknowledgement__c, License__c 
                          FROM Account WHERE Id =: wrapperObj.accWrap.id];
        
        if(accNew.Category_1__c != wrapperObj.accWrap.Category_1__c || 
           accNew.Market__c != wrapperObj.accWrap.Market__c || accNew.Maint_Category_1__c != wrapperObj.accWrap.Maint_Category_1__c ||
           accNew.Bank_Name__c != wrapperObj.accWrap.Bank_Name__c || accNew.Account_Type__c != wrapperObj.accWrap.Account_Type__c || 
           accNew.Account_Number__c != wrapperObj.accWrap.Account_Number__c || accNew.Routing_Number__c != wrapperObj.accWrap.Routing_Number__c ||
           accNew.BillingStreet != wrapperObj.accWrap.BillingStreet || accNew.BillingCity != wrapperObj.accWrap.BillingCity ||
           accNew.BillingState != wrapperObj.accWrap.BillingState || accNew.BillingPostalCode != wrapperObj.accWrap.BillingPostalCode ||
           accNew.Billing_Email__c != wrapperObj.accWrap.Billing_Email__c || accNew.License__c != wrapperObj.accWrap.License__c || wrapperObj.accWrap.Is_Uploaded__c)
        {
            //sendForApproval = true;
            if(acc.Status__c != 'Onboarding'){
            acc.Status__c = 'On Hold';
            }
            //acc.Approval_Status__c = 'Waiting for Approval';
            /* if((accNew.Bank_Name__c != wrapperObj.accWrap.Bank_Name__c || accNew.Account_Type__c != wrapperObj.accWrap.Account_Type__c || 
accNew.Account_Number__c != wrapperObj.accWrap.Account_Number__c || accNew.Routing_Number__c != wrapperObj.accWrap.Routing_Number__c) 
&& (!isDDAUploaded || !isVCUploaded))
{
error = 'error';
if(!isDDAUploaded){
ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please upload Direct Deposit Agreement.'));

}
if(!isVCUploaded){
ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please upload Voided Check.'));

}      
}
if(accNew.License__c != wrapperObj.accWrap.License__c && (!isLicenseUploaded || !isPermitsUploaded))
{
error = 'error';
if(!isLicenseUploaded){
ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please upload License.'));

}
if(!isPermitsUploaded){
ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please upload Permits.'));

}   
} */
        }
        
        
        List<Contact> contactUpsertList = new List<Contact>();    
        System.debug('wrapperObj.conListWrap-----'+wrapperObj.conListWrap);    
        for(Contact objconWrap: wrapperObj.conListWrap) {  
            if(String.isNotBlank(objconWrap.Department__c) || 
               String.isNotBlank(objconWrap.FirstName) || String.isNotBlank(objconWrap.LastName) || 
               String.isNotBlank(objconWrap.Phone) || String.isNotBlank(objconWrap.Email) )
            {           
                if(objconWrap.Email == null || objconWrap.Email == '') {
                    error = 'error';
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Email is required.'));
                    
                }   
                if(String.isBlank(objconWrap.LastName)) {
                    error = 'error';
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'ADDITIONAL CONTACTS: LastName is required.'));
                    
                }  
                
                if(String.isBlank(objconWrap.FirstName)) {
                    error = 'error';
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'ADDITIONAL CONTACTS: FirstName is required.'));
                    
                }  
                
                if(objconWrap.Phone == null) {
                    error = 'error';
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'ADDITIONAL CONTACTS: Phone is required.'));
                    
                }  
                
                
                Contact conObj = new Contact();                
                if(objconWrap != null && objconWrap.Id != null) {
                    conObj.id = objconWrap.Id;
                }
                if(objconWrap != null && objconWrap.AccountId != null) {
                    conObj.AccountId = objconWrap.AccountId;
                }
                else{ conObj.AccountId = currentUserAccountId;
                }
                conObj.Department__c = objconWrap.Department__c;
                conObj.FirstName = objconWrap.FirstName;
                conObj.LastName = objconWrap.LastName;
                conObj.Email = objconWrap.Email;
                conObj.Phone = objconWrap.Phone;
                //	conObj.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Vendor').getRecordTypeId();
                
                contactUpsertList.add(conObj);
            }
        }
        
        for(ContentWrapper contver: cvWrapList){
            if(!Test.isRunningTest() && (contver.attachType == 'Direct Deposit Agreement' || contver.attachType == 'Voided Check') &&   (contver.recId == null || contver.status == 'Rejected' || contver.status == 'Expired'))
            {
                //error = 'error';
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please upload Direct Deposit Agreement and Voided Check.'));
                
            }
            if(contver.status == 'Uploaded'){
                isUploaded = true;
            }
        }
        if(error == 'error'){
            return null;
        }
        
        acc.Taxpayer_Identification_Number__c = tinNum;
        acc.Is_Uploaded__c = isUploaded;
        acc.Primary_Contact_Email__c = wrapperObj.primaryConWrap.Email;
        try {
            update acc;
        } catch(Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,e.getMessage()));
            return null;
        }     
        Contact con = new Contact();
        con = wrapperObj.primaryConWrap;
        con.Is_Primary__c = true;
        con.MailingStreet = wrapperObj.accWrap.BillingStreet;
        con.MailingCity = wrapperObj.accWrap.BillingCity;
        con.MailingState = wrapperObj.accWrap.BillingState;
        con.MailingPostalCode = wrapperObj.accWrap.BillingPostalCode;
        //	con.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Vendor').getRecordTypeId();
        
        upsert con;    
        
        
        if(!contactUpsertList.isEmpty()) {
            upsert contactUpsertList;
        }  
        
        /*                
if(sendForApproval){
try{
// Create an approval request for the account
Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
req1.setComments('Submitting request for approval.');
req1.setObjectId(wrapperObj.accWrap.Id);

// Submit on behalf of a specific submitter
req1.setSubmitterId(UserInfo.getUserId());                 

req1.setProcessDefinitionNameOrId('Finance_Vendor_Profile_Update_Approval');

// Submit the approval request for the account
Approval.ProcessResult result = Approval.process(req1);
system.debug('result-----'+result);

}
catch(DMLException e){
error = e.getMessage(); 
system.debug('======error====='+error +'==========='+ e.getLineNumber());
}
}
*/
        isSave = true;
        return new PageReference('/apex/VendorThankYou?lang='+langRehabContractorCheck+'&hasSaved='+isSave);
    }   
    
    // available attachment types at file upload
    public List<SelectOption> getattachmentTypes(){
        List<SelectOption> attachmentType = new List<SelectOption>();
        for(Vendor_Attachment__mdt attach: [SELECT Name__c, MasterLabel FROM Vendor_Attachment__mdt ORDER BY MasterLabel]){
            if(langRehabContractorCheck) { 
                attachmentType.add(new SelectOption(attach.Name__c, SpanishUtil.spanishAttachVal(attach.Name__c))); 
            }
            else{ attachmentType.add(new SelectOption(attach.Name__c, attach.Name__c));   
            }                                               
        }            
        
        return attachmentType;
    }
    
    //creates a list of required Documents
    public void createReqDocTable(){
        
        cvWrapList.clear();
        cvWrapAdditionalList.clear();
        attachTypesToAdd.clear();
        attachTypesToAddTemp.clear();
        
        Set<Id> conDocIds = new Set<Id>();
        if(currentUserAccountId != null){
            for(ContentDocumentLink cdLink: [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: currentUserAccountId])
            {  conDocIds.add(cdLink.ContentDocumentId);
            } 
        }
        
        Set<String> attachNames = new Set<string>();
        for(Vendor_Attachment__mdt attach: [SELECT Name__c, MasterLabel FROM Vendor_Attachment__mdt ORDER BY MasterLabel]){
            attachNames.add(attach.Name__c);
        }
        for(ContentVersion cv: [Select id,OwnerId,FirstPublishLocationId,ContentDocumentId,Title,VersionData,Expiration_Date__c,Attachment_Type__c,Status__c From ContentVersion Where ContentDocumentId IN: conDocIds AND Attachment_Type__c IN: attachNames AND IsLatest = true]){
            
            if(cv.OwnerId == UserInfo.getUserId()){ attachmentIdList.add(cv.Id);
                
                if(cv.Attachment_Type__c == 'Certificate of Insurance or Waiver - Workers Comp' || 
                   cv.Attachment_Type__c == 'Permanent Resident Card / Green Card' || 
                   cv.Attachment_Type__c == 'Employment Authorization Document / Work Permit' ||
                   cv.Attachment_Type__c == 'Employment Visa')
                {
                    ContentWrapper cvWrap = new ContentWrapper();
                    cvWrap.recId = cv.Id;
                    cvWrap.conDocId = cv.ContentDocumentId;
                    cvWrap.title = cv.Title;
                    if(langRehabContractorCheck) {  
                        cvWrap.attachType = SpanishUtil.spanishAttachVal(cv.Attachment_Type__c); 
                        cvWrap.status = SpanishUtil.spanishAttachType(cv.Status__c); 
                    }
                    else{
                        cvWrap.attachType = cv.Attachment_Type__c;
                        cvWrap.status = cv.Status__c;
                    }
                    cvWrap.expDt = cv.Expiration_Date__c;
                    
                    cvWrapAdditionalList.add(cvWrap);
                }
                else{
                    //contVerList.add(cv);
                    ContentWrapper cvWrap = new ContentWrapper();
                    cvWrap.recId = cv.Id;
                    cvWrap.conDocId = cv.ContentDocumentId;
                    cvWrap.title = cv.Title;
                    if(langRehabContractorCheck) {  
                        cvWrap.attachType = SpanishUtil.spanishAttachVal(cv.Attachment_Type__c); 
                        cvWrap.status = SpanishUtil.spanishAttachType(cv.Status__c);  
                    }
                    else{
                        cvWrap.attachType = cv.Attachment_Type__c;
                        cvWrap.status = cv.Status__c;
                    }  cvWrap.expDt = cv.Expiration_Date__c;
                    
                    cvWrapList.add(cvWrap);                    
                }  
                
                attachTypesToAdd.add(cv.Attachment_Type__c); 
                attachTypesToAddTemp.add(cv.Attachment_Type__c);               
            }
        }
        
        System.debug('attachTypesToAdd-----'+attachTypesToAdd);
        wrapperObj.accWrap.Market__c = null;
        wrapperObj.accWrap.Category_1__c = null;
        wrapperObj.accWrap.Maint_Category_1__c = null;
        
        for(MarketWrapper wrp: marketWrapList){
            if(wrp.isSelected){
                if(String.isBlank(wrapperObj.accWrap.Market__c)){
                    wrapperObj.accWrap.Market__c= wrp.value;
                }
                else{
                    wrapperObj.accWrap.Market__c+= ';' + wrp.value;
                }
            }
        }
        for(RehabTradeWrapper wrp: lst_rehabContractorTrades){
            if(wrp.isSelected){
                if(String.isBlank(wrapperObj.accWrap.Category_1__c)){
                    wrapperObj.accWrap.Category_1__c = wrp.value;
                }
                else{
                    wrapperObj.accWrap.Category_1__c += ';' + wrp.value;
                }
            }
        }
        
        for(RehabTradeWrapper wrp: lst_maintenanceProviderTrades){
            if(wrp.isSelected){
                if(String.isBlank(wrapperObj.accWrap.Maint_Category_1__c)){
                    wrapperObj.accWrap.Maint_Category_1__c = wrp.value;
                }
                else{
                    wrapperObj.accWrap.Maint_Category_1__c += ';' + wrp.value;
                }
            }
        }
        
        if(!attachTypesToAdd.isEmpty()){
            //Required Docs
            if(!attachTypesToAdd.contains('W9')){
                attachTypesToAdd.add('W9');
            }
            if(!attachTypesToAdd.contains('Direct Deposit Agreement')){
                attachTypesToAdd.add('Direct Deposit Agreement');
            }
            if(!attachTypesToAdd.contains('Voided Check')){
                attachTypesToAdd.add('Voided Check');
            }
            if(!attachTypesToAdd.contains('Driver’s License/Photo Id')){
                attachTypesToAdd.add('Driver’s License/Photo Id');
            }
            if(!attachTypesToAdd.contains('TIN Documentation (Social Security Card or IRS Notice of Assignment of TIN)')){
                attachTypesToAdd.add('TIN Documentation (Social Security Card or IRS Notice of Assignment of TIN)');
            }
            if(!attachTypesToAdd.contains('Payment Agreement')){
                attachTypesToAdd.add('Payment Agreement');
            }
            
            //Additional docs
            if(!attachTypesToAdd.contains('Certificate of Insurance or Waiver - Workers Comp')){
                attachTypesToAdd.add('Certificate of Insurance or Waiver - Workers Comp');
            }
            if(!attachTypesToAdd.contains('Permanent Resident Card / Green Card')){
                attachTypesToAdd.add('Permanent Resident Card / Green Card');
            }
            if(!attachTypesToAdd.contains('Employment Authorization Document / Work Permit')){
                attachTypesToAdd.add('Employment Authorization Document / Work Permit');
            }
            if(!attachTypesToAdd.contains('Employment Visa')){
                attachTypesToAdd.add('Employment Visa');
            }
        }
        else{
            //Required Docs
            attachTypesToAdd.add('W9');
            attachTypesToAdd.add('Direct Deposit Agreement');
            attachTypesToAdd.add('Voided Check');
            attachTypesToAdd.add('Driver’s License/Photo Id');
            attachTypesToAdd.add('TIN Documentation (Social Security Card or IRS Notice of Assignment of TIN)');
            attachTypesToAdd.add('Payment Agreement');
            
            //Additional docs
            attachTypesToAdd.add('Certificate of Insurance or Waiver - Workers Comp');
            attachTypesToAdd.add('Permanent Resident Card / Green Card');
            attachTypesToAdd.add('Employment Authorization Document / Work Permit');
            attachTypesToAdd.add('Employment Visa');
        } 
        
        System.debug('wrapperObj.accWrap.Category_1__c:-----'+wrapperObj.accWrap.Category_1__c);
        System.debug('wrapperObj.accWrap.Market__c:-----'+wrapperObj.accWrap.Market__c);
        
        /* Added new Markets - 5/07/2021 - Isaac A. Huicochea*/
        if(String.isNotBlank(wrapperObj.accWrap.Category_1__c)){
            if(String.isNotBlank(wrapperObj.accWrap.Market__c))
            {
                if(wrapperObj.accWrap.Type == 'Rehab & Maintenance' && (wrapperObj.accWrap.Market__c.contains('MEM') || wrapperObj.accWrap.Market__c.contains('STL') || wrapperObj.accWrap.Market__c.contains('BHM') || wrapperObj.accWrap.Market__c.contains('HSV') ||
                                                                        wrapperObj.accWrap.Market__c.contains('TUS') || wrapperObj.accWrap.Market__c.contains('TLH') || wrapperObj.accWrap.Market__c.contains('JKT') || wrapperObj.accWrap.Market__c.contains('JAN') ||
                                                                        wrapperObj.accWrap.Market__c.contains('CHA') || wrapperObj.accWrap.Market__c.contains('BNA')))
                {
                    if(!attachTypesToAdd.contains('Hold Harmless Agreement')){
                        attachTypesToAdd.add('Hold Harmless Agreement');
                    }
/* Consolidating to 1 Document 8/31/2023 Chris                   
                    if(!attachTypesToAdd.contains('Hold Harmless Agreement Premier')){
                        attachTypesToAdd.add('Hold Harmless Agreement Premier');
                    }*/
                }
                if(wrapperObj.accWrap.Type == 'Rehab & Maintenance' && (wrapperObj.accWrap.Market__c.contains('DFW') || wrapperObj.accWrap.Market__c.contains('SAN') ||
                                                                        wrapperObj.accWrap.Market__c.contains('HOU') || wrapperObj.accWrap.Market__c.contains('LIT') ||
                                                                        wrapperObj.accWrap.Market__c.contains('OKC') || wrapperObj.accWrap.Market__c.contains('TUL') ||
                                                                       	wrapperObj.accWrap.Market__c.contains('AUS')))
                {
                    if(!attachTypesToAdd.contains('Hold Harmless Agreement')){
                        attachTypesToAdd.add('Hold Harmless Agreement');
                    }
/* Consolidating to 1 Document 8/31/2023 Chris Mollet Demand Chain 
                    if(!attachTypesToAdd.contains('Hold Harmless Agreement PPMG TX')){ attachTypesToAdd.add('Hold Harmless Agreement PPMG TX');
                    }*/
                }
            }
            
            if(wrapperObj.accWrap.Category_1__c.contains('Electrical') || 
               wrapperObj.accWrap.Category_1__c.contains('HVAC') ||
               wrapperObj.accWrap.Category_1__c.contains('Plumbing') ||
               wrapperObj.accWrap.Category_1__c.contains('Foundation')
              )
            {
                if(!attachTypesToAdd.contains('License')){ attachTypesToAdd.add('License');
                }
                if(!attachTypesToAdd.contains('Permits')){ attachTypesToAdd.add('Permits');
                }
            }
            
            if( wrapperObj.accWrap.Category_1__c.contains('Engineer') ||
               wrapperObj.accWrap.Category_1__c.contains('Locks') ||
               wrapperObj.accWrap.Category_1__c.contains('Pest Control') ||
               wrapperObj.accWrap.Category_1__c.contains('Insulation') ||
               wrapperObj.accWrap.Category_1__c.contains('Chimneys')
              )
            {
                if(!attachTypesToAdd.contains('License')){ attachTypesToAdd.add('License');
                }
            }
            
            if(wrapperObj.accWrap.Category_1__c.contains('Electrical') || 
               wrapperObj.accWrap.Category_1__c.contains('Engineer') ||
               wrapperObj.accWrap.Category_1__c.contains('Foundation') ||
               wrapperObj.accWrap.Category_1__c.contains('HVAC') ||
               wrapperObj.accWrap.Category_1__c.contains('Locks') ||
               wrapperObj.accWrap.Category_1__c.contains('Plumbing') ||
               wrapperObj.accWrap.Category_1__c.contains('Pest Control') ||
               wrapperObj.accWrap.Category_1__c.contains('Roofs') ||
               wrapperObj.accWrap.Category_1__c.contains('Chimneys') ||
               wrapperObj.accWrap.Category_1__c.contains('Tree Removal') ||
               wrapperObj.accWrap.Category_1__c.contains('Insulation') ||
               wrapperObj.accWrap.Category_1__c.contains('Windows')
              )
            {
                if(!attachTypesToAdd.contains('Certificate of Insurance - General Liability')){
                    attachTypesToAdd.add('Certificate of Insurance - General Liability');
                }
                /* Added new Markets - 5/07/2021 - Isaac A. Huicochea*/
                if(String.isNotBlank(wrapperObj.accWrap.Market__c))
                {
                    if(wrapperObj.accWrap.Type == 'Rehab & Maintenance' && (wrapperObj.accWrap.Market__c.contains('MEM') || wrapperObj.accWrap.Market__c.contains('STL') || wrapperObj.accWrap.Market__c.contains('BHM') || wrapperObj.accWrap.Market__c.contains('HSV')||
                                                                            wrapperObj.accWrap.Market__c.contains('TUS') || wrapperObj.accWrap.Market__c.contains('TLH') || wrapperObj.accWrap.Market__c.contains('JKT') || wrapperObj.accWrap.Market__c.contains('JAN')||
                                                                            wrapperObj.accWrap.Market__c.contains('CHA') || wrapperObj.accWrap.Market__c.contains('BNA')))
                    {
/* Consolidating to 1 Document 8/31/2023 Chris Mollet Demand Chain*/                        
                    if(!attachTypesToAdd.contains('Insurance Agreement')){
                            attachTypesToAdd.add('Insurance Agreement');
                        } 
                    }
                    if(wrapperObj.accWrap.Type == 'Rehab & Maintenance' && (wrapperObj.accWrap.Market__c.contains('DFW') || wrapperObj.accWrap.Market__c.contains('SAN') || 
                                                                            wrapperObj.accWrap.Market__c.contains('HOU') || wrapperObj.accWrap.Market__c.contains('LIT') ||
                                                                            wrapperObj.accWrap.Market__c.contains('OKC') || wrapperObj.accWrap.Market__c.contains('TUL') ||
                                                                            wrapperObj.accWrap.Market__c.contains('BHM') || wrapperObj.accWrap.Market__c.contains('HSV') ||
                                                                            wrapperObj.accWrap.Market__c.contains('AUS')))
                    {
/* Consolidating to 1 Document 8/31/2023 Chris Mollet Demand Chain*/
                        if(!attachTypesToAdd.contains('Insurance Agreement')){
                            attachTypesToAdd.add('Insurance Agreement');
                        }
                    }
                }
                
                if(wrapperObj.accWrap.Type == 'Rehab')
                {
/* Consolidating to 1 Document 8/31/2023 Chris Mollet Demand Chain*/
                    if(!attachTypesToAdd.contains('Insurance Agreement')){
                        attachTypesToAdd.add('Insurance Agreement');
                    }
                    if(!attachTypesToAdd.contains('Hold Harmless Agreement')){
                        attachTypesToAdd.add('Hold Harmless Agreement');
                    }
                }
            }
            if(wrapperObj.accWrap.Category_1__c.contains('Appliances') || 
               wrapperObj.accWrap.Category_1__c.contains('Cages') ||
               wrapperObj.accWrap.Category_1__c.contains('Carpet') ||
               wrapperObj.accWrap.Category_1__c.contains('Cleaning') ||
               wrapperObj.accWrap.Category_1__c.contains('Concrete') ||
               wrapperObj.accWrap.Category_1__c.contains('Garage Doors') ||
               wrapperObj.accWrap.Category_1__c.contains('Gas') ||
               wrapperObj.accWrap.Category_1__c.contains('Gutters') ||
               wrapperObj.accWrap.Category_1__c.contains('Handyman') ||
               wrapperObj.accWrap.Category_1__c.contains('Countertops') ||               
               wrapperObj.accWrap.Category_1__c.contains('Hardwoods') ||
               wrapperObj.accWrap.Category_1__c.contains('Inspector') ||
               wrapperObj.accWrap.Category_1__c.contains('Move Outs') ||
               wrapperObj.accWrap.Category_1__c.contains('Painter') ||
               wrapperObj.accWrap.Category_1__c.contains('Project Manager') ||
               wrapperObj.accWrap.Category_1__c.contains('Rehab') ||
               wrapperObj.accWrap.Category_1__c.contains('Trash') ||
               wrapperObj.accWrap.Category_1__c.contains('Tub/Top Refinishing') ||
               wrapperObj.accWrap.Category_1__c.contains('Utility/City') ||
               wrapperObj.accWrap.Category_1__c.contains('Yard Crew') ||
               wrapperObj.accWrap.Category_1__c.contains('Photography') ||
               wrapperObj.accWrap.Category_1__c.contains('Chimneys') ||
               wrapperObj.accWrap.Category_1__c.contains('Tree Removal') ||
               wrapperObj.accWrap.Category_1__c.contains('Insulation') ||
               wrapperObj.accWrap.Category_1__c.contains('Windows')
              ){
                  if(wrapperObj.accWrap.Type == 'Rehab')
                  {
/* Consolidating to 1 Document 8/31/2023 Chris Mollet Demand Chain*/
                      if(!attachTypesToAdd.contains('Hold Harmless Agreement')){
                          attachTypesToAdd.add('Hold Harmless Agreement');
                      }
                  }
              }
        }  
        
        System.debug('wrapperObj.accWrap.Maint_Category_1__c:-----'+wrapperObj.accWrap.Maint_Category_1__c);
        
        /* Added new Markets - 5/07/2021 - Isaac A. Huicochea*/
        if(String.isNotBlank(wrapperObj.accWrap.Maint_Category_1__c)){
            if(String.isNotBlank(wrapperObj.accWrap.Market__c))
            {
                System.debug('wrapperObj.accWrap.Maint_Category_1__c:-----'+wrapperObj.accWrap.Maint_Category_1__c);
                if(wrapperObj.accWrap.Type == 'Maintenance' && (wrapperObj.accWrap.Market__c.contains('MEM') || wrapperObj.accWrap.Market__c.contains('STL')|| wrapperObj.accWrap.Market__c.contains('BHM') || wrapperObj.accWrap.Market__c.contains('HSV')||
                                                                wrapperObj.accWrap.Market__c.contains('TUS') || wrapperObj.accWrap.Market__c.contains('TLH')|| wrapperObj.accWrap.Market__c.contains('JKT') || wrapperObj.accWrap.Market__c.contains('JAN')||
                                                                wrapperObj.accWrap.Market__c.contains('CHA') || wrapperObj.accWrap.Market__c.contains('BNA')))
                {
/* Consolidating to 1 Document 8/31/2023 Chris Mollet Demand Chain*/
                    if(!attachTypesToAdd.contains('Hold Harmless Agreement')){
                        attachTypesToAdd.add('Hold Harmless Agreement');
                    }
                }
                System.debug('wrapperObj.accWrap.Type:-----'+wrapperObj.accWrap.Type);
                if(wrapperObj.accWrap.Type == 'Maintenance' && (wrapperObj.accWrap.Market__c.contains('DFW') || wrapperObj.accWrap.Market__c.contains('SAN') ||
                                                                wrapperObj.accWrap.Market__c.contains('HOU') || wrapperObj.accWrap.Market__c.contains('LIT') ||
                                                                wrapperObj.accWrap.Market__c.contains('OKC') || wrapperObj.accWrap.Market__c.contains('TUL') ||
                                                                wrapperObj.accWrap.Market__c.contains('AUS')))
                {

/* Consolidating to 1 Document 8/31/2023 Chris Mollet Demand Chain*/
                    if(!attachTypesToAdd.contains('Hold Harmless Agreement')){
                        attachTypesToAdd.add('Hold Harmless Agreement');
                    }
                    System.debug('attachTypesToAdd-----'+attachTypesToAdd);
                }
            }
            
            if(wrapperObj.accWrap.Maint_Category_1__c.contains('Electrical') || 
               wrapperObj.accWrap.Maint_Category_1__c.contains('HVAC')  ||
               wrapperObj.accWrap.Maint_Category_1__c.contains('Plumbing') ||
               wrapperObj.accWrap.Maint_Category_1__c.contains('Foundation')
              )
            {
                if(!attachTypesToAdd.contains('License')){
                    attachTypesToAdd.add('License');
                }
                if(!attachTypesToAdd.contains('Permits')){
                    attachTypesToAdd.add('Permits');
                }
            }
            
            if(wrapperObj.accWrap.Maint_Category_1__c.contains('Engineer') ||
               wrapperObj.accWrap.Maint_Category_1__c.contains('Locks') ||
               wrapperObj.accWrap.Maint_Category_1__c.contains('Chimneys') ||
               wrapperObj.accWrap.Maint_Category_1__c.contains('Insulation') ||
               wrapperObj.accWrap.Maint_Category_1__c.contains('Pest Control')
              )
            {
                if(!attachTypesToAdd.contains('License')){
                    attachTypesToAdd.add('License');
                }
            }
            
            if(wrapperObj.accWrap.Maint_Category_1__c.contains('Electrical') || 
               wrapperObj.accWrap.Maint_Category_1__c.contains('Engineer') ||
               wrapperObj.accWrap.Maint_Category_1__c.contains('Foundation') ||
               wrapperObj.accWrap.Maint_Category_1__c.contains('HVAC') ||
               wrapperObj.accWrap.Maint_Category_1__c.contains('Locks') ||
               wrapperObj.accWrap.Maint_Category_1__c.contains('Plumbing') ||
               wrapperObj.accWrap.Maint_Category_1__c.contains('Pest Control') ||
               wrapperObj.accWrap.Maint_Category_1__c.contains('Roofs') ||
               wrapperObj.accWrap.Maint_Category_1__c.contains('Chimneys') ||
               wrapperObj.accWrap.Maint_Category_1__c.contains('Tree Removal') ||
               wrapperObj.accWrap.Maint_Category_1__c.contains('Insulation') ||
               wrapperObj.accWrap.Maint_Category_1__c.contains('Windows')
              )
            {
                if(!attachTypesToAdd.contains('Certificate of Insurance - General Liability')){
                    attachTypesToAdd.add('Certificate of Insurance - General Liability');
                }
                /* Added new Markets - 5/07/2021 - Isaac A. Huicochea*/
                if(String.isNotBlank(wrapperObj.accWrap.Market__c))
                {
                    if((wrapperObj.accWrap.Type == 'Maintenance' || wrapperObj.accWrap.Type == 'Rehab & Maintenance') && (wrapperObj.accWrap.Market__c.contains('MEM') || wrapperObj.accWrap.Market__c.contains('STL')|| wrapperObj.accWrap.Market__c.contains('BHM') || wrapperObj.accWrap.Market__c.contains('HSV') ||
                                                                                                                          wrapperObj.accWrap.Market__c.contains('TUS') || wrapperObj.accWrap.Market__c.contains('TLH')|| wrapperObj.accWrap.Market__c.contains('JKT') || wrapperObj.accWrap.Market__c.contains('JAN') ||
                                                                														  wrapperObj.accWrap.Market__c.contains('CHA') || wrapperObj.accWrap.Market__c.contains('BNA')))
                    {
/* Consolidating to 1 Document 8/31/2023 Chris Mollet Demand Chain*/
                        if(!attachTypesToAdd.contains('Insurance Agreement')){
                            attachTypesToAdd.add('Insurance Agreement');
                        }
                    }
                    if((wrapperObj.accWrap.Type == 'Maintenance' || wrapperObj.accWrap.Type == 'Rehab & Maintenance') && (wrapperObj.accWrap.Market__c.contains('DFW') || wrapperObj.accWrap.Market__c.contains('SAN') ||
                                                                                                                          wrapperObj.accWrap.Market__c.contains('HOU') || wrapperObj.accWrap.Market__c.contains('LIT') ||
                                                                                                                          wrapperObj.accWrap.Market__c.contains('OKC') || wrapperObj.accWrap.Market__c.contains('TUL') ||
                                                                                                                          wrapperObj.accWrap.Market__c.contains('AUS')))
                    {
/* Consolidating to 1 Document 8/31/2023 Chris Mollet Demand Chain*/
                        if(!attachTypesToAdd.contains('Insurance Agreement')){
                            attachTypesToAdd.add('Insurance Agreement');
                        }
                        if(!attachTypesToAdd.contains('Hold Harmless Agreement')){
                            attachTypesToAdd.add('Hold Harmless Agreement');
                        }
                    }
                }
                if(wrapperObj.accWrap.Type == 'Rehab')
                {
/* Consolidating to 1 Document 8/31/2023 Chris Mollet Demand Chain*/
                    if(!attachTypesToAdd.contains('Insurance Agreement')){
                        attachTypesToAdd.add('Insurance Agreement');
                    }
                    if(!attachTypesToAdd.contains('Hold Harmless Agreement')){
                        attachTypesToAdd.add('Hold Harmless Agreement');
                    }
                }
            }
            if(wrapperObj.accWrap.Maint_Category_1__c.contains('Appliances') || 
               wrapperObj.accWrap.Maint_Category_1__c.contains('Cages') ||
               wrapperObj.accWrap.Maint_Category_1__c.contains('Carpet') ||
               wrapperObj.accWrap.Maint_Category_1__c.contains('Cleaning') ||
               wrapperObj.accWrap.Maint_Category_1__c.contains('Concrete') ||
               wrapperObj.accWrap.Maint_Category_1__c.contains('Garage Doors') ||
               wrapperObj.accWrap.Maint_Category_1__c.contains('Gutters') ||
               wrapperObj.accWrap.Maint_Category_1__c.contains('Handyman') ||
               wrapperObj.accWrap.Maint_Category_1__c.contains('Countertops') ||
               wrapperObj.accWrap.Maint_Category_1__c.contains('Process Server') ||
               wrapperObj.accWrap.Maint_Category_1__c.contains('Hardwoods') ||
               wrapperObj.accWrap.Maint_Category_1__c.contains('Misc') ||
               wrapperObj.accWrap.Maint_Category_1__c.contains('Move Outs') ||
               wrapperObj.accWrap.Maint_Category_1__c.contains('Rehab') ||
               wrapperObj.accWrap.Maint_Category_1__c.contains('Trash') ||
               wrapperObj.accWrap.Maint_Category_1__c.contains('Tub/Top Refinishing') ||
               wrapperObj.accWrap.Maint_Category_1__c.contains('Yard Crew') ||
               wrapperObj.accWrap.Maint_Category_1__c.contains('Chimneys') ||
               wrapperObj.accWrap.Maint_Category_1__c.contains('Tree Removal') ||
               wrapperObj.accWrap.Maint_Category_1__c.contains('Insulation') ||
               wrapperObj.accWrap.Maint_Category_1__c.contains('Windows')
              ){              
                  if(wrapperObj.accWrap.Type == 'Rehab & Maintenance' || wrapperObj.accWrap.Type == 'Rehab')
                  {
/* Consolidating to 1 Document 8/31/2023 Chris Mollet Demand Chain*/
                      if(!attachTypesToAdd.contains('Hold Harmless Agreement')){
                          attachTypesToAdd.add('Hold Harmless Agreement');
                      }
                  }
              }   
        } 
        
        System.debug('attachTypesToAdd-----'+attachTypesToAdd);
        
        if(!attachTypesToAdd.isEmpty()){
            for(String attachType: attachTypesToAdd){
                if(attachType == 'Certificate of Insurance or Waiver - Workers Comp' || 
                   attachType == 'Permanent Resident Card / Green Card' || 
                   attachType == 'Employment Authorization Document / Work Permit' ||
                   attachType == 'Employment Visa')
                {
                    if(!attachTypesToAddTemp.contains(attachType)){
                        ContentWrapper cvWrap = new ContentWrapper();
                        if(langRehabContractorCheck) {  
                            cvWrap.attachType = SpanishUtil.spanishAttachVal(attachType);  
                        }
                        else{
                            cvWrap.attachType = attachType;
                        }
                        cvWrapAdditionalList.add(cvWrap);
                    }
                }
                else{
                    if(!attachTypesToAddTemp.contains(attachType)){
                        ContentWrapper cvWrap = new ContentWrapper();
                        if(langRehabContractorCheck) {  
                            cvWrap.attachType = SpanishUtil.spanishAttachVal(attachType);  
                        }
                        else{
                            cvWrap.attachType = attachType;
                        }
                        cvWrapList.add(cvWrap);
                    }
                }
            }    
            System.debug('cvWrapList-----'+cvWrapList);
        }     
    }    
    
    //creates a list of attachments to show on file upload stage
    public void attachFileFunction(){
        error = '';
        if(String.isNotBlank(attachId)){           
            attachmentIdList.add(attachId); 
            wrapperObj.accWrap.Is_Uploaded__c = true;
            
            /*
//Email on New Upload
Messaging.SingleEmailMessage email;
List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();        
List<EmailTemplate> emailTemplateList = [select id,name,HtmlValue from EmailTemplate where developername=:'Vendor_Document_Uploaded'];
System.debug('emailTemplateList-----'+emailTemplateList);
Set<String> usrNameSet = new Set<String>();
for(String usrName: Label.Vendor_Approval_Team.split(',')){
usrNameSet.add(usrName.trim());
}
List<User> usrList = [SELECT Id, Email FROM User WHERE Name IN: usrNameSet AND IsActive = true];
System.debug('usrList-----'+usrList);
if(!emailTemplateList.isEmpty() && !usrList.isEmpty()){
for(ContentVersion cv: [Select id,OwnerId,FirstPublishLocationId,ContentDocumentId,Title,VersionData,Attachment_Type__c,Status__c,Expiration_Date__c From ContentVersion where id =: attachId AND IsLatest = true]){
String emailBody = emailTemplateList[0].HtmlValue;
List<String> toaddress = new List<String>();
email = new Messaging.SingleEmailMessage();
email.setTemplateID(emailTemplateList[0].id);
system.debug(emailBody) ;               
emailBody = emailBody.replace('[ATTACH TYPE]','<a href="'+Label.OrgMyURL+'/lightning/r/ContentDocument/'+cv.ContentDocumentId+'/view">'+cv.Attachment_Type__c+'</a>');
email.setHTMLBody(emailBody);

email.setWhatId(cv.Id);
email.setTreatTargetObjectAsRecipient(false);
email.setSaveAsActivity(false); 
email.setTreatTargetObjectAsRecipient(false);                        
//toaddress.add(accountMap.get(accId).Primary_Contact_Email__c);
for(User usr: usrList){
toaddress.add(usr.Email);
}
email.setToAddresses(toaddress);             
emails.add(email);
}
} 

if(!emails.isEmpty()) {
Messaging.SendEmail(emails);
}   
//Email on New Upload End
*/               
        }
        if(attachmentIdList.size() > 0){
            if(cvWrapList.size()>0){
                cvWrapList.clear();
            }
            
            for(ContentVersion cv: [Select id,OwnerId,FirstPublishLocationId,ContentDocumentId,Title,VersionData,Attachment_Type__c,Status__c,Expiration_Date__c From ContentVersion where id IN :attachmentIdList AND IsLatest = true]){
                ContentWrapper cvWrap = new ContentWrapper();
                cvWrap.recId = cv.Id;
                cvWrap.conDocId = cv.ContentDocumentId;
                cvWrap.title = cv.Title;
                cvWrap.expDt = cv.Expiration_Date__c;
                System.debug('langRehabContractorCheck----'+langRehabContractorCheck);
                if(langRehabContractorCheck) {  
                    cvWrap.attachType = SpanishUtil.spanishAttachVal(cv.Attachment_Type__c);  
                    System.debug('cvWrap.attachType----'+cvWrap.attachType);
                }
                else{
                    cvWrap.attachType = cv.Attachment_Type__c;
                }
                cvWrapList.add(cvWrap);
                attachTypesToAdd.add(cv.Attachment_Type__c); 
                attachTypesToAddTemp.add(cv.Attachment_Type__c); 
                
                if(cv.Attachment_Type__c == 'Direct Deposit Agreement' && cv.Status__c == 'Uploaded')
                {
                    isDDAUploaded = true;
                } 
                if(cv.Attachment_Type__c == 'Voided Check' && cv.Status__c == 'Uploaded')
                {
                    isVCUploaded = true;
                } 
                if(cv.Attachment_Type__c == 'License' && cv.Status__c == 'Uploaded')
                {
                    isLicenseUploaded = true;
                } 
                if(cv.Attachment_Type__c == 'Permits' && cv.Status__c == 'Uploaded')
                {
                    isPermitsUploaded = true;
                } 
            } 
            
        }
        createReqDocTable();
    }
    
    
    public List<RehabTradeWrapper> rehabContractorTrades(){
        /* Replaced Inaccurate Words - 5/07/2021 - Isaac A. Huicochea*/
        lst_rehabContractorTrades = new List<RehabTradeWrapper>();
        List<SelectOption> options = new List<SelectOption>();        
        if(langRehabContractorCheck) {           
            options.add(new SelectOption('Cages', 'Caja de Unidad de Aire Acondieionado')); 
            options.add(new SelectOption('Carpet', 'Alfombra'));
            options.add(new SelectOption('Cleaning', 'Limpieza'));
            options.add(new SelectOption('Concrete', 'Hormigón'));
            options.add(new SelectOption('Electrical', 'Eléctricidad'));
            options.add(new SelectOption('Foundation', 'Fundación'));
            options.add(new SelectOption('Garage Doors', 'Puertas de garaje'));        
            options.add(new SelectOption('Chimneys', 'Chimeneas'));
            options.add(new SelectOption('Handyman', 'Personal de mantenimiento'));
            options.add(new SelectOption('Countertops', 'Countertops'));
            options.add(new SelectOption('Hardwoods', 'Maderas duras'));
            options.add(new SelectOption('HVAC', 'HVAC'));            
            options.add(new SelectOption('Inspector', 'Inspectora'));
            options.add(new SelectOption('Locks', 'Cerraduras'));
            options.add(new SelectOption('Move Outs', 'Mover salidas'));            
            // options.add(new SelectOption('Painter', 'Pintora'));
            options.add(new SelectOption('Pest Control', 'Control de plagas'));
            options.add(new SelectOption('Plumbing', 'Plomería'));
            //options.add(new SelectOption('Project Manager', 'Gerente de proyecto'));
            options.add(new SelectOption('Cosmetic Rehab Vendor', 'Rehabilitación'));
            options.add(new SelectOption('Roofs', 'Techos'));
            options.add(new SelectOption('Trash', 'Basura'));
            options.add(new SelectOption('Utility/City', 'Utilidad / Ciudad'));
            options.add(new SelectOption('Photography', 'fotografía'));
            options.add(new SelectOption('Yard Crew', 'Tripulación de la yarda'));
            options.add(new SelectOption('Insulation', 'Aislamiento'));
            options.add(new SelectOption('Tree Removal', 'Remoción de árboles'));
        } else {         
            Schema.DescribeFieldResult fieldResult = Account.Category_1__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry f : ple)
            {
                options.add(new SelectOption(f.getLabel(),f.getValue()));
            } 
        }
        rehabCatString = '';
        for(SelectOption opt: options){
            RehabTradeWrapper wrap = new RehabTradeWrapper(false,  opt.getLabel(), opt.getValue());
            if(String.isNotBlank(wrapperObj.accWrap.Category_1__c)){
                if(wrapperObj.accWrap.Category_1__c.contains(wrap.value)){
                    if(String.isBlank(rehabCatString)){
                        rehabCatString = langRehabContractorCheck ? SpanishUtil.spanishRehabTradeVal(wrap.value) : wrap.value;
                    }
                    else{
                        rehabCatString += ';' + (langRehabContractorCheck ? SpanishUtil.spanishRehabTradeVal(wrap.value) : wrap.value);
                    }
                    wrap.isSelected = true;
                }
            }
            lst_rehabContractorTrades.add(wrap);
        }
        System.debug('rehabCatString-----'+rehabCatString);
        
        return lst_rehabContractorTrades;
        
    }
    
    
    public List<RehabTradeWrapper> maintenanceProviderTrades(){
        /* Replaced Inaccurate Words - 5/07/2021 - Isaac A. Huicochea*/
        lst_maintenanceProviderTrades = new List<RehabTradeWrapper>();
        List<SelectOption> options = new List<SelectOption>();
        if(langRehabContractorCheck) {           
            options.add(new SelectOption('Cages', 'Caja de Unidad de Aire Acondieionado')); 
            options.add(new SelectOption('Carpet', 'Alfombra'));
            options.add(new SelectOption('Cleaning', 'Limpieza'));
            options.add(new SelectOption('Concrete', 'Hormigón'));
            options.add(new SelectOption('Electrical', 'Eléctricidad'));
            options.add(new SelectOption('Foundation', 'Fundación'));
            options.add(new SelectOption('Garage Doors', 'Puertas de garaje')); 
            options.add(new SelectOption('Chimneys', 'Chimeneas'));
            //options.add(new SelectOption('Gas', 'Gas'));
            options.add(new SelectOption('Handyman', 'Personal de mantenimiento'));
            options.add(new SelectOption('Countertops', 'Countertops'));
            options.add(new SelectOption('Process Server', 'Process Server'));
            options.add(new SelectOption('Hardwoods', 'Maderas duras'));
            options.add(new SelectOption('HVAC', 'HVAC'));            
            //options.add(new SelectOption('Inspector', 'Inspectora'));
            options.add(new SelectOption('Locks', 'Cerraduras'));
            options.add(new SelectOption('Move Outs', 'Mover salidas'));            
            //options.add(new SelectOption('Painter', 'Pintora'));
            options.add(new SelectOption('Pest Control', 'Control de plagas'));
            options.add(new SelectOption('Plumbing', 'Plomería'));
            //options.add(new SelectOption('Project Manager', 'Gerente de proyecto'));
            options.add(new SelectOption('Rehab', 'Rehabilitación'));
            options.add(new SelectOption('Roofs', 'Techos'));
            options.add(new SelectOption('Trash', 'Basura'));
            options.add(new SelectOption('Insulation', 'Aislamiento'));
            options.add(new SelectOption('Tree Removal', 'Remoción de árboles'));
            //options.add(new SelectOption('Utility/City', 'Utilidad / Ciudad'));
            options.add(new SelectOption('Yard Crew', 'Tripulación de la yarda'));
        } else { 
            Schema.DescribeFieldResult fieldResult = Account.Maint_Category_1__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry f : ple)
            {
                options.add(new SelectOption(f.getLabel(),f.getValue()));
            }
        } 
        maintCatString = '';      
        for(SelectOption opt: options){
            RehabTradeWrapper wrap = new RehabTradeWrapper(false, opt.getLabel(), opt.getValue());
            if(String.isNotBlank(wrapperObj.accWrap.Maint_Category_1__c)){
                if(wrapperObj.accWrap.Maint_Category_1__c.contains(wrap.value)){
                    if(String.isBlank(maintCatString)){
                        maintCatString = langRehabContractorCheck ? SpanishUtil.spanishRehabTradeVal(wrap.value) : wrap.value;
                    }
                    else{
                        maintCatString += ';' + (langRehabContractorCheck ? SpanishUtil.spanishRehabTradeVal(wrap.value) : wrap.value);
                    }
                    wrap.isSelected = true;
                }
            }
            lst_maintenanceProviderTrades.add(wrap);
        }
        
        return lst_maintenanceProviderTrades;
        
    }
    
    //This method is user for redirect vf page 
    public PageReference doCancel() { 
        PageReference demoPage = new pagereference('/VendorPortalHome');
        demoPage.setRedirect(true);
        return demoPage;
    }   
    
    // Wrapper Class
    Public Class ContactWrapper{    
        public Account accWrap{get;set;}
        public Contact primaryConWrap{get;set;}
        public list<contact> conListWrap{get;set;}
        
        public ContactWrapper(){
            accWrap = new Account();
            primaryConWrap = new Contact();
            conListWrap = new list<contact>();
        }    
    }
    
    // Wrapper Class
    Public class ContentWrapper{  
        public Id recId{get;set;}  
        public Id conDocId{get;set;}
        public String title{get;set;}
        public String attachType{get;set;}  
        public Date expDt{get;set;}  
        public String status{get;set;}    
    }
    
    // Wrapper Class
    public Class MarketWrapper{    
        public Boolean isSelected{get;set;}
        public String label{get;set;}
        public String value{get;set;}
        
        public MarketWrapper(Boolean sel,  String lbl,String val) {
            this.isSelected = sel;             
            this.label = lbl;
            this.value = val;                    
        }
    }
    
    // Wrapper Class
    public Class RehabTradeWrapper{    
        public Boolean isSelected{get;set;}
        public String label{get;set;}
        public String value{get;set;}
        
        public RehabTradeWrapper(Boolean sel,  String lbl,String val) {
            this.isSelected = sel;             
            this.label = lbl;
            this.value = val;                    
        }
    }
}