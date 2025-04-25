public with sharing class OpportunityTriggerHandler {
    public static List<Opportunity> newList {get; set;}
    public static List<Opportunity> oldList {get; set;}
    public static Map<Id, Opportunity> newMap {get; set;}
    public static Map<Id, Opportunity> oldMap {get; set;}
    
    
    public static void beforeUpdate(){
        setDefaultValuesForSalesOppBeforeUpdate(); //new Method
        validateRenovationProjectOnSalesOpportunity('BEFORE_UPDATE');
        projectEvaluationStatusBeforeUpdate();
        requiredFieldValidation();
        validateFollowUpSoldDateForBuyOppBeforeUpdate();
        //     lockOpportunit();
    }
    
    public static void afterUpdate(){
        updateHouse();
        fillHouseNameToBuyOppNameBeforeUpdate();
        updateRenoProjAfterUpdate();
        updateBuyOppAssessName('UPDATE');
        afterUpdateSendEmail(); //
        //createContract();
        afterUpdateUpdateContactRole();
    }
    
    public static void afterInsert(){   
        fillHouseNameToBuyOppNameAfterInsert();
        updateBuyOppAssessName('INSERT');
        afterInsertSendEmail();
        setDefaultValue(); // new Nov 24
        afterInsertUpdateContactRole(); // new Jan 5 21
    }
    
    public static void beforeInsert(){
        validateRenovationProjectOnSalesOpportunity('BEFORE_INSERT');
        requiredFieldValidation();
        setDefaultValuesForBuyOppBeforeInsert();
        setDefaultValuesForSalesOppBeforeInsert();
    }
    
    /* public static void lockOpportunit(){

Set<id> salesRecordTypeIdSet = new Set<id>();
for(RecordType rt : [SELECT id FROM RecordType where sObjectType = 'Opportunity' AND Name LIKE 'Investor%']){
salesRecordTypeIdSet.add(rt.id);
}

for(Opportunity opp : newList){
if(oldMap.get(opp.Id).StageName == 'Cancelled' && opp.CLONE__c == false ){
if(salesRecordTypeIdSet.contains(opp.RecordTypeId)){
//opp.AddError('You cannot update the cancelled opportunity'); 
}
} else if(oldMap.get(opp.Id).StageName != 'Cancelled' && newMap.get(opp.Id).stageName != 'Cancelled'){
//opp.AddError('You can clone only a cancelled opportunity');
}
}
}  */   
    /*public static void createContract(){
        List<Contract> contractToInsertList = new List<Contract>();
        List<Contract> listContract=[select Id FROM Contract where Opportunity__c IN: trigger.newMap.keySet()];
        
        EmailTemplate et = [SELECT Id,Subject,HtmlValue,Body FROM EmailTemplate WHERE Name = 'New PMA Contract'];
        List<String> addresses = new List<String>();
        List<Contract_Email__mdt> customList = [SELECT Id, Name__c, Email__c FROM Contract_Email__mdt];
        for(Contract_Email__mdt conObj : customList){
            addresses.add(conObj.Email__c);
        }
        
        OrgWideEmailAddress orgEmail = [select Id, DisplayName, Address from OrgWideEmailAddress where DisplayName = 'Portfolio Advisor'];
        Set<id> salesRecordTypeIdSet = new Set<id>();
        for(RecordType rt : [SELECT id FROM RecordType where sObjectType = 'Opportunity' AND Name LIKE 'Investor%']){
            salesRecordTypeIdSet.add(rt.id);
        }
        
        for(Opportunity opp : newList){
            if(listContract.isEmpty()){
                if(salesRecordTypeIdSet.contains(opp.RecordTypeId)){
                    if (opp.StageName == 'Closed' && oldMap.get(opp.Id).StageName != 'Closed' && (opp.Closing_Date__c != null)){
                        if(opp.Closing_Date__c.addMonths(12) > system.today()){
                            if(opp.AccountId != NULL){   
                                system.debug('No Valid contract');
                                Contract contractToInsert=new Contract();
                                contractToInsert.RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get(Label.Contract_Record_Type).getRecordTypeId();
                                contractToInsert.AccountId=opp.AccountId;
                                contractToInsert.Opportunity__c=opp.Id;
                                contractToInsert.Status='Draft';
                                contractToInsert.ContractTerm=12;
                                contractToInsert.StartDate=opp.Closing_Date__c;
                                                                
                                if(opp.Property_Management_Reduction__c != NULL){
                                    contractToInsert.Property_Management_Fee__c = opp.Property_Management_Reduction__c;
                                }else if(opp.Property_Management_Reduction_P_A__c != NULL){
                                    contractToInsert.Property_Management_Fee__c = opp.Property_Management_Reduction_P_A__c;
                                }else{
                                    contractToInsert.Property_Management_Fee__c = 10;
                                }
                                if(opp.For_x_Months__c != NULL){
                                    contractToInsert.Property_Management_Fee_Concession_Exp__c = contractToInsert.StartDate.addMonths(opp.For_x_Months__c.intValue());
                                }else if(opp.For_x_Months_Post_Appraisal__c != NULL){
                                    contractToInsert.Property_Management_Fee_Concession_Exp__c = contractToInsert.StartDate.addMonths(opp.For_x_Months_Post_Appraisal__c.intValue());
                                }else{
                                    contractToInsert.Property_Management_Fee_Concession_Exp__c = NULL;
                                }
                                contractToInsertList.add(contractToInsert);
                                
                                String htmlbody = et.HtmlValue;
                                List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>(); 
                                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                                email.setOrgWideEmailAddressId(orgEmail.Id);
                                email.setSubject(et.Subject);
                                email.setHTMLBody(htmlbody);
                                email.setToAddresses(addresses);
                                emailList.add(email);
                                
                                if(emailList.size() > 0){
                                    Messaging.SendEmailResult[] res = Messaging.sendEmail(emailList);
                                }
                            }
                        }
                    }
                }
            }
        }
        System.debug('Contract '+contractToInsertList);
        insert contractToInsertList;
        
        List<Contract> conToUpdate=new List<Contract>();
        for(Contract contractUpdate: contractToInsertList){
            contractUpdate.Status='Activated';
            conToUpdate.add(contractUpdate);
        }
        update conToUpdate;   
    }*/ // create contract
    
    public static void updateBuyOppAssessName(String triggerContext){
        
        Id BuyRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Buy').getRecordTypeId();
        Set<id> oppIdSet =  new Set<id>();
        Map<id,String> assIdOppNameMap = new Map<id,String>();
        for(Opportunity opp : newList){
            if(opp.RecordTypeId == BuyRecordType && opp.Assessment__c != null){
                if(triggerContext == 'UPDATE'){
                    if(opp.Assessment__c != oldMap.get(opp.id).Assessment__c){
                        if(!assIdOppNameMap.containsKey(opp.Assessment__c)){
                            assIdOppNameMap.put(opp.Assessment__c,opp.Name);
                        }
                    }
                }else if(triggerContext == 'INSERT'){
                    if(!assIdOppNameMap.containsKey(opp.Assessment__c)){
                        assIdOppNameMap.put(opp.Assessment__c,opp.Name);
                    }
                }
            }
        }
        
        if(!assIdOppNameMap.isEmpty()){
            List<Assessment__c> assList = new List<Assessment__c>();
            for(Assessment__c ass : [SELECT Id FROM Assessment__c WHERE ID IN : assIdOppNameMap.keySet() AND CreatedDate = TODAY]){
                if(assIdOppNameMap.containsKey(ass.id)){
                    ass.Name = assIdOppNameMap.get(ass.id);
                    assList.add(ass);
                }
            }
            
            if(assList.size() > 0){
                Update assList;
            }
        }
    }
    
    public static void updateRenoProjAfterUpdate(){
        
        Set<id> salesRecordTypeIdSet = new Set<id>();
        for(RecordType rt : [SELECT id FROM RecordType where sObjectType = 'Opportunity' AND Name LIKE 'Investor%']){
            salesRecordTypeIdSet.add(rt.id);
        }
        
        Id renovationRecordType = Schema.SObjectType.Project__c.getRecordTypeInfosByName().get('Renovation').getRecordTypeId();
        
        Set<id> oldRenovationProject = new Set<id>();
        Map<id,id> projIdSalesOppIdMap = new Map<id,id>();
        for(Opportunity opp : [SELECT Id,Project__c,Project__r.RecordTypeId FROM Opportunity WHERE Id IN : newList AND RecordTypeId IN : salesRecordTypeIdSet])
        {
            if(opp.Project__c != null && opp.Project__r.RecordTypeId == renovationRecordType){
                if(opp.Project__c != oldMap.get(opp.id).Project__c){
                    if(!projIdSalesOppIdMap.containsKey(opp.Project__c)){
                        projIdSalesOppIdMap.put(opp.Project__c,opp.id);
                    }
                    if(oldMap.get(opp.id).Project__c != Null){
                        oldRenovationProject.add(oldMap.get(opp.id).Project__c);
                    }
                }
            }else{
                if(oldMap.get(opp.id).Project__c != Null){
                    oldRenovationProject.add(oldMap.get(opp.id).Project__c);
                }
            }
        }
        System.debug('oldRenovationProject'+oldRenovationProject);
        System.debug('projIdSalesOppIdMap'+projIdSalesOppIdMap);
        List<Project__c> projectList = new List<Project__c>();
        if(oldRenovationProject.size() > 0 || !projIdSalesOppIdMap.isEmpty()){
            for(Project__c proj : [SELECT Id,RecordTypeId FROM Project__c WHERE  Id IN : projIdSalesOppIdMap.keySet() OR Id IN : oldRenovationProject]){
                if(oldRenovationProject.contains(proj.id) && proj.RecordTypeId == renovationRecordType ){
                    proj.Opportunity__c = null;
                    projectList.add(proj);
                }else{
                    if(projIdSalesOppIdMap.containsKey(proj.id)){
                        proj.Opportunity__c = projIdSalesOppIdMap.get(proj.id);
                        projectList.add(proj);
                    }
                }
            }
        }
        System.debug('projectList'+projectList);
        if(projectList.size() > 0){
            Update projectList;
        }
    }
    
    public static void validateFollowUpSoldDateForBuyOppBeforeUpdate(){
        Id BuyRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Buy').getRecordTypeId();
        
        Set<id> oppIdSet = new Set<id>();
        for(Opportunity opp : newList){
            if(opp.RecordTypeId == BuyRecordType && oldMap.get(opp.id).Follow_Up_Sold_Date__c != null){
                if(opp.Follow_Up_Sold_Date__c == null){
                    opp.Follow_Up_Sold_Date__c.addError('Follow Up/Sold Date cannot be empty');
                }
            }
        }
    }
    
    public static void setDefaultValuesForBuyOppBeforeInsert(){
        
        Id BuyRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Buy').getRecordTypeId();
        for(Opportunity opp : newList){
            if(opp.RecordTypeId == BuyRecordType){
                opp.StageName = 'Pre-Assessment';
                //opp.LeadSource = 'Wholesaler';  
            }
        }
    }
    //
    public static void setDefaultValue(){
        Set<Id> idSetOpp = new Set<Id>();
        for(Opportunity opp : newList){
            idSetOpp.add(opp.Id);
        }
        if(!System.isFuture() && !System.isBatch()){
            setDefaultValuesForSalesOppAfterInsert(idSetOpp);
        }    
    }
    @future
    public static void setDefaultValuesForSalesOppAfterInsert(Set<Id> idSetOpp){
        List<Account> clientAcc = [SELECT Id, Name, Standard_Referral_Fee__c, X2nd_Layer_Referral_Fee__c, Referred_by__c, Referred_by__r.Standard_Referral_Fee__c, Referred_by__r.X2nd_Layer_Referral_Fee__c
                             FROM Account WHERE RecordType.Name = 'Affiliates' AND Name = 'Client Referral' LIMIT 1];
        Map<Id, Account> accMap = new Map<Id, Account>();
        Set<Id> accIdSet = new Set<Id>();
        for(Opportunity oppObj : [SELECT Id, AccountId FROM Opportunity WHERE Id IN:idSetOpp]){
            accIdSet.add(oppObj.AccountId);
        }
        
        for(Account acc : [SELECT Id, Name, RecordType.Name, Standard_Referral_Fee__c, X2nd_Layer_Referral_Fee__c, Referred_by__c, Referred_by__r.RecordTypeId,
                           Referred_by__r.Standard_Referral_Fee__c, Referred_by__r.X2nd_Layer_Referral_Fee__c, Referred_by__r.Referred_by__r.X2nd_Layer_Referral_Fee__c
                           FROM Account WHERE Id IN: accIdSet]){
            accMap.put(acc.Id, acc);
        }
        System.debug('Map '+accMap);
        Id oppInvProp = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Investor Prospect').getRecordTypeId();
        Id oppInvOwn = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Investor Owner').getRecordTypeId();
        Id oppInv = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Investor').getRecordTypeId();
        Id accInvPorp = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Investor Prospect').getRecordTypeId();
        Id accInvOwn = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Investor Owner').getRecordTypeId();
        Id accAff = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Affiliates').getRecordTypeId();
        List<Opportunity> oppList = new List<Opportunity>();
        for(Opportunity opp : [SELECT Id, AccountId, StageName, RecordTypeId, Standard_Referral_Fee__c, X2nd_Layer_Referral_Fee__c FROM Opportunity WHERE Id IN: idSetOpp]){
            if(opp.RecordTypeId == oppInvProp || opp.RecordTypeId == oppInv ){ 
                opp.StageName = 'Pre-Qual';
            }
            if((opp.RecordTypeId == oppInvProp || opp.RecordTypeId == oppInvOwn || opp.RecordTypeId == oppInv ) && opp.AccountId != NULL){
                if(accMap.get(opp.AccountId).Referred_by__r.RecordTypeId == accInvPorp || accMap.get(opp.AccountId).Referred_by__r.RecordTypeId == accInvOwn){
                    if(clientAcc.size() > 0){
                        opp.Standard_Referral_Fee__c = clientAcc[0].Standard_Referral_Fee__c;
                        opp.X2nd_Layer_Referral_Fee__c = clientAcc[0].Referred_by__r.X2nd_Layer_Referral_Fee__c; //X2nd_Layer_Referral_Fee__c
                    }
                  //  Now check this affiliate account referred by and get the second layer fee.
                }else if(accMap.get(opp.AccountId).Referred_by__r.RecordTypeId == accAff){
                    opp.Standard_Referral_Fee__c = accMap.get(opp.AccountId).Referred_by__r.Standard_Referral_Fee__c;
                    opp.X2nd_Layer_Referral_Fee__c = accMap.get(opp.AccountId).Referred_by__r.Referred_by__r.X2nd_Layer_Referral_Fee__c; //Referred_by__r.X2nd_Layer_Referral_Fee__c;
                  //  Now check this affiliate account referred by and get the second layer fee
                }
            }
            oppList.add(opp);
        }
        if(oppList.size() > 0){
            update oppList;
        }
    }
    //
    public static void setDefaultValuesForSalesOppBeforeInsert(){
        List<Account> clientAcc = [SELECT Id, Name, Standard_Referral_Fee__c, X2nd_Layer_Referral_Fee__c, Referred_by__c, Referred_by__r.Standard_Referral_Fee__c, Referred_by__r.X2nd_Layer_Referral_Fee__c
                             FROM Account WHERE RecordType.Name = 'Affiliates' AND Name = 'Client Referral' LIMIT 1];
        Map<Id, Account> accMap = new Map<Id, Account>();
        Set<Id> accIdSet = new Set<Id>();
        for(Opportunity oppObj : newList){
            accIdSet.add(oppObj.AccountId);
        }
        
        for(Account acc : [SELECT Id, Name, RecordType.Name, Standard_Referral_Fee__c, X2nd_Layer_Referral_Fee__c, Referred_by__c, Referred_by__r.RecordTypeId,
                           Referred_by__r.Standard_Referral_Fee__c, Referred_by__r.X2nd_Layer_Referral_Fee__c, Referred_by__r.Referred_by__r.X2nd_Layer_Referral_Fee__c
                           FROM Account WHERE Id IN: accIdSet]){
            accMap.put(acc.Id, acc);
        }
        System.debug('Map '+accMap);
        Id oppInvProp = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Investor Prospect').getRecordTypeId();
        Id oppInvOwn = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Investor Owner').getRecordTypeId();
        Id oppInv = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Investor').getRecordTypeId();
        Id accInvPorp = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Investor Prospect').getRecordTypeId();
        Id accInvOwn = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Investor Owner').getRecordTypeId();
        Id accAff = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Affiliates').getRecordTypeId();
        for(Opportunity opp : newList){
            if(opp.RecordTypeId == oppInvProp || opp.RecordTypeId == oppInv ){ 
                opp.StageName = 'Pre-Qual';
            }
            if((opp.RecordTypeId == oppInvProp || opp.RecordTypeId == oppInvOwn || opp.RecordTypeId == oppInv ) && opp.AccountId != NULL){
                if(accMap.get(opp.AccountId).Referred_by__r.RecordTypeId == accInvPorp || accMap.get(opp.AccountId).Referred_by__r.RecordTypeId == accInvOwn){
                    if(clientAcc.size() > 0){
                        opp.Standard_Referral_Fee__c = clientAcc[0].Standard_Referral_Fee__c;
                        opp.X2nd_Layer_Referral_Fee__c = clientAcc[0].Referred_by__r.X2nd_Layer_Referral_Fee__c; //X2nd_Layer_Referral_Fee__c
                    }
                  //  Now check this affiliate account referred by and get the second layer fee.
                }else if(accMap.get(opp.AccountId).Referred_by__r.RecordTypeId == accAff){
                    opp.Standard_Referral_Fee__c = accMap.get(opp.AccountId).Referred_by__r.Standard_Referral_Fee__c;
                    opp.X2nd_Layer_Referral_Fee__c = accMap.get(opp.AccountId).Referred_by__r.Referred_by__r.X2nd_Layer_Referral_Fee__c; //Referred_by__r.X2nd_Layer_Referral_Fee__c;
                  //  Now check this affiliate account referred by and get the second layer fee
                }
            }
        }
    }
    // Before Update 11 Nov
    public static void setDefaultValuesForSalesOppBeforeUpdate(){
        List<Account> clientAcc = [SELECT Id, Name, Standard_Referral_Fee__c, X2nd_Layer_Referral_Fee__c, Referred_by__c, Referred_by__r.Standard_Referral_Fee__c, Referred_by__r.X2nd_Layer_Referral_Fee__c
                             FROM Account WHERE RecordType.Name = 'Affiliates' AND Name = 'Client Referral' LIMIT 1];
        Map<Id, Account> accMap = new Map<Id, Account>();
        Set<Id> accIdSet = new Set<Id>();
        for(Opportunity oppObj : newList){
            accIdSet.add(oppObj.AccountId);
        }
        
        for(Account acc : [SELECT Id, Name, RecordType.Name, Standard_Referral_Fee__c, X2nd_Layer_Referral_Fee__c, Referred_by__c, Referred_by__r.RecordTypeId,
                           Referred_by__r.Standard_Referral_Fee__c, Referred_by__r.X2nd_Layer_Referral_Fee__c, Referred_by__r.Referred_by__r.X2nd_Layer_Referral_Fee__c
                           FROM Account WHERE Id IN: accIdSet]){
            accMap.put(acc.Id, acc);
        }
        System.debug('Map '+accMap);
        Id oppInvProp = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Investor Prospect').getRecordTypeId();
        Id oppInvOwn = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Investor Owner').getRecordTypeId();
        Id oppInv = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Investor').getRecordTypeId();
        Id accInvPorp = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Investor Prospect').getRecordTypeId();
        Id accInvOwn = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Investor Owner').getRecordTypeId();
        Id accAff = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Affiliates').getRecordTypeId();
        for(Opportunity opp : newList){
            System.debug('Opp AccId '+opp.AccountId);
            if((opp.RecordTypeId == oppInv || opp.RecordTypeId == oppInvOwn || opp.RecordTypeId == oppInvProp) && opp.AccountId != NULL){
                if(accMap.get(opp.AccountId).Referred_by__r.RecordTypeId == accInvOwn || accMap.get(opp.AccountId).Referred_by__r.RecordTypeId == accInvPorp){
                    if(clientAcc.size() > 0){
                        opp.Standard_Referral_Fee__c = clientAcc[0].Standard_Referral_Fee__c;
                        opp.X2nd_Layer_Referral_Fee__c = clientAcc[0].Referred_by__r.X2nd_Layer_Referral_Fee__c; //X2nd_Layer_Referral_Fee__c
                    }
                }else if(accMap.get(opp.AccountId).Referred_by__r.RecordTypeId == accAff){
                    opp.Standard_Referral_Fee__c = accMap.get(opp.AccountId).Referred_by__r.Standard_Referral_Fee__c;
                    opp.X2nd_Layer_Referral_Fee__c = accMap.get(opp.AccountId).Referred_by__r.Referred_by__r.X2nd_Layer_Referral_Fee__c; //Referred_by__r.X2nd_Layer_Referral_Fee__c
                }
            }
        }
    }
    
    public static void fillHouseNameToBuyOppNameBeforeUpdate(){
        
        Id BuyRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Buy').getRecordTypeId();
        
        Set<id> oppIdSet = new Set<id>();
        for(Opportunity opp : newList){
            if(opp.RecordTypeId == BuyRecordType && opp.House__c != null){
                if(opp.House__c != oldMap.get(opp.id).House__c){
                    oppIdSet.add(opp.id);
                }
            }
        }
        
        if(oppIdSet.size() > 0){
            
            List<Opportunity> oppList = new List<Opportunity>();
            for(Opportunity opp : [SELECT Id, Name, House__r.Name FROM Opportunity WHERE Id IN : oppIdSet ]){
                opp.Name = opp.House__r.Name;
                oppList.add(opp);
            }
            if(oppList.size() > 0){
                UPDATE oppList;
            }
        }
    }
    
    public static void fillHouseNameToBuyOppNameAfterInsert(){
        Id BuyRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Buy').getRecordTypeId();
        List<Opportunity> oppList = new List<Opportunity>();
        for(Opportunity opp : [SELECT Id, Name, House__c, House__r.Name FROM Opportunity WHERE Id IN : newList AND RecordTypeId =: BuyRecordType AND House__c != Null]){
            opp.Name = opp.House__r.Name;
            oppList.add(opp);
        }
        
        if(oppList.size() > 0){
            UPDATE oppList;
        }
    }
    
    public static void validateRenovationProjectOnSalesOpportunity(STRING TRIGGER_EVENT){
        
        //Sales Opportunity recordType Id Set
        Set<id> recordTypeIdSet = new Set<id>();
        
        // This query is used to get all recodType whose name contains Investor i.e "Sales Opportunity"
        for(RecordType oppRt : [SELECT Id FROM RecordType WHERE SobjectType ='Opportunity' AND Name Like 'Investor%'])
        {
            recordTypeIdSet.add(oppRt.id);
        }
        
        // Add projectid in the set to check if it is Renovation and if there exist a sales opportunity under that project 
        Set<id> projectIdSet = new set<id>();
        for(Opportunity opp : newList){
            
            // Here we are checking trigger event BEFORE_INSERT
            if(String.isNotBlank(TRIGGER_EVENT) && TRIGGER_EVENT == 'BEFORE_INSERT')
            {
                if(opp.Project__c != null && recordTypeIdSet.contains(opp.RecordTypeId)){
                    projectIdSet.add(opp.Project__c);
                }
            }
            
            // Here we are checking trigger event BEFORE_UPDATE to check if Project__c lookup is changed or not
            if(String.isNotBlank(TRIGGER_EVENT) && TRIGGER_EVENT == 'BEFORE_UPDATE')
            {
                if(opp.Project__c != null && oldMap.get(opp.id).Project__c != opp.Project__c && recordTypeIdSet.contains(opp.RecordTypeId)){
                    projectIdSet.add(opp.Project__c);
                }
            }
        }
        
        // Map of projectid and SalesOpp 
        Map<id,Boolean> projectOppMap = new Map<id,Boolean>();
        if(projectIdSet.size() > 0){
            for(Project__c proj : [SELECT Id,(SELECT Id FROM Opportunities__r WHERE RecordTypeId IN :recordTypeIdSet) 
                                   FROM Project__c WHERE Id IN :projectIdSet AND RecordType.Name='Renovation'])
            {
                if(!projectOppMap.containsKey(proj.id) && proj.Opportunities__r.size() > 0){
                    projectOppMap.put(proj.id,True);
                }
            }
        }
        
        // Loop through all sales opprtunities to check revation project exist's on other sales opportunity
        for(Opportunity opp : newList){
            if(opp.Project__c != null && recordTypeIdSet.contains(opp.RecordTypeId)){
                if(!projectOppMap.isEmpty()){
                    if(projectOppMap.containsKey(opp.Project__c))
                    {
                        opp.Project__c.addError('Selected "Renovation Project" is already associated with another Sales Opportunity');
                    }
                }
            }
        }
    }
    // --------    
    public static void projectEvaluationStatusBeforeUpdate(){
        
        Id InvestorProspectRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Investor Prospect').getRecordTypeId();
        Id investorRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Investor').getRecordTypeId();
        Id investorOwnerRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Investor Owner').getRecordTypeId();
        Id RenovationRecordType = Schema.SObjectType.Project__c.getRecordTypeInfosByName().get('Renovation').getRecordTypeId();
        Set<Id> idSet = new Set<Id>();
        Map<Id, Project__c> proMap = new Map<Id, Project__c>();
        for(Opportunity opp2 : newList){
            
            System.debug('DC: opp2.Project_Evaluation_1__c: ' + opp2.Project_Evaluation_1__c);
            System.debug('DC: oldMap.get(opp2.Id).Project_Evaluation_1__c: ' + oldMap.get(opp2.Id).Project_Evaluation_1__c);
            
            if(opp2.Project_Evaluation_1__c != oldMap.get(opp2.Id).Project_Evaluation_1__c || opp2.Project_Evaluation_2__c != oldMap.get(opp2.Id).Project_Evaluation_2__c ||
               opp2.Project_Evaluation_3__c != oldMap.get(opp2.Id).Project_Evaluation_3__c || opp2.Project_Evaluation_1_Status__c != oldMap.get(opp2.Id).Project_Evaluation_1_Status__c ||
               opp2.Project_Evaluation_2_Status__c != oldMap.get(opp2.Id).Project_Evaluation_2_Status__c || opp2.Project_Evaluation_3_Status__c != oldMap.get(opp2.Id).Project_Evaluation_3_Status__c){
                   
                   if(opp2.Project_Evaluation_1__c != null) idSet.add(opp2.Project_Evaluation_1__c);
                   if(opp2.Project_Evaluation_2__c != null) idSet.add(opp2.Project_Evaluation_2__c);
                   if(opp2.Project_Evaluation_3__c != null) idSet.add(opp2.Project_Evaluation_3__c);
               }
            
        }
        System.debug('DC: idSet.size(): ' + idSet);
        if(idSet.size() > 0){
            
            
            Set<Id> investorRecordTypesSet = new Set<Id>{InvestorProspectRecordType, investorRecordType, investorOwnerRecordType};
                Boolean investorOppPresent = false;
            for(Opportunity opp2 : newList) {
                if(investorRecordTypesSet.contains(opp2.RecordTypeId)) {
                    investorOppPresent = true;
                    break;
                }
            }
            
            System.debug('DC: investorOppPresent: ' + investorOppPresent);
            if(!investorOppPresent) return;
            
            List<Project__c> projectList = [SELECT Id, Name, Year_Built__c, RecordTypeId, DR_Expires__c,Asking_Price__c, Project_Manager__c, Max_Budget__c, Estimated_Annual_HOA_Dues__c, HOA_Subdivision_Name__c, house__r.county__c, house__r.legal_description__c FROM Project__c WHERE Id IN: IdSet];
            for(Project__c pro : projectList){
                proMap.put(pro.Id, pro);
            }
            List<Opportunity> newOppList = [SELECT Id, Name, Cancellation_Completed_By_Contracts_Dep__c, Project_Evaluation_1__c, Project_Evaluation_2__c, Project_Evaluation_3__c, 
                                            Project_Evaluation_1_Status__c, Project_Evaluation_2_Status__c, Project_Evaluation_3_Status__c, HOA_Dues__c 
                                            FROM Opportunity WHERE Id NOT IN:newList AND (Project_Evaluation_1__c IN: idSet OR Project_Evaluation_2__c IN: idSet OR Project_Evaluation_3__c IN: idSet)];
            System.debug('DC: newOppList: ' + newOppList);
            Map<Id, Set<String>> pro1 = new Map<Id, Set<String>>();
            Map<Id, Set<String>> pro2 = new Map<Id, Set<String>>();
            Map<Id, Set<String>> pro3 = new Map<Id, Set<String>>();
            
            for(Opportunity opp3 : newOppList){
                pro1.put(opp3.Project_Evaluation_1__c, new Set<String>{opp3.Project_Evaluation_1_Status__c});
                pro2.put(opp3.Project_Evaluation_2__c, new Set<String>{opp3.Project_Evaluation_2_Status__c});
                pro3.put(opp3.Project_Evaluation_3__c, new Set<String>{opp3.Project_Evaluation_3_Status__c});
            }
            
            System.debug('DC: pro1: ' + pro1);
            System.debug('DC: pro2: ' + pro2);
            System.debug('DC: pro3: ' + pro3);
            
            for(Opportunity opp : newList) {
                
            	System.debug('DC: opp: ' + opp);
                if(opp.RecordTypeId == InvestorProspectRecordType || opp.RecordTypeId == investorRecordType || opp.RecordTypeId ==investorOwnerRecordType ){
                    //
                    if(opp.Project_Evaluation_1__c != NULL){
                        if((opp.Project_Evaluation_1__c == opp.Project_Evaluation_2__c) || (opp.Project_Evaluation_1__c == opp.Project_Evaluation_3__c)){
                            opp.addError('You cannot use same Renovation Project again on this Opportunity');
                        }  
                    }
                    if(opp.Project_Evaluation_2__c != NULL){
                        if((opp.Project_Evaluation_2__c == opp.Project_Evaluation_1__c) || (opp.Project_Evaluation_2__c == opp.Project_Evaluation_3__c)){
                            opp.addError('You cannot use same Renovation Project again on this Opportunity');
                        }
                    }
                    if(opp.Project_Evaluation_3__c != NULL){
                        if((opp.Project_Evaluation_3__c == opp.Project_Evaluation_1__c) || (opp.Project_Evaluation_3__c == opp.Project_Evaluation_2__c)){
                            opp.addError('You cannot use same Renovation Project again on this Opportunity');
                        } 
                    }
                    
                    
                    //---
                    if(opp.Project_Evaluation_1__c != NULL && opp.Project_Evaluation_1_Status__c == NULL && proMap.get(opp.Project_Evaluation_1__c).RecordTypeId == RenovationRecordType){
                        opp.Project_Evaluation_1_Status__c = 'Under Evaluation';
                    }
                    if(opp.Project_Evaluation_2__c != NULL && opp.Project_Evaluation_2_Status__c == NULL && proMap.get(opp.Project_Evaluation_2__c).RecordTypeId == RenovationRecordType){
                        opp.Project_Evaluation_2_Status__c = 'Under Evaluation';
                    }
                    if(opp.Project_Evaluation_3__c != NULL && opp.Project_Evaluation_3_Status__c == NULL && proMap.get(opp.Project_Evaluation_3__c).RecordTypeId == RenovationRecordType){
                        opp.Project_Evaluation_3_Status__c = 'Under Evaluation';
                    }
                    // custom error code which does not allow 2 projects to be selected at the same time
                    if(opp.Project_Evaluation_1_Status__c == 'SELECTED'){
                        if(opp.Project_Evaluation_2_Status__c == 'SELECTED' || opp.Project_Evaluation_3_Status__c == 'SELECTED'){
                            opp.addError('You cannot have more that one Renovation Project as "SELECTED". Please make sure to have only one Renovation Project as "SELECTED"');
                        }
                    }else if(opp.Project_Evaluation_2_Status__c == 'SELECTED'){
                        if(opp.Project_Evaluation_1_Status__c == 'SELECTED' || opp.Project_Evaluation_3_Status__c == 'SELECTED'){
                            opp.addError('You cannot have more that one Renovation Project as "SELECTED". Please make sure to have only one Renovation Project as "SELECTED"');
                        }
                    }else if(opp.Project_Evaluation_3_Status__c == 'SELECTED'){
                        if(opp.Project_Evaluation_2_Status__c == 'SELECTED' || opp.Project_Evaluation_1_Status__c == 'SELECTED'){
                            opp.addError('You cannot have more that one Renovation Project as "SELECTED". Please make sure to have only one Renovation Project as "SELECTED"');
                        }
                    }
                    // 10.17.2024 - Demand Chain - removed check to see if oldValue was NOT selected.  
                    if(opp.Project_Evaluation_1__c != null 
                           && String.isNotBlank(opp.Project_Evaluation_1_Status__c) 
                           && opp.Project_Evaluation_1_Status__c == 'Selected' 
                           //&& oldMap.get(opp.id).Project_Evaluation_1_Status__c != 'Selected'
                      ){
                        System.debug('DC: Project Map 1 '+pro1.get(opp.Project_Evaluation_1__c));
                        System.debug('DC: Project Map 2 '+pro2.get(opp.Project_Evaluation_1__c));
                        System.debug('DC: Project Map 3 '+pro3.get(opp.Project_Evaluation_1__c));
                        System.debug('DC: Should be true '+pro1.containsKey(opp.Project_Evaluation_1__c));
                        
                        if(pro1.containsKey(opp.Project_Evaluation_1__c)){
                            System.debug('DC: pro1.containsKey(opp.Project_Evaluation_1__c): '+ pro1.containsKey(opp.Project_Evaluation_1__c));
                            if(pro1.get(opp.Project_Evaluation_1__c).contains('Selected')){
                                System.debug('Error');
                                opp.addError('You cannot mark this Renovation Project as "SELECTED" because it is already "SELECTED" in another Opportunity');
                            }
                        }
                        if(pro2.containsKey(opp.Project_Evaluation_1__c)){
                            if(pro2.get(opp.Project_Evaluation_1__c).contains('Selected')){
                                opp.addError('You cannot mark this Renovation Project as "SELECTED" because it is already "SELECTED" in another Opportunity');
                            }
                        }
                        if(pro3.containsKey(opp.Project_Evaluation_1__c)){
                            if(pro3.get(opp.Project_Evaluation_1__c).contains('Selected')){
                                opp.addError('You cannot mark this Renovation Project as "SELECTED" because it is already "SELECTED" in another Opportunity');
                            }
                        }
                        opp.Project_Evaluation_2_Status__c = opp.Project_Evaluation_2__c != null ? 'Rejected' : null;
                        opp.Project_Evaluation_3_Status__c = opp.Project_Evaluation_3__c != null ? 'Rejected' : null;
                        opp.DR_Expires2__c =  proMap.get(opp.Project_Evaluation_1__c).DR_Expires__c;
                        opp.RH_Manager__c = proMap.get(opp.Project_Evaluation_1__c).Project_Manager__c;
                        opp.RH_Budget__c =  proMap.get(opp.Project_Evaluation_1__c).Max_Budget__c;
                        opp.Asking_Price_New__c =  proMap.get(opp.Project_Evaluation_1__c).Asking_Price__c;
                        opp.Year_Built__c =  proMap.get(opp.Project_Evaluation_1__c).Year_Built__c;
                        
                        
            			System.debug('DC: proMap.get(opp.Project_Evaluation_1__c): ' + proMap.get(opp.Project_Evaluation_1__c));
                        opp.project__c =  proMap.get(opp.Project_Evaluation_1__c).Id;
                        opp.Name = proMap.get(opp.Project_Evaluation_1__c).Name;
                        opp.HOA_Dues__c = proMap.get(opp.Project_Evaluation_1__c).Estimated_Annual_HOA_Dues__c; //change 25 Jan
                        opp.HOA_Subdivision_Name__c = proMap.get(opp.Project_Evaluation_1__c).HOA_Subdivision_Name__c; // change 27 Jan
                        opp.County__c = proMap.get(opp.Project_Evaluation_1__c).house__r.county__c; // change 27 Jan
                        opp.Legal_Description__c = proMap.get(opp.Project_Evaluation_1__c).house__r.legal_description__c; // change 27 Jan

                    // 10.17.2024 - Demand Chain - removed check to see if oldValue was NOT selected.  
                    } else if(opp.Project_Evaluation_2__c != null 
                                 && String.isNotBlank(opp.Project_Evaluation_2_Status__c) 
                                 && opp.Project_Evaluation_2_Status__c == 'Selected' 
                                 //&& oldMap.get(opp.id).Project_Evaluation_2_Status__c != 'Selected'
                             ){
                        System.debug('Project Name '+proMap.get(opp.Project_Evaluation_2__c).Name);
                        if(pro1.containsKey(opp.Project_Evaluation_2__c)){
                            if(pro1.get(opp.Project_Evaluation_2__c).contains('Selected')){
                                System.debug('Error');
                                opp.addError('You cannot mark this Renovation Project as "SELECTED" because it is already "SELECTED" in another Opportunity');
                            }
                        }
                        if(pro2.containsKey(opp.Project_Evaluation_2__c)){
                            if(pro2.get(opp.Project_Evaluation_2__c).contains('Selected')){
                                opp.addError('You cannot mark this Renovation Project as "SELECTED" because it is already "SELECTED" in another Opportunity');
                            }
                        }
                        if(pro3.containsKey(opp.Project_Evaluation_2__c)){
                            if(pro3.get(opp.Project_Evaluation_2__c).contains('Selected')){
                                opp.addError('You cannot mark this Renovation Project as "SELECTED" because it is already "SELECTED" in another Opportunity');
                            }
                        }
                        opp.Project_Evaluation_1_Status__c = opp.Project_Evaluation_1__c != null ? 'Rejected' : null;
                        opp.Project_Evaluation_3_Status__c = opp.Project_Evaluation_3__c != null ? 'Rejected' : null;
                        opp.DR_Expires2__c =  proMap.get(opp.Project_Evaluation_2__c).DR_Expires__c;
                        opp.RH_Manager__c = proMap.get(opp.Project_Evaluation_2__c).Project_Manager__c;
                        opp.RH_Budget__c =  proMap.get(opp.Project_Evaluation_2__c).Max_Budget__c;
                        opp.Asking_Price_New__c =  proMap.get(opp.Project_Evaluation_2__c).Asking_Price__c;
                        opp.Year_Built__c =  proMap.get(opp.Project_Evaluation_2__c).Year_Built__c;
                        opp.project__c =  proMap.get(opp.Project_Evaluation_2__c).Id;
                        opp.Name = proMap.get(opp.Project_Evaluation_2__c).Name;
                        opp.HOA_Dues__c = proMap.get(opp.Project_Evaluation_2__c).Estimated_Annual_HOA_Dues__c; //change 25 Jan
                        opp.HOA_Subdivision_Name__c = proMap.get(opp.Project_Evaluation_2__c).HOA_Subdivision_Name__c; // change 27 Jan
                        opp.County__c = proMap.get(opp.Project_Evaluation_2__c).house__r.county__c; // change 27 Jan
                        opp.Legal_Description__c = proMap.get(opp.Project_Evaluation_2__c).house__r.legal_description__c; // change 27 Jan
                    
                    // 10.17.2024 - Demand Chain - removed check to see if oldValue was NOT selected.  
                    } else if(opp.Project_Evaluation_3__c != null 
                                && String.isNotBlank(opp.Project_Evaluation_3_Status__c) 
                                && opp.Project_Evaluation_3_Status__c == 'Selected' 
                                //&& oldMap.get(opp.id).Project_Evaluation_3_Status__c != 'Selected'
                             ){
                        System.debug('Project Name '+proMap.get(opp.Project_Evaluation_3__c).Name);
                        if(pro1.containsKey(opp.Project_Evaluation_3__c)){
                            if(pro1.get(opp.Project_Evaluation_3__c).contains('Selected')){
                                System.debug('Error');
                                opp.addError('You cannot mark this Renovation Project as "SELECTED" because it is already "SELECTED" in another Opportunity');
                            }
                        }
                        if(pro2.containsKey(opp.Project_Evaluation_3__c)){
                            if(pro2.get(opp.Project_Evaluation_3__c).contains('Selected')){
                                opp.addError('You cannot mark this Renovation Project as "SELECTED" because it is already "SELECTED" in another Opportunity');
                            }
                        }
                        if(pro3.containsKey(opp.Project_Evaluation_3__c)){
                            if(pro3.get(opp.Project_Evaluation_3__c).contains('Selected')){
                                opp.addError('You cannot mark this Renovation Project as "SELECTED" because it is already "SELECTED" in another Opportunity');
                            }
                        }
                        opp.Project_Evaluation_2_Status__c = opp.Project_Evaluation_2__c != null ? 'Rejected' : null;
                        opp.Project_Evaluation_1_Status__c = opp.Project_Evaluation_1__c != null ? 'Rejected' : null;
                        opp.DR_Expires2__c =  proMap.get(opp.Project_Evaluation_3__c).DR_Expires__c;
                        opp.RH_Manager__c = proMap.get(opp.Project_Evaluation_3__c).Project_Manager__c;
                        opp.RH_Budget__c =  proMap.get(opp.Project_Evaluation_3__c).Max_Budget__c;
                        opp.Asking_Price_New__c =  proMap.get(opp.Project_Evaluation_3__c).Asking_Price__c;
                        opp.Year_Built__c =  proMap.get(opp.Project_Evaluation_3__c).Year_Built__c;
                        opp.project__c =  proMap.get(opp.Project_Evaluation_3__c).Id;
                        opp.Name = proMap.get(opp.Project_Evaluation_3__c).Name;
                        opp.HOA_Dues__c = proMap.get(opp.Project_Evaluation_3__c).Estimated_Annual_HOA_Dues__c; //change 25 Jan
                        opp.HOA_Subdivision_Name__c = proMap.get(opp.Project_Evaluation_3__c).HOA_Subdivision_Name__c; // change 27 Jan
                        opp.County__c = proMap.get(opp.Project_Evaluation_3__c).house__r.county__c; // change 27 Jan
                        opp.Legal_Description__c = proMap.get(opp.Project_Evaluation_3__c).house__r.legal_description__c; // change 27 Jan
                        
                    }
                    // condition to remove the project status if project is removed
                    if(opp.Project_Evaluation_1__c == NULL && opp.Project_Evaluation_1_Status__c != NULL){
                        opp.Project_Evaluation_1_Status__c = NULL;
                    }
                    if(opp.Project_Evaluation_2__c == NULL && opp.Project_Evaluation_2_Status__c != NULL){
                        opp.Project_Evaluation_2_Status__c = NULL; 
                    }
                    if(opp.Project_Evaluation_3__c == NULL && opp.Project_Evaluation_3_Status__c != NULL){
                        opp.Project_Evaluation_3_Status__c = NULL;
                    }
                    
                    // On Change StageName from Something to Cancelled we are setting Project_Evaluation_Status to rejected 
                    /*  if(opp.StageName == 'Cancelled' && oldMap.get(opp.id).StageName != 'Cancelled'){
if(opp.Project_Evaluation_1_Status__c == 'Selected'){
opp.Project_Evaluation_1_Status__c = 'Rejected';
}else if(opp.Project_Evaluation_2_Status__c == 'Selected'){
opp.Project_Evaluation_2_Status__c = 'Rejected';
}else if(opp.Project_Evaluation_3_Status__c == 'Selected'){
opp.Project_Evaluation_3_Status__c = 'Rejected';
}
} */
                    if(opp.Cancellation_Completed_By_Contracts_Dep__c == True && oldMap.get(opp.id).Cancellation_Completed_By_Contracts_Dep__c != True && opp.StageName == 'Cancelled'){
                        if(opp.Project_Evaluation_1_Status__c == 'Selected'){
                            opp.Project_Evaluation_1_Status__c = 'Rejected';
                        }else if(opp.Project_Evaluation_2_Status__c == 'Selected'){
                            opp.Project_Evaluation_2_Status__c = 'Rejected';
                        }else if(opp.Project_Evaluation_3_Status__c == 'Selected'){
                            opp.Project_Evaluation_3_Status__c = 'Rejected';
                        }
                    }               
                    
                    // condition to set the fields to null if no project is selected
                    if(opp.Project_Evaluation_1__c == NULL || (opp.Project_Evaluation_1_Status__c == 'Under Evaluation' || opp.Project_Evaluation_1_Status__c == 'Rejected')){
                        if(opp.Project_Evaluation_2__c == NULL || (opp.Project_Evaluation_2_Status__c == 'Under Evaluation' || opp.Project_Evaluation_2_Status__c == 'Rejected')){
                            if(opp.Project_Evaluation_3__c == NULL || (opp.Project_Evaluation_3_Status__c == 'Under Evaluation' || opp.Project_Evaluation_3_Status__c == 'Rejected')){
                                if(opp.StageName != 'Cancelled'){
                                    opp.DR_Expires2__c =  NULL;
                                    opp.RH_Manager__c = NULL;
                                    opp.RH_Budget__c =  NULL;
                                    opp.Asking_Price_New__c =  NULL;
                                    opp.Year_Built__c = NUll;
                                    opp.HOA_Dues__c = NULL;
                                    opp.HOA_Subdivision_Name__c = NULL;
                                    opp.County__c = NULL;
                                    opp.Legal_Description__c = NULL;
                                }
                                opp.project__c =  NULL;
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    /*
public static void updateProjectEvaluationStatus(){

Id InvestorProspectRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Investor Prospect').getRecordTypeId();
Id investorRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Investor').getRecordTypeId();
Id investorOwnerRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Investor Owner').getRecordTypeId();
Id RenovationRecordType = Schema.SObjectType.Project__c.getRecordTypeInfosByName().get('Renovation').getRecordTypeId();

Set<Id> idSet = new Set<Id>();
Map<Id, Project__c> proMap = new Map<Id, Project__c>();
for(Opportunity opp2 : newList){
idSet.add(opp2.Project_Evaluation_1__c);
idSet.add(opp2.Project_Evaluation_2__c);
idSet.add(opp2.Project_Evaluation_3__c);
}
List<Project__c> projectList = [SELECT Id, Name, RecordTypeId, DR_Expires__c, Project_Manager__c, Max_Budget__c FROM Project__c WHERE Id IN: IdSet];
for(Project__c pro : projectList){
proMap.put(pro.Id, pro);
}

for(Opportunity opp : newList){
if(opp.RecordTypeId == InvestorProspectRecordType || opp.RecordTypeId == investorRecordType || opp.RecordTypeId == investorOwnerRecordType){
// custom error code
if(opp.Project_Evaluation_1_Status__c == 'SELECTED'){
if(opp.Project_Evaluation_2_Status__c == 'SELECTED' || opp.Project_Evaluation_3_Status__c == 'SELECTED'){
opp.addError('Cannot have two projects SELECTED at the same time');
}
}else if(opp.Project_Evaluation_2_Status__c == 'SELECTED'){
if(opp.Project_Evaluation_1_Status__c == 'SELECTED' || opp.Project_Evaluation_3_Status__c == 'SELECTED'){
opp.addError('Cannot have two projects SELECTED at the same time');
}
}else if(opp.Project_Evaluation_3_Status__c == 'SELECTED'){
if(opp.Project_Evaluation_2_Status__c == 'SELECTED' || opp.Project_Evaluation_1_Status__c == 'SELECTED'){
opp.addError('Cannot have two projects SELECTED at the same time');
}
}

// ------
if(opp.Project_Evaluation_1__c != null && String.isNotBlank(opp.Project_Evaluation_1_Status__c) && opp.Project_Evaluation_1_Status__c == 'Selected' && oldMap.get(opp.id).Project_Evaluation_1_Status__c != 'Selected'){
System.debug('Project Name '+proMap.get(opp.Project_Evaluation_1__c).Name); 
opp.Project_Evaluation_2_Status__c = opp.Project_Evaluation_2__c != null ? 'Rejected' : null;
opp.Project_Evaluation_3_Status__c = opp.Project_Evaluation_3__c != null ? 'Rejected' : null;
opp.DR_Expires2__c =  proMap.get(opp.Project_Evaluation_1__c).DR_Expires__c;
opp.RH_Manager__c = proMap.get(opp.Project_Evaluation_1__c).Project_Manager__c;
opp.RH_Budget__c =  proMap.get(opp.Project_Evaluation_1__c).Max_Budget__c;

}else if(opp.Project_Evaluation_2__c != null && String.isNotBlank(opp.Project_Evaluation_2_Status__c) && opp.Project_Evaluation_2_Status__c == 'Selected' && oldMap.get(opp.id).Project_Evaluation_2_Status__c != 'Selected'){
System.debug('Project Name '+proMap.get(opp.Project_Evaluation_2__c).Name); 
opp.Project_Evaluation_1_Status__c = opp.Project_Evaluation_1__c != null ? 'Rejected' : null;
opp.Project_Evaluation_3_Status__c = opp.Project_Evaluation_3__c != null ? 'Rejected' : null;
opp.DR_Expires2__c =  proMap.get(opp.Project_Evaluation_2__c).DR_Expires__c;
opp.RH_Manager__c = proMap.get(opp.Project_Evaluation_2__c).Project_Manager__c;
opp.RH_Budget__c =  proMap.get(opp.Project_Evaluation_2__c).Max_Budget__c;

}else if(opp.Project_Evaluation_3__c != null && String.isNotBlank(opp.Project_Evaluation_3_Status__c) && opp.Project_Evaluation_3_Status__c == 'Selected' && oldMap.get(opp.id).Project_Evaluation_3_Status__c != 'Selected'){
System.debug('Project Name '+proMap.get(opp.Project_Evaluation_3__c).Name); 
opp.Project_Evaluation_2_Status__c = opp.Project_Evaluation_2__c != null ? 'Rejected' : null;
opp.Project_Evaluation_1_Status__c = opp.Project_Evaluation_1__c != null ? 'Rejected' : null;
opp.DR_Expires2__c =  proMap.get(opp.Project_Evaluation_3__c).DR_Expires__c;
opp.RH_Manager__c = proMap.get(opp.Project_Evaluation_3__c).Project_Manager__c;
opp.RH_Budget__c =  proMap.get(opp.Project_Evaluation_3__c).Max_Budget__c;

}else if(opp.Project_Evaluation_1__c == NULL && opp.Project_Evaluation_1_Status__c != NULL){
opp.Project_Evaluation_1_Status__c = NULL;

}else if(opp.Project_Evaluation_2__c == NULL && opp.Project_Evaluation_2_Status__c != NULL){
opp.Project_Evaluation_2_Status__c = NULL;

}else if(opp.Project_Evaluation_3__c == NULL && opp.Project_Evaluation_3_Status__c != NULL){
opp.Project_Evaluation_3_Status__c = NULL;

}
// condition to set the fields to null if no project is selected
if(opp.Project_Evaluation_1__c == NULL || (opp.Project_Evaluation_1_Status__c == 'Under Evaluation' || opp.Project_Evaluation_1_Status__c == 'Rejected')){
if(opp.Project_Evaluation_2__c == NULL || (opp.Project_Evaluation_2_Status__c == 'Under Evaluation' || opp.Project_Evaluation_2_Status__c == 'Rejected')){
if(opp.Project_Evaluation_3__c == NULL || (opp.Project_Evaluation_3_Status__c == 'Under Evaluation' || opp.Project_Evaluation_3_Status__c == 'Rejected')){
opp.DR_Expires2__c =  NULL;
opp.RH_Manager__c = NULL;
opp.RH_Budget__c =  NULL;
}
}
}
} 
}
}
*/
    // -------    
    // After Update House Lookup on Opportunity
    public static void updateHouse(){
        
        Id InvestorProspectRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Investor Prospect').getRecordTypeId();
        Id investorRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Investor').getRecordTypeId();
        Id BuyRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Buy').getRecordTypeId();
        Id RenovationRecordType = Schema.SObjectType.Project__c.getRecordTypeInfosByName().get('Renovation').getRecordTypeId();
        
        Set<id> investorRecordTypeIds=new set<id>{investorRecordType,InvestorProspectRecordType};
            
            Set<id> houseIdSet = new Set<id>();
        for(Opportunity opp : newList){
            if(opp.RecordTypeId == BuyRecordType){
                if((opp.Sale_Comp_1__c != null && oldMap.get(opp.id).Sale_Comp_1__c != opp.Sale_Comp_1__c)){
                    houseIdSet.add(opp.Sale_Comp_1__c);
                }
                if((opp.Sale_Comp_2__c != null && oldMap.get(opp.id).Sale_Comp_2__c != opp.Sale_Comp_2__c)){
                    houseIdSet.add(opp.Sale_Comp_2__c);
                }
                if((opp.Sale_Comp_3__c != null && oldMap.get(opp.id).Sale_Comp_3__c != opp.Sale_Comp_3__c)){
                    houseIdSet.add(opp.Sale_Comp_3__c);
                }
                if((opp.Rent_Comp_1__c != null && oldMap.get(opp.id).Rent_Comp_1__c != opp.Rent_Comp_1__c)){
                    houseIdSet.add(opp.Rent_Comp_1__c);
                }
                if((opp.Rent_Comp_2__c != null && oldMap.get(opp.id).Rent_Comp_2__c != opp.Rent_Comp_2__c)){
                    houseIdSet.add(opp.Rent_Comp_2__c);
                }
                if((opp.Rent_Comp_3__c != null && oldMap.get(opp.id).Rent_Comp_3__c != opp.Rent_Comp_3__c)){
                    houseIdSet.add(opp.Rent_Comp_3__c);
                }
            }
        }
        /*  
System.debug('houseIdSet--'+houseIdSet);
List<House__c> houseList = new List<House__c>();
if(houseIdSet.size() > 0){
for(House__c hs : [SELECT Id,Source__c,CreatedDate,LastModifiedDate,Appraised_Amount__c,Appraised_Date__c,Sale_Amount__c,Sales_Date__c,Rent_Year_1__c,Lease_Closing_Date__c,
(SELECT Id,Amount,CreatedDate,LastModifiedDate,CloseDate,Appraised__c,Appraisal_Appt_Set__c FROM Opportunities2__r WHERE RecordTypeId IN : investorRecordTypeIds ORDER BY CreatedDate  DESC LIMIT 1),
(SELECT Id,Amount,CreatedDate,LastModifiedDate,Appraised__c,Appraisal_Appt_Set__c FROM Opportunities3__r WHERE RecordTypeId IN : investorRecordTypeIds ORDER BY CreatedDate  DESC LIMIT 1),
(SELECT Id,Amount,CreatedDate,LastModifiedDate,CloseDate,Appraised__c,Appraisal_Appt_Set__c FROM Opportunities4__r WHERE RecordTypeId IN : investorRecordTypeIds ORDER BY CreatedDate  DESC LIMIT 1),
(SELECT Id,LastModifiedDate,CreatedDate,Rent_Year_1__c,Lease_Closing__c FROM Projects__r WHERE RecordTypeId IN : investorRecordTypeIds ORDER BY CreatedDate  DESC LIMIT 1)
FROM House__c WHERE ID IN : houseIdSet]){

House__c updatedHouse = new House__c();
updatedHouse.id = hs.id;
if(hs.CreatedDate != hs.LastModifiedDate){
// updatedHouse.Source__c = 'Internal';
}                                   
//  system.assert(false, updatedHouse.Source__c);

for(Project__c prj : hs.Projects__r){
if(prj.Rent_Year_1__c != null){
updatedHouse.Rent_Year_1__c = prj.Rent_Year_1__c;
}
if(prj.Lease_Closing__c != null){
updatedHouse.Lease_Closing_Date__c = prj.Lease_Closing__c;
} 
}

for(Opportunity opp : hs.Opportunities2__r){
System.debug('Opp'+opp.id);
if(opp.Appraisal_Appt_Set__c != null){
updatedHouse.Appraised_Date__c = opp.Appraisal_Appt_Set__c;
}
if(opp.Amount != null){
updatedHouse.Sale_Amount__c = opp.Amount;
}
if(opp.CloseDate != null){
updatedHouse.Sales_Date__c = opp.CloseDate;
}
if(opp.Appraised__c != null){
updatedHouse.Appraised_Amount__c = opp.Appraised__c;
}
}

for(Opportunity opp : hs.Opportunities3__r){
System.debug('Opp'+opp.id);
if(opp.Appraisal_Appt_Set__c != null){
updatedHouse.Appraised_Date__c = opp.Appraisal_Appt_Set__c;
}
if(opp.Amount != null){
updatedHouse.Sale_Amount__c = opp.Amount;
}
if(opp.CloseDate != null){
updatedHouse.Sales_Date__c = opp.CloseDate;
}
if(opp.Appraised__c != null){
updatedHouse.Appraised_Amount__c = opp.Appraised__c;
}
}

for(Opportunity opp : hs.Opportunities4__r){
System.debug('Opp'+opp.id);
if(opp.Appraisal_Appt_Set__c != null){
updatedHouse.Appraised_Date__c = opp.Appraisal_Appt_Set__c;
}
if(opp.Amount != null){
updatedHouse.Sale_Amount__c = opp.Amount;
}
if(opp.CloseDate != null){
updatedHouse.Sales_Date__c = opp.CloseDate;
}
if(opp.Appraised__c != null){
updatedHouse.Appraised_Amount__c = opp.Appraised__c;
}
}

System.debug('updatedHouse--'+updatedHouse);
houseList.add(updatedHouse);
}
}

if(!houseList.isEmpty()){
System.debug('houseList--'+houseList);
Update houseList;
}*/
    }
    
    
    public static void requiredFieldValidation(){
        
        Id buyRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Buy').getRecordTypeId();
        for(Opportunity opp : newList){
            if(opp.RecordTypeId == buyRecordType){ 
                
                if(String.isBlank(opp.AccountId)){
                    opp.AccountId.addError('These required fields must be completed: Account Name');
                }
                if(String.isBlank(opp.LeadSource)){
                    opp.LeadSource.addError('These required fields must be completed: Lead Source');
                }
                if(opp.Listing_Date__c == null){
                    opp.Listing_Date__c.addError('These required fields must be completed: Listing Date');
                }
                
                if(opp.Follow_Up_Sold_Date__c == null){
                    //     opp.Follow_Up_Sold_Date__c.addError('These required fields must be completed: Follow Up/Sold Date');
                }
                if(opp.House__c == null){
                    //  opp.House__c.addError('These required fields must be completed: House'); 
                }
                
                if(opp.StageName == 'Pre-Assessment'){
                    if(String.isBlank(opp.AccountId)){
                        opp.AccountId.addError('These required fields must be completed: Account Name');
                    }
                    if(String.isBlank(opp.LeadSource)){
                        opp.LeadSource.addError('These required fields must be completed: Lead Source');
                    }
                    if(opp.Listing_Date__c == null){
                        opp.Listing_Date__c.addError('These required fields must be completed: Listing Date');
                    }
                    if(opp.Follow_Up_Sold_Date__c == null){
                        //       opp.Follow_Up_Sold_Date__c.addError('These required fields must be completed: Follow Up/Sold Date');
                    }
                    if(opp.House__c == null){
                        // opp.House__c.addError('These required fields must be completed: House'); 
                    }
                }else if(opp.StageName == 'Assessment Requested'){
                    if(opp.Assessment__c == null){
                        opp.Assessment__c.addError('These required fields must be completed: Assessment');
                    }
                }else if(opp.StageName == 'Assessment Completed'){
                    if(String.isBlank(opp.Assessment_Status__c)){
                        opp.Assessment_Status__c.addError('These required fields must be completed: Assessment Status');
                    }  
                }else if(opp.StageName == 'Offer Sheet Submit'){
                    if(opp.Initial_List_Price__c == null){
                        opp.Initial_List_Price__c.addError('These required fields must be completed: Initial List Price');
                    }
                    if(opp.Initial_Offer__c == null){
                        opp.Initial_Offer__c.addError('These required fields must be completed: Initial Offer');
                    }
                    if(opp.Current_List_Price__c == null){
                        opp.Current_List_Price__c.addError('These required fields must be completed: Current List Price');
                    }
                    if(opp.Current_Offer__c == null){
                        opp.Current_Offer__c.addError('These required fields must be completed: Current Offer');
                    }
                    if(opp.Assessment__c == null){
                        opp.Assessment__c.addError('These required fields must be completed: Assessment');
                    }
                    if(opp.Flood_Insurance_Required__c == null){
                        opp.Flood_Insurance_Required__c.addError('These required fields must be completed: Flood Insurance Required');
                    }
                    if(opp.HOA_Dues__c == null){
                        opp.HOA_Dues__c.addError('These required fields must be completed: HOA Dues');
                    }
                    if(opp.Total_Taxes__c == null){
                        opp.Total_Taxes__c.addError('These required fields must be completed: Total Taxes');
                    }
                    if(opp.Estimated_Rent__c == null){
                        opp.Estimated_Rent__c.addError('These required fields must be completed: Estimated Rent');
                    }
                    if(opp.Asking_Price_OS__c == null){
                        opp.Asking_Price_OS__c.addError('These required fields must be completed: Asking Price OS');
                    }
                    if(opp.Rehab_Budget_OS__c == null){
                        opp.Rehab_Budget_OS__c.addError('These required fields must be completed: Rehab Budget OS');
                    }
                    if(opp.Margin__c == null){
                        opp.Margin__c.addError('These required fields must be completed: Margin');
                    }
                    if(opp.Comps_Support_Per_Sq_Ft__c == null){
                        opp.Comps_Support_Per_Sq_Ft__c.addError('These required fields must be completed: Comps Support Per Sq Ft');
                    }
                    if(opp.Low_End_Range__c == null){
                        opp.Low_End_Range__c.addError('These required fields must be completed: Low End Range');
                    }
                    if(opp.Occupancy_At_Closing__c == null){
                        opp.Occupancy_At_Closing__c.addError('These required fields must be completed: Occupancy At Closing');
                    }
                    if(opp.Closing_Concessions_Information__c == null){
                        opp.Closing_Concessions_Information__c.addError('These required fields must be completed: Closing Concessions');
                    } 
                    
                }else if(opp.StageName == 'Offer Sheet Approved')
                    
                {
                    if(opp.Initial_List_Price__c == null){
                        opp.Initial_List_Price__c.addError('These required fields must be completed: Initial List Price');
                    }
                    if(opp.Initial_Offer__c == null){
                        opp.Initial_Offer__c.addError('These required fields must be completed: Initial Offer');
                    }
                    if(opp.Current_List_Price__c == null){
                        opp.Current_List_Price__c.addError('These required fields must be completed: Current List Price');
                    }
                    if(opp.Current_Offer__c == null){
                        opp.Current_Offer__c.addError('These required fields must be completed: Current Offer');
                    }
                    if(opp.Assessment__c == null){
                        opp.Assessment__c.addError('These required fields must be completed: Assessment');
                    }
                    if(opp.Flood_Insurance_Required__c == null){
                        opp.Flood_Insurance_Required__c.addError('These required fields must be completed: Flood Insurance Required');
                    }
                    if(opp.HOA_Dues__c == null){
                        opp.HOA_Dues__c.addError('These required fields must be completed: HOA Dues');
                    }
                    if(opp.Total_Taxes__c == null){
                        opp.Total_Taxes__c.addError('These required fields must be completed: Total Taxes');
                    }
                    if(opp.Estimated_Rent__c == null){
                        opp.Estimated_Rent__c.addError('These required fields must be completed: Estimated Rent');
                    }
                    if(opp.Asking_Price_OS__c == null){
                        opp.Asking_Price_OS__c.addError('These required fields must be completed: Asking Price OS');
                    }
                    if(opp.Rehab_Budget_OS__c == null){
                        opp.Rehab_Budget_OS__c.addError('These required fields must be completed: Rehab Budget OS');
                    }
                    if(opp.Margin__c == null){
                        opp.Margin__c.addError('These required fields must be completed: Margin');
                    }
                    if(opp.Comps_Support_Per_Sq_Ft__c == null){
                        opp.Comps_Support_Per_Sq_Ft__c.addError('These required fields must be completed: Comps Support Per Sq Ft');
                    }
                    if(opp.Low_End_Range__c == null){
                        opp.Low_End_Range__c.addError('These required fields must be completed: Low End Range');
                    }
                    if(opp.Occupancy_At_Closing__c == null){
                        opp.Occupancy_At_Closing__c.addError('These required fields must be completed: Occupancy At Closing');
                    }
                    if(opp.Closing_Concessions_Information__c == null){
                        opp.Closing_Concessions_Information__c.addError('These required fields must be completed: Closing Concessions');
                    }
                    
                }else if(opp.StageName == 'Verbal'){
                    
                    if(opp.Initial_List_Price__c == null){
                        opp.Initial_List_Price__c.addError('These required fields must be completed: Initial List Price');
                    }
                    if(opp.Initial_Offer__c == null){
                        opp.Initial_Offer__c.addError('These required fields must be completed: Initial Offer');
                    }
                    if(opp.Current_List_Price__c == null){
                        opp.Current_List_Price__c.addError('These required fields must be completed: Current List Price');
                    }
                    if(opp.Current_Offer__c == null){
                        opp.Current_Offer__c.addError('These required fields must be completed: Current Offer');
                    }
                    if(opp.Assessment__c == null){
                        opp.Assessment__c.addError('These required fields must be completed: Assessment');
                    }
                    if(opp.Flood_Insurance_Required__c == null){
                        opp.Flood_Insurance_Required__c.addError('These required fields must be completed: Flood Insurance Required');
                    }
                    if(opp.HOA_Dues__c == null){
                        opp.HOA_Dues__c.addError('These required fields must be completed: HOA Dues');
                    }
                    if(opp.Total_Taxes__c == null){
                        opp.Total_Taxes__c.addError('These required fields must be completed: Total Taxes');
                    }
                    if(opp.Estimated_Rent__c == null){
                        opp.Estimated_Rent__c.addError('These required fields must be completed: Estimated Rent');
                    }
                    if(opp.Asking_Price_OS__c == null){
                        opp.Asking_Price_OS__c.addError('These required fields must be completed: Asking Price OS');
                    }
                    if(opp.Rehab_Budget_OS__c == null){
                        opp.Rehab_Budget_OS__c.addError('These required fields must be completed: Rehab Budget OS');
                    }
                    if(opp.Margin__c == null){
                        opp.Margin__c.addError('These required fields must be completed: Margin');
                    }
                    if(opp.Comps_Support_Per_Sq_Ft__c == null){
                        opp.Comps_Support_Per_Sq_Ft__c.addError('These required fields must be completed: Comps Support Per Sq Ft');
                    }
                    if(opp.Low_End_Range__c == null){
                        opp.Low_End_Range__c.addError('These required fields must be completed: Low End Range');
                    }
                    if(opp.Occupancy_At_Closing__c == null){
                        opp.Occupancy_At_Closing__c.addError('These required fields must be completed: Occupancy At Closing');
                    }
                    if(opp.Closing_Concessions_Information__c == null){
                        opp.Closing_Concessions_Information__c.addError('These required fields must be completed: Closing Concessions');
                    }
                }
            }
        }
    }
    
    public static void afterInsertSendEmail(){ 
        EmailTemplate et = [SELECT Id,Subject,HtmlValue,Body FROM EmailTemplate WHERE Name = 'Lender 1 Intro Email'];
        EmailTemplate et2 = [SELECT Id,Subject,HtmlValue,Body FROM EmailTemplate WHERE Name = 'Lender 2 Intro Email'];
        EmailTemplate et3 = [SELECT Id,Subject,HtmlValue,Body FROM EmailTemplate WHERE Name = 'REI Nation Title Verification'];
        OrgWideEmailAddress orgEmail = [select Id, DisplayName, Address from OrgWideEmailAddress where DisplayName = 'Portfolio Advisor'];
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        List<EmailMessage> emailHistories = new List<EmailMessage>();
        
        Set<id> salesRecordTypeIdSet = new Set<id>();
        for(RecordType rt : [SELECT id FROM RecordType where sObjectType = 'Opportunity' AND Name LIKE 'Investor%']){
            salesRecordTypeIdSet.add(rt.id);
        }
        
        Set<Id> accId = new Set<Id>();
        Map<Id, List<String>> conMap = new Map<Id, List<String>>();
        Map<Id, List<String>> conMapNotPrimary = new Map<Id, List<String>>();
        for(Opportunity opp : newList){
            accId.add(opp.AccountId);
        }
        for(Contact con : [SELECT Id, AccountId, Email, Is_Primary__c FROM Contact WHERE AccountId IN: accId AND Email != NULL ORDER BY CreatedDate DESC]){
            List<String> strList = new List<String>();
            if(con.Is_Primary__c == TRUE){
                System.debug('email ' +con.Email);
                if(!conMap.containsKey(con.AccountId)){
                    strList.add(con.Email);
                    conMap.put(con.AccountId, strList);
                }else{
                    strList = conMap.get(con.AccountId);
                    strList.add(con.Email);
                    conMap.put(con.AccountId, strList);
                }    
            }else{
                if(!conMapNotPrimary.containsKey(con.AccountId)){
                    strList.add(con.Email);
                    conMapNotPrimary.put(con.AccountId, strList);
                }else{
                    strList = conMapNotPrimary.get(con.AccountId);
                    strList.add(con.Email);
                    conMapNotPrimary.put(con.AccountId, strList);
                }
            }
        }
        String likeVal = '%CLONE';
        for(Opportunity opp : [SELECT Id, Owner.Email, Account.Name, Intro_Lender_1__r.Account.Name, Intro_Lender_2__r.Account.Name, Purchase_Method__c, Title_Verification_Email__c, Intro_Lender_1__c, Intro_Lender_2__c, Intro_Lender_1_Account__c, Intro_Lender_2_Account__c, Title_Name_Type__c, Intro_Lender_1_Intro_Email__c,Intro_Lender_2_Intro_Email__c, Intro_Lender_1__r.Email, Owner.FirstName, Owner.Sig2__c, Intro_Lender_1__r.Name, Intro_Lender_2__r.Name , Intro_Lender_2__r.Email FROM Opportunity WHERE Id IN : newList
                               AND RecordTypeId IN : salesRecordTypeIdSet AND (NOT Name LIKE: likeVal)]){
            // Title Verification Email --- 
            if(opp.Title_Verification_Email__c == TRUE){
                String subject = et3.Subject;
                if( opp.Account.Name != NULL){
                    subject = subject.replace('{!Opportunity.Account}', opp.Account.Name); 
                }else{
                    subject = subject.replace('{!Opportunity.Account}', ''); 
                }
                String htmlbody = et3.HtmlValue;
                if( opp.Account.Name != NULL){
                    htmlbody = htmlbody.replace('{!Opportunity.Account}', opp.Account.Name); 
                }else{
                    htmlbody = htmlbody.replace('{!Opportunity.Account}', ''); 
                }
                if(opp.Owner.FirstName != NULL){
                    htmlbody = htmlbody.replace('{!User.FirstName}', opp.Owner.FirstName); 
                }else{
                    htmlbody = htmlbody.replace('{!User.FirstName}', '');
                }
                if(opp.Owner.Sig2__c != NULL){
                    htmlbody = htmlbody.replace('{!User.Sig2__c}', opp.Owner.Sig2__c); 
                }else{
                    htmlbody = htmlbody.replace('{!User.Sig2__c}', ''); 
                }
                if(opp.Title_Name_Type__c != NULL){
                    htmlbody = htmlbody.replace('{!Opportunity.Title_Name_Type__c}', opp.Title_Name_Type__c);
                }else{
                    htmlbody = htmlbody.replace('{!Opportunity.Title_Name_Type__c}', '');
                }
                if(opp.Id != NULL){
                    htmlbody = htmlbody.replace('{!Opportunity.Id}', opp.Id);
                }else{
                    htmlbody = htmlbody.replace('{!Opportunity.Id}', ''); 
                }
                if(opp.Purchase_Method__c != NULL){
                    htmlbody = htmlbody.replace('{!Opportunity.Purchase_Method__c}', opp.Purchase_Method__c);
                }else{
                    htmlbody = htmlbody.replace('{!Opportunity.Purchase_Method__c}', ''); 
                }
                
                System.debug('map '+conMap.get(opp.AccountId));
                System.debug('map not primary '+conMapNotPrimary.get(opp.AccountId));
                String[] toAddresses = new String[]{};
                    System.debug('To Address for Title Email '+toAddresses);
                if(conMap.containsKey(opp.AccountId)){
                    toAddresses = conMap.get(opp.AccountId);
                }else if(conMapNotPrimary.containsKey(opp.AccountId)){
                    toAddresses = new String[]{conMapNotPrimary.get(opp.AccountId)[0]};
                        }
                if(conMap.containsKey(opp.AccountId) || conMapNotPrimary.containsKey(opp.AccountId)){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();   
                    mail.setSubject(subject);
                    mail.setReplyTo(Label.SalesOppIntroEmailService);
                    mail.setOrgWideEmailAddressId(orgEmail.Id);
                    mail.setToAddresses(toAddresses);
                    mail.setHtmlBody(htmlbody);  
                    mail.setSaveAsActivity(false);
                    allmsg.add(mail);
                    
                    EmailMessage emailMsg = new EmailMessage();
                    emailMsg.MessageDate = Datetime.now();
                    emailMsg.Status = '3';
                    emailMsg.RelatedToId = opp.Id;
                    emailMsg.FromAddress = opp.Owner.Email; //orgEmail.Address
                    emailMsg.FromName = orgEmail.DisplayName;
                    emailMsg.ToAddress = String.join(toAddresses, ',');
                    emailMsg.Subject = subject;
                    emailMsg.HtmlBody = htmlbody;
                    
                    emailHistories.add(emailMsg);
                }
                else{
                    Opportunity oppNew = newMap.get(opp.Id);
                    oppNew.addError('Account on this Opportunity is either not having any Contact or having a Contact with no Email Address');
                }
            }//
            if(opp.Intro_Lender_1__c != NULL && opp.Intro_Lender_1_Intro_Email__c == TRUE){
                System.debug('inside lender 1');
                String subject = et.Subject;
                if( opp.Account.Name != NULL){
                    subject = subject.replace('{!Opportunity.Account}', opp.Account.Name); 
                }else{
                    subject = subject.replace('{!Opportunity.Account}', ''); 
                }
                String htmlbody = et.HtmlValue;
                if(opp.Owner.FirstName != NULL){
                    htmlbody = htmlbody.replace('{!User.FirstName}', opp.Owner.FirstName); 
                }else{
                    htmlbody = htmlbody.replace('{!User.FirstName}', ''); 
                }
                if(opp.Owner.Sig2__c != NULL){
                    htmlbody = htmlbody.replace('{!User.Sig2__c}', opp.Owner.Sig2__c); 
                }else{
                    htmlbody = htmlbody.replace('{!User.Sig2__c}', ''); 
                }
                if(opp.Account.Name != NULL){
                    htmlbody = htmlbody.replace('{!Opportunity.Account}', opp.Account.Name); 
                }else{
                    htmlbody = htmlbody.replace('{!Opportunity.Account}', ''); 
                }
                if(opp.Intro_Lender_1__c != NULL){
                    htmlbody = htmlbody.replace('{!Opportunity.Intro_Lender_1_Account__c}', opp.Intro_Lender_1__r.Account.Name); 
                }else{
                    htmlbody = htmlbody.replace('{!Opportunity.Intro_Lender_1_Account__c}', ''); 
                }
                if(opp.Intro_Lender_1__c != NULL){
                    htmlbody = htmlbody.replace('{!Opportunity.Intro_Lender_1__c}', opp.Intro_Lender_1__r.Name); 
                }else{
                    htmlbody = htmlbody.replace('{!Opportunity.Intro_Lender_1__c}', ''); 
                }
                if(opp.Title_Name_Type__c != NULL){
                    htmlbody = htmlbody.replace('{!Opportunity.Title_Name_Type__c}', opp.Title_Name_Type__c); 
                }else{
                    htmlbody = htmlbody.replace('{!Opportunity.Title_Name_Type__c}', ''); 
                }
                if(opp.Id != NULL){
                    htmlbody = htmlbody.replace('{!Opportunity.Id}', opp.Id);
                }else{
                    htmlbody = htmlbody.replace('{!Opportunity.Id}', ''); 
                }
                if(opp.Purchase_Method__c != NULL){
                    htmlbody = htmlbody.replace('{!Opportunity.Purchase_Method__c}', opp.Purchase_Method__c);
                }else{
                    htmlbody = htmlbody.replace('{!Opportunity.Purchase_Method__c}', ''); 
                }
                
                
                String[] toAddresses = new String[]{};
                    System.debug('To Address for Title Email '+toAddresses);
                if(conMap.containsKey(opp.AccountId)){
                    toAddresses = conMap.get(opp.AccountId);
                }else if(conMapNotPrimary.containsKey(opp.AccountId)){
                    toAddresses = new String[]{conMapNotPrimary.get(opp.AccountId)[0]};
                        }
                    String[] ccAddresses = new String[]{opp.Intro_Lender_1__r.Email};
                        if(conMap.containsKey(opp.AccountId) || conMapNotPrimary.containsKey(opp.AccountId)){
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();   
                            mail.setSubject(subject);
                            mail.setReplyTo(Label.SalesOppIntroEmailService);
                            mail.setOrgWideEmailAddressId(orgEmail.Id);
                            mail.setToAddresses(toAddresses);
                            mail.setCcAddresses(ccAddresses);
                            mail.setHtmlBody(htmlbody);  
                            mail.setSaveAsActivity(false);
                            allmsg.add(mail);
                            
                            EmailMessage emailMsg = new EmailMessage();
                            emailMsg.MessageDate = Datetime.now();
                            emailMsg.Status = '3';
                            emailMsg.RelatedToId = opp.Id;
                            emailMsg.FromAddress = opp.Owner.Email; //orgEmail.Address
                            emailMsg.FromName = orgEmail.DisplayName;
                            emailMsg.ToAddress = String.join(toAddresses, ',');
                            emailMsg.CcAddress = String.join(ccAddresses, ',');
                            emailMsg.Subject = subject;
                            emailMsg.HtmlBody = htmlbody;
                            emailHistories.add(emailMsg);
                        }else{
                            Opportunity oppNew = newMap.get(opp.Id);
                            oppNew.addError('Account on this Opportunity is either not having any Contact or having a Contact with no Email Address');
                        }
            }// lender 1
            
            if(opp.Intro_Lender_2__c != NULL && opp.Intro_Lender_2_Intro_Email__c == TRUE){
                System.debug('inside lender 2');
                String subject = et2.Subject;
                if( opp.Account.Name != NULL){
                    subject = subject.replace('{!Opportunity.Account}', opp.Account.Name); 
                }else{
                    subject = subject.replace('{!Opportunity.Account}', ''); 
                }
                String htmlbody = et2.HtmlValue;
                if(opp.Owner.FirstName != NULL){
                    htmlbody = htmlbody.replace('{!User.FirstName}', opp.Owner.FirstName); 
                }else{
                    htmlbody = htmlbody.replace('{!User.FirstName}', ''); 
                }
                if(opp.Owner.Sig2__c != NULL){
                    htmlbody = htmlbody.replace('{!User.Sig2__c}', opp.Owner.Sig2__c); 
                }else{
                    htmlbody = htmlbody.replace('{!User.Sig2__c}', ''); 
                }
                if(opp.Account.Name != NULL){
                    htmlbody = htmlbody.replace('{!Opportunity.Account}', opp.Account.Name); 
                }else{
                    htmlbody = htmlbody.replace('{!Opportunity.Account}', ''); 
                }
                if(opp.Intro_Lender_2_Account__c != NULL){
                    htmlbody = htmlbody.replace('{!Opportunity.Intro_Lender_2_Account__c}', opp.Intro_Lender_2__r.Account.Name); 
                }else{
                    htmlbody = htmlbody.replace('{!Opportunity.Intro_Lender_2_Account__c}', ''); 
                }
                if(opp.Intro_Lender_2__c != NULL){
                    htmlbody = htmlbody.replace('{!Opportunity.Intro_Lender_2__c}', opp.Intro_Lender_2__r.Name); 
                }else{
                    htmlbody = htmlbody.replace('{!Opportunity.Intro_Lender_2__c}', ''); 
                }
                if(opp.Title_Name_Type__c != NULL){
                    htmlbody = htmlbody.replace('{!Opportunity.Title_Name_Type__c}', opp.Title_Name_Type__c); 
                }else{
                    htmlbody = htmlbody.replace('{!Opportunity.Title_Name_Type__c}', ''); 
                }
                if(opp.Id != NULL){
                    htmlbody = htmlbody.replace('{!Opportunity.Id}', opp.Id);
                }else{
                    htmlbody = htmlbody.replace('{!Opportunity.Id}', ''); 
                }
                if(opp.Purchase_Method__c != NULL){
                    htmlbody = htmlbody.replace('{!Opportunity.Purchase_Method__c}', opp.Purchase_Method__c);
                }else{
                    htmlbody = htmlbody.replace('{!Opportunity.Purchase_Method__c}', ''); 
                }
                
                String[] toAddresses = new String[]{};
                    System.debug('To Address for Title Email '+toAddresses);
                if(conMap.containsKey(opp.AccountId)){
                    toAddresses = conMap.get(opp.AccountId);
                }else if(conMapNotPrimary.containsKey(opp.AccountId)){
                    toAddresses = new String[]{conMapNotPrimary.get(opp.AccountId)[0]};
                        }
                    String[] ccAddresses = new String[]{opp.Intro_Lender_2__r.Email};
                        if(conMap.containsKey(opp.AccountId) || conMapNotPrimary.containsKey(opp.AccountId)){
                            Messaging.SingleEmailMessage mail2 = new Messaging.SingleEmailMessage();   
                            mail2.setSubject(subject);
                            mail2.setReplyTo(Label.SalesOppIntroEmailService);
                            mail2.setOrgWideEmailAddressId(orgEmail.Id);
                            mail2.setToAddresses(toAddresses);
                            mail2.setCcAddresses(ccAddresses);
                            mail2.setHtmlBody(htmlbody);  
                            mail2.setSaveAsActivity(true);
                            allmsg.add(mail2);
                            
                            EmailMessage emailMsg2 = new EmailMessage();
                            emailMsg2.MessageDate = Datetime.now();
                            emailMsg2.Status = '3';
                            emailMsg2.RelatedToId = opp.Id;
                            emailMsg2.FromAddress = opp.Owner.Email; //orgEmail.Address
                            emailMsg2.FromName = orgEmail.DisplayName;
                            emailMsg2.ToAddress = String.join(toAddresses, ',');
                            emailMsg2.CcAddress = String.join(ccAddresses, ',');
                            emailMsg2.Subject = subject;
                            emailMsg2.HtmlBody = htmlbody;
                            
                            emailHistories.add(emailMsg2);
                        }else{
                            Opportunity oppNew = newMap.get(opp.Id);
                            oppNew.addError('Account on this Opportunity is either not having any Contact or having a Contact with no Email Address');
                        }
            }// lender 2                                   
        }
        
        if(!emailHistories.isEmpty()){
            insert emailHistories;
        }
        
        if(!Test.isRunningTest()){
            Messaging.SendEmailResult[] r = Messaging.sendEmail(allmsg);
            System.debug('mail send results'+ r);
        }
    }
    
    public static void afterUpdateSendEmail(){
        EmailTemplate et = [SELECT Id,Subject,HtmlValue,Body FROM EmailTemplate WHERE Name = 'Lender 1 Intro Email'];
        EmailTemplate et2 = [SELECT Id,Subject,HtmlValue,Body FROM EmailTemplate WHERE Name = 'Lender 2 Intro Email'];
        EmailTemplate et3 = [SELECT Id,Subject,HtmlValue,Body FROM EmailTemplate WHERE Name = 'REI Nation Title Verification'];
        OrgWideEmailAddress orgEmail = [select Id, DisplayName, Address from OrgWideEmailAddress where DisplayName = 'Portfolio Advisor'];
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        List<EmailMessage> emailHistories = new List<EmailMessage>();
        
        Set<id> salesRecordTypeIdSet = new Set<id>();
        for(RecordType rt : [SELECT id FROM RecordType where sObjectType = 'Opportunity' AND Name LIKE 'Investor%']){
            salesRecordTypeIdSet.add(rt.id);
        }
        
        Set<Id> accId = new Set<Id>();
        Map<Id, List<String>> conMap = new Map<Id, List<String>>();
        Map<Id, List<String>> conMapNotPrimary = new Map<Id, List<String>>();
        
        for(Opportunity opp : newList){
            accId.add(opp.AccountId);
        }
        for(Contact con : [SELECT Id, AccountId, Email, Is_Primary__c FROM Contact WHERE AccountId IN: accId AND Email != NULL ORDER BY CreatedDate ASC]){
            List<String> strList = new List<String>();
            if(con.Is_Primary__c == TRUE){
                System.debug('email ' +con.Email);
                if(!conMap.containsKey(con.AccountId)){
                    strList.add(con.Email);
                    conMap.put(con.AccountId, strList);
                }else{
                    strList = conMap.get(con.AccountId);
                    strList.add(con.Email);
                    conMap.put(con.AccountId, strList);
                }    
            }else{
                if(!conMapNotPrimary.containsKey(con.AccountId)){
                    strList.add(con.Email);
                    conMapNotPrimary.put(con.AccountId, strList);
                }else{
                    strList = conMapNotPrimary.get(con.AccountId);
                    strList.add(con.Email);
                    conMapNotPrimary.put(con.AccountId, strList);
                }
            }
        }
        System.debug('conMap' +conMap);
        for(Opportunity opp : [SELECT Id, Owner.Email, Purchase_Method__c, Intro_Lender_2__r.Account.Name, Intro_Lender_1__r.Account.Name, Account.Name, Title_Verification_Email__c, Intro_Lender_1__c, Intro_Lender_2__c, Intro_Lender_1_Account__c, Intro_Lender_2_Account__c, Title_Name_Type__c, Intro_Lender_1_Intro_Email__c,Intro_Lender_2_Intro_Email__c, Intro_Lender_1__r.Email, Owner.FirstName, Owner.Sig2__c, Intro_Lender_1__r.Name, Intro_Lender_2__r.Name , Intro_Lender_2__r.Email FROM Opportunity WHERE Id IN : newList AND RecordTypeId IN : salesRecordTypeIdSet]){
            // Title Verification Email --- 
            if(opp.Title_Verification_Email__c == TRUE && oldMap.get(opp.Id).Title_Verification_Email__c != opp.Title_Verification_Email__c){
                String subject = et3.Subject;
                if( opp.Account.Name != NULL){
                    subject = subject.replace('{!Opportunity.Account}', opp.Account.Name); 
                }else{
                    subject = subject.replace('{!Opportunity.Account}', ''); 
                }
                String htmlbody = et3.HtmlValue;
                if( opp.Account.Name != NULL){
                    htmlbody = htmlbody.replace('{!Opportunity.Account}', opp.Account.Name); 
                }else{
                    htmlbody = htmlbody.replace('{!Opportunity.Account}', ''); 
                }
                if(opp.Owner.FirstName != NULL){
                    htmlbody = htmlbody.replace('{!User.FirstName}', opp.Owner.FirstName); 
                }else{
                    htmlbody = htmlbody.replace('{!User.FirstName}', '');
                }
                if(opp.Owner.Sig2__c != NULL){
                    htmlbody = htmlbody.replace('{!User.Sig2__c}', opp.Owner.Sig2__c); 
                }else{
                    htmlbody = htmlbody.replace('{!User.Sig2__c}', ''); 
                }
                if(opp.Title_Name_Type__c != NULL){
                    htmlbody = htmlbody.replace('{!Opportunity.Title_Name_Type__c}', opp.Title_Name_Type__c);
                }else{
                    htmlbody = htmlbody.replace('{!Opportunity.Title_Name_Type__c}', '');
                }
                if(opp.Id != NULL){
                    htmlbody = htmlbody.replace('{!Opportunity.Id}', opp.Id);
                }else{
                    htmlbody = htmlbody.replace('{!Opportunity.Id}', ''); 
                }
                if(opp.Purchase_Method__c != NULL){
                    htmlbody = htmlbody.replace('{!Opportunity.Purchase_Method__c}', opp.Purchase_Method__c);
                }else{
                    htmlbody = htmlbody.replace('{!Opportunity.Purchase_Method__c}', ''); 
                }
                
                System.debug('map '+conMap.get(opp.AccountId));
                System.debug('map not primary '+conMapNotPrimary.get(opp.AccountId));
                String[] toAddresses = new String[]{};
                    System.debug('To Address for Title Email '+toAddresses);
                if(conMap.containsKey(opp.AccountId)){
                    toAddresses = conMap.get(opp.AccountId);
                }else if(conMapNotPrimary.containsKey(opp.AccountId)){
                    toAddresses = new String[]{conMapNotPrimary.get(opp.AccountId)[0]};
                        }
                if(conMap.containsKey(opp.AccountId) || conMapNotPrimary.containsKey(opp.AccountId)){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();   
                    mail.setSubject(subject);
                    mail.setReplyTo(Label.SalesOppIntroEmailService);
                    mail.setOrgWideEmailAddressId(orgEmail.Id);
                    mail.setToAddresses(toAddresses);
                    mail.setHtmlBody(htmlbody);  
                    mail.setSaveAsActivity(false);
                    allmsg.add(mail);
                    
                    EmailMessage emailMsg = new EmailMessage();
                    emailMsg.MessageDate = Datetime.now();
                    emailMsg.Status = '3';
                    emailMsg.RelatedToId = opp.Id;
                    emailMsg.FromAddress = orgEmail.Address; //orgEmail.Address
                    emailMsg.FromName = orgEmail.DisplayName;
                    emailMsg.ToAddress = String.join(toAddresses, ',');
                    emailMsg.Subject = subject;
                    emailMsg.HtmlBody = htmlbody;
                    emailHistories.add(emailMsg);
                }
                else{
                    Opportunity oppNew = newMap.get(opp.Id);
                    oppNew.addError('Account on this Opportunity is either not having any Contact or having a Contact with no Email Address');
                }
            }// 
            
            if(opp.Intro_Lender_1__c != NULL && opp.Intro_Lender_1_Intro_Email__c == TRUE && oldMap.get(opp.Id).Intro_Lender_1_Intro_Email__c != opp.Intro_Lender_1_Intro_Email__c){
                System.debug('inside lender 1');
                String subject = et.Subject;
                if( opp.Account.Name != NULL){
                    subject = subject.replace('{!Opportunity.Account}', opp.Account.Name); 
                }else{
                    subject = subject.replace('{!Opportunity.Account}', ''); 
                }
                String htmlbody = et.HtmlValue;
                if(opp.Owner.FirstName != NULL){
                    htmlbody = htmlbody.replace('{!User.FirstName}', opp.Owner.FirstName); 
                }else{
                    htmlbody = htmlbody.replace('{!User.FirstName}', ''); 
                }
                if(opp.Owner.Sig2__c != NULL){
                    htmlbody = htmlbody.replace('{!User.Sig2__c}', opp.Owner.Sig2__c); 
                }else{
                    htmlbody = htmlbody.replace('{!User.Sig2__c}', ''); 
                }
                if( opp.Account.Name != NULL){
                    htmlbody = htmlbody.replace('{!Opportunity.Account}', opp.Account.Name); 
                }else{
                    htmlbody = htmlbody.replace('{!Opportunity.Account}', ''); 
                }
                if(opp.Intro_Lender_1__c != NULL){
                    htmlbody = htmlbody.replace('{!Opportunity.Intro_Lender_1_Account__c}', opp.Intro_Lender_1__r.Account.Name); 
                }else{
                    htmlbody = htmlbody.replace('{!Opportunity.Intro_Lender_1_Account__c}', ''); 
                }
                if(opp.Intro_Lender_1__c != NULL){
                    htmlbody = htmlbody.replace('{!Opportunity.Intro_Lender_1__c}', opp.Intro_Lender_1__r.Name); 
                }else{
                    htmlbody = htmlbody.replace('{!Opportunity.Intro_Lender_1__c}', ''); 
                }
                if(opp.Title_Name_Type__c != NULL){
                    htmlbody = htmlbody.replace('{!Opportunity.Title_Name_Type__c}', opp.Title_Name_Type__c); 
                }else{
                    htmlbody = htmlbody.replace('{!Opportunity.Title_Name_Type__c}', ''); 
                }
                if(opp.Id != NULL){
                    htmlbody = htmlbody.replace('{!Opportunity.Id}', opp.Id);
                }else{
                    htmlbody = htmlbody.replace('{!Opportunity.Id}', ''); 
                }
                if(opp.Purchase_Method__c != NULL){
                    htmlbody = htmlbody.replace('{!Opportunity.Purchase_Method__c}', opp.Purchase_Method__c);
                }else{
                    htmlbody = htmlbody.replace('{!Opportunity.Purchase_Method__c}', ''); 
                }
                
                String[] toAddresses = new String[]{};
                    String[] ccAddresses = new String[]{opp.Intro_Lender_1__r.Email};
                        
                        if(conMap.containsKey(opp.AccountId)){
                            toAddresses = conMap.get(opp.AccountId);
                        }else if(conMapNotPrimary.containsKey(opp.AccountId)){
                            toAddresses = new String[]{conMapNotPrimary.get(opp.AccountId)[0]};
                                System.debug('to Address'+toAddresses);
                        }
                if(conMap.containsKey(opp.AccountId) || conMapNotPrimary.containsKey(opp.AccountId)){    
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();   
                    mail.setSubject(subject);
                    mail.setReplyTo(Label.SalesOppIntroEmailService);
                    mail.setOrgWideEmailAddressId(orgEmail.Id);
                    mail.setToAddresses(toAddresses);
                    mail.setCcAddresses(ccAddresses);
                    mail.setHtmlBody(htmlbody);  
                    mail.setSaveAsActivity(false);
                    allmsg.add(mail);
                    
                    EmailMessage emailMsg = new EmailMessage();
                    emailMsg.MessageDate = Datetime.now();
                    emailMsg.Status = '3';
                    emailMsg.RelatedToId = opp.Id;
                    emailMsg.FromAddress = opp.Owner.Email; //orgEmail.Address
                    emailMsg.FromName = orgEmail.DisplayName;
                    emailMsg.ToAddress = String.join(toAddresses, ',');
                    emailMsg.CcAddress = String.join(ccAddresses, ',');
                    emailMsg.Subject = subject;
                    emailMsg.HtmlBody = htmlbody;
                    
                    emailHistories.add(emailMsg);
                }
                else{
                    Opportunity oppNew = newMap.get(opp.Id);
                    oppNew.addError('Account on this Opportunity is either not having any Contact or having a Contact with no Email Address');
                }
            }
            // lender 1
            
            if(opp.Intro_Lender_2__c != NULL && opp.Intro_Lender_2_Intro_Email__c == TRUE && oldMap.get(opp.Id).Intro_Lender_2_Intro_Email__c != opp.Intro_Lender_2_Intro_Email__c){
                System.debug('inside lender 2');
                String subject = et2.Subject;
                if( opp.Account.Name != NULL){
                    subject = subject.replace('{!Opportunity.Account}', opp.Account.Name); 
                }else{
                    subject = subject.replace('{!Opportunity.Account}', ''); 
                }
                String htmlbody = et2.HtmlValue;
                if(opp.Owner.FirstName != NULL){
                    htmlbody = htmlbody.replace('{!User.FirstName}', opp.Owner.FirstName); 
                }else{
                    htmlbody = htmlbody.replace('{!User.FirstName}', ''); 
                }
                if(opp.Owner.Sig2__c != NULL){
                    htmlbody = htmlbody.replace('{!User.Sig2__c}', opp.Owner.Sig2__c); 
                }else{
                    htmlbody = htmlbody.replace('{!User.Sig2__c}', ''); 
                }
                if(opp.Account.Name != NULL){
                    htmlbody = htmlbody.replace('{!Opportunity.Account}', opp.Account.Name); 
                }else{
                    htmlbody = htmlbody.replace('{!Opportunity.Account}', ''); 
                }
                if(opp.Intro_Lender_2__c != NULL){
                    htmlbody = htmlbody.replace('{!Opportunity.Intro_Lender_2_Account__c}', opp.Intro_Lender_2__r.Account.Name); 
                }else{
                    htmlbody = htmlbody.replace('{!Opportunity.Intro_Lender_2_Account__c}', ''); 
                }
                if(opp.Intro_Lender_2__c != NULL){
                    htmlbody = htmlbody.replace('{!Opportunity.Intro_Lender_2__c}', opp.Intro_Lender_2__r.Name); 
                }else{
                    htmlbody = htmlbody.replace('{!Opportunity.Intro_Lender_2__c}', ''); 
                }
                if(opp.Title_Name_Type__c != NULL){
                    htmlbody = htmlbody.replace('{!Opportunity.Title_Name_Type__c}', opp.Title_Name_Type__c); 
                }else{
                    htmlbody = htmlbody.replace('{!Opportunity.Title_Name_Type__c}', ''); 
                }
                if(opp.Id != NULL){
                    htmlbody = htmlbody.replace('{!Opportunity.Id}', opp.Id);
                }else{
                    htmlbody = htmlbody.replace('{!Opportunity.Id}', ''); 
                }
                if(opp.Purchase_Method__c != NULL){
                    htmlbody = htmlbody.replace('{!Opportunity.Purchase_Method__c}', opp.Purchase_Method__c);
                }else{
                    htmlbody = htmlbody.replace('{!Opportunity.Purchase_Method__c}', ''); 
                }
                
                String[] toAddresses = new String[]{};
                    String[] ccAddresses = new String[]{opp.Intro_Lender_2__r.Email};
                        System.debug('To Address for Title Email '+toAddresses);
                if(conMap.containsKey(opp.AccountId)){
                    toAddresses = conMap.get(opp.AccountId);
                }else if(conMapNotPrimary.containsKey(opp.AccountId)){
                    toAddresses = new String[]{conMapNotPrimary.get(opp.AccountId)[0]};
                        }
                if(conMap.containsKey(opp.AccountId) || conMapNotPrimary.containsKey(opp.AccountId)){        
                    Messaging.SingleEmailMessage mail2 = new Messaging.SingleEmailMessage();   
                    mail2.setSubject(subject);
                    mail2.setReplyTo(Label.SalesOppIntroEmailService);
                    mail2.setOrgWideEmailAddressId(orgEmail.Id);
                    mail2.setToAddresses(toAddresses);
                    mail2.setCcAddresses(ccAddresses);
                    mail2.setHtmlBody(htmlbody);  
                    mail2.setSaveAsActivity(true);
                    allmsg.add(mail2);
                    
                    EmailMessage emailMsg2 = new EmailMessage();
                    emailMsg2.MessageDate = Datetime.now();
                    emailMsg2.Status = '3';
                    emailMsg2.RelatedToId = opp.Id;
                    emailMsg2.FromAddress = opp.Owner.Email; //orgEmail.Address
                    emailMsg2.FromName = orgEmail.DisplayName;
                    emailMsg2.ToAddress = String.join(toAddresses, ',');
                    emailMsg2.CcAddress = String.join(ccAddresses, ',');
                    emailMsg2.Subject = subject;
                    emailMsg2.HtmlBody = htmlbody;
                    
                    emailHistories.add(emailMsg2);
                }
                else{
                    Opportunity oppNew = newMap.get(opp.Id);
                    oppNew.addError('Account on this Opportunity is either not having any Contact or having a Contact with no Email Address');
                }
            }
            
        }// lender 2
        
        if(!emailHistories.isEmpty()){
            insert emailHistories;
        }
        
        if(!Test.isRunningTest()){
            Messaging.SendEmailResult[] r = Messaging.sendEmail(allmsg);
            System.debug('mail send results'+ r);
        }
    } //end of afterupdate
    public static void afterInsertUpdateContactRole(){
        List<OpportunityContactRole> newContactRoleList = new List<OpportunityContactRole>();
        for(Opportunity opp : newList){
            if(opp.Lender_Name__c != NULL){
                OpportunityContactRole oppContact = new OpportunityContactRole();
                oppContact.ContactId = opp.Lender_Name__c; 
                oppContact.OpportunityId = opp.Id;
                oppContact.Role = 'Lender';
                oppContact.IsPrimary = FALSE;
                newContactRoleList.add(oppContact);
            }
            
        }
        
        if(newContactRoleList.size() > 0){
            insert newContactRoleList;
        }
        
    }// end of afterInsertUpdateContactRole
    public static void afterUpdateUpdateContactRole(){
        Set<Id> idSet = new Set<Id>();
        for(Opportunity opp : newList){
            idSet.add(opp.Id);
        }
        List<OpportunityContactRole> newContactRoleList = new List<OpportunityContactRole>();
        List<OpportunityContactRole> deleteContactRoleList = new List<OpportunityContactRole>();
        Map<String, OpportunityContactRole> oppContactMap = new Map<String, OpportunityContactRole>();
        String str = '';
        for(OpportunityContactRole oppContact : [SELECT id,ContactId,OpportunityId FROM OpportunityContactRole WHERE OpportunityId IN: idSet]){
            str = '';
            str += oppContact.OpportunityId;
            str += oppContact.ContactId;
            oppContactMap.put(str, oppContact);
        }
        system.debug('oppmap'+oppContactMap);
        
        
        String str2 = '';
        for(Opportunity opp : newList){
            str2 = '';
            system.debug('inside for');
            if(opp.Lender_Name__c != NULL && oldMap.get(opp.Id).Lender_Name__c != opp.Lender_Name__c){
                system.debug('inside cond');
                if(oldMap.get(opp.Id).Lender_Name__c != NULL){
                    str2 += opp.Id;
                    str2 += oldMap.get(opp.Id).Lender_Name__c;
                    OpportunityContactRole oppCon = oppContactMap.get(str2);
                    deleteContactRoleList.add(oppCon);
                    system.debug(str2);
                    system.debug(oppCon);
                }
                OpportunityContactRole oppContact = new OpportunityContactRole();
                oppContact.ContactId = opp.Lender_Name__c; 
                oppContact.OpportunityId = opp.Id;
                oppContact.Role = 'Lender';
                oppContact.IsPrimary = FALSE;
                newContactRoleList.add(oppContact);
            }else if(opp.Lender_Name__c == NULL && oldMap.get(opp.Id).Lender_Name__c != NULL){
                str2 += opp.Id;
                str2 += oldMap.get(opp.Id).Lender_Name__c;
                OpportunityContactRole oppCon = oppContactMap.get(str2);
                deleteContactRoleList.add(oppCon);
            }
        }
        
        if(newContactRoleList.size() > 0){
            system.debug('insert');
            insert newContactRoleList;
        }
        if(!deleteContactRoleList.isEmpty()){
            try{
                delete deleteContactRoleList;
            }catch(Exception ex){
                System.debug(ex.getMessage()+''+ex.getLineNumber());
            }
            
        }
    }// end of afterUpdateUpdateContactRole method
}