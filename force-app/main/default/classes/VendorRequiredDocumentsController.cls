public with sharing class VendorRequiredDocumentsController {
    
    
    @AuraEnabled
    public static List<ContentVersion> getConVersionList(Id recordId){
        
        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        Set<string> uploadedDocs = new Set<string>();
        Set<Id> conDocIds = new Set<Id>();
        for(ContentDocumentLink cdLink: [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: recordId])
        {
            conDocIds.add(cdLink.ContentDocumentId);
        }
        
        if(conDocIds.size() > 0){
            for(ContentVersion cv : [SELECT Id, ContentDocumentId, Attachment_Type__c, Expiration_Date__c, Title, Status__c 
                                     FROM ContentVersion WHERE ContentDocumentId =: conDocIds AND Attachment_Type__c != null 
                                     AND IsLatest = true]){
                                         contentVersionList.add(cv);
                                         uploadedDocs.add(cv.Attachment_Type__c);
                                     }
        }
        System.debug('uploadedDocs'+uploadedDocs);
        Set<String> requireDocsSet = new Set<String>();
        // Common Document For All Category
        if(!uploadedDocs.contains('W9')){
            requireDocsSet.add('W9');
        }
        
        if(!uploadedDocs.contains('TIN Documentation (Social Security Card or IRS Notice of Assignment of TIN)')){ 
            requireDocsSet.add('TIN Documentation (Social Security Card or IRS Notice of Assignment of TIN)');
        }
        
        if(!uploadedDocs.contains('Driver’s License/Photo Id')){
            requireDocsSet.add('Driver’s License/Photo Id');
        }
        
        if(!uploadedDocs.contains('Direct Deposit Agreement')){ //diff
            requireDocsSet.add('Direct Deposit Agreement');
        }
        
        if(!uploadedDocs.contains('Voided Check')){
            requireDocsSet.add('Voided Check');
        }
        if(!uploadedDocs.contains('Payment Agreement')){
            requireDocsSet.add('Payment Agreement');
        }
         /* Added new Markets - 5/07/2021 - Isaac A. Huicochea*/
        for(Account acc : [SELECT Id,Type,Market__c,Category_1__c,Maint_Category_1__c FROM Account WHERE Id=: recordId]){
            if(String.isNotBlank(acc.Category_1__c)){
                if(String.isNotBlank(acc.Market__c))
                {
                    if(acc.Type == 'Rehab & Maintenance' && (acc.Market__c.contains('MEM') || acc.Market__c.contains('STL') || acc.Market__c.contains('BHM') || 
                                                             acc.Market__c.contains('HSV') || acc.Market__c.contains('TUS') || acc.Market__c.contains('TLH') || 
                                                             acc.Market__c.contains('JKT') || acc.Market__c.contains('JAN') || acc.Market__c.contains('CHA') || 
                                                             acc.Market__c.contains('BNA')))
                    {
                        if(!requireDocsSet.contains('Hold Harmless Agreement REI') && !uploadedDocs.contains('Hold Harmless Agreement REI')){
                            requireDocsSet.add('Hold Harmless Agreement REI');
                        }
                        if(!requireDocsSet.contains('Hold Harmless Agreement Premier') && !uploadedDocs.contains('Hold Harmless Agreement Premier')){
                            requireDocsSet.add('Hold Harmless Agreement Premier');
                        }
                    }
                    if(acc.Type == 'Rehab & Maintenance' && (acc.Market__c.contains('DFW') || acc.Market__c.contains('SAN') ||
                                                             acc.Market__c.contains('HOU') || acc.Market__c.contains('LIT') ||
                                                             acc.Market__c.contains('OKC') || acc.Market__c.contains('TUL') || 
                                                             acc.Market__c.contains('AUS')))
                    {
                        if(!requireDocsSet.contains('Hold Harmless Agreement REI') && !uploadedDocs.contains('Hold Harmless Agreement REI'))
                        {
                            requireDocsSet.add('Hold Harmless Agreement REI');
                        }
                        if(!requireDocsSet.contains('Hold Harmless Agreement PPMG TX') && !uploadedDocs.contains('Hold Harmless Agreement PPMG TX'))
                        { 
                            requireDocsSet.add('Hold Harmless Agreement PPMG TX');
                        }
                    }
                }
                
                if(acc.Category_1__c.contains('Electrical') || 
                   acc.Category_1__c.contains('HVAC') ||
                   acc.Category_1__c.contains('Plumbing') ||
                   acc.Category_1__c.contains('Foundation')
                  )
                {
                    if(!requireDocsSet.contains('License') && !uploadedDocs.contains('License'))
                    { 
                        requireDocsSet.add('License');
                    }
                    if(!requireDocsSet.contains('Permits') && !uploadedDocs.contains('Permits'))
                    { 
                        requireDocsSet.add('Permits');
                    }
                }
                
                if( acc.Category_1__c.contains('Engineer') ||
                   acc.Category_1__c.contains('Locks') ||
                   acc.Category_1__c.contains('Pest Control') ||
                   acc.Category_1__c.contains('Insulation') ||
                   acc.Category_1__c.contains('Chimneys')
                  )
                {
                    if(!requireDocsSet.contains('License') && !uploadedDocs.contains('License'))
                    { 
                        requireDocsSet.add('License');
                    }
                }
                
                if(acc.Category_1__c.contains('Electrical') || 
                   acc.Category_1__c.contains('Engineer') ||
                   acc.Category_1__c.contains('Foundation') ||
                   acc.Category_1__c.contains('HVAC') ||
                   acc.Category_1__c.contains('Locks') ||
                   acc.Category_1__c.contains('Plumbing') ||
                   acc.Category_1__c.contains('Pest Control') ||
                   acc.Category_1__c.contains('Roofs') ||
                   acc.Category_1__c.contains('Chimneys') ||
                   acc.Category_1__c.contains('Tree Removal') ||
                   acc.Category_1__c.contains('Insulation') ||
                   acc.Category_1__c.contains('Windows')
                  )
                {
                    if(!requireDocsSet.contains('Certificate of Insurance - General Liability') && !uploadedDocs.contains('Certificate of Insurance - General Liability')){
                        requireDocsSet.add('Certificate of Insurance - General Liability');
                    }
                     /* Added new Markets - 5/07/2021 - Isaac A. Huicochea*/
                    if(String.isNotBlank(acc.Market__c))
                    {
                        if(acc.Type == 'Rehab & Maintenance' && (acc.Market__c.contains('MEM') || acc.Market__c.contains('STL') || acc.Market__c.contains('BHM') || 
                                                             	 acc.Market__c.contains('HSV') || acc.Market__c.contains('TUS') || acc.Market__c.contains('TLH') || 
                                                             	 acc.Market__c.contains('JKT') || acc.Market__c.contains('JAN') || acc.Market__c.contains('CHA') || 
                                                             	 acc.Market__c.contains('BNA')))
                        {
                            if(!requireDocsSet.contains('Insurance Agreement REI') && !uploadedDocs.contains('Insurance Agreement REI')){
                                requireDocsSet.add('Insurance Agreement REI');
                            } 
                        }
                        if(acc.Type == 'Rehab & Maintenance' && (acc.Market__c.contains('DFW') ||acc.Market__c.contains('SAN') || 
                                                                 acc.Market__c.contains('HOU') || acc.Market__c.contains('LIT') ||
                                                                 acc.Market__c.contains('OKC') || acc.Market__c.contains('TUL') || 
                                                                 acc.Market__c.contains('BHM') || acc.Market__c.contains('HSV') || 
                                                                 acc.Market__c.contains('AUS')))
                        {
                            if(!requireDocsSet.contains('Insurance Agreement REI') && !uploadedDocs.contains('Insurance Agreement REI')){
                                requireDocsSet.add('Insurance Agreement REI');
                            }
                        }
                    }
                    
                    if(acc.Type == 'Rehab')
                    {
                        if(!requireDocsSet.contains('Insurance Agreement REI') && !uploadedDocs.contains('Insurance Agreement REI')){
                            requireDocsSet.add('Insurance Agreement REI');
                        }
                        if(!requireDocsSet.contains('Hold Harmless Agreement REI') && !uploadedDocs.contains('Hold Harmless Agreement REI')){
                            requireDocsSet.add('Hold Harmless Agreement REI');
                        }
                    }
                }
                if(acc.Category_1__c.contains('Appliances') || 
                   acc.Category_1__c.contains('Cages') ||
                   acc.Category_1__c.contains('Carpet') ||
                   acc.Category_1__c.contains('Cleaning') ||
                   acc.Category_1__c.contains('Concrete') ||
                   acc.Category_1__c.contains('Garage Doors') ||
                   acc.Category_1__c.contains('Gas') ||
                   acc.Category_1__c.contains('Gutters') ||
                   acc.Category_1__c.contains('Handyman') ||
                   acc.Category_1__c.contains('Countertops') ||
                   acc.Category_1__c.contains('Hardwoods') ||
                   acc.Category_1__c.contains('Inspector') ||
                   acc.Category_1__c.contains('Move Outs') ||
                   acc.Category_1__c.contains('Painter') ||
                   acc.Category_1__c.contains('Project Manager') ||
                   acc.Category_1__c.contains('Rehab') ||
                   acc.Category_1__c.contains('Trash') ||
                   acc.Category_1__c.contains('Tub/Top Refinishing') ||
                   acc.Category_1__c.contains('Utility/City') ||
                   acc.Category_1__c.contains('Yard Crew') ||
                   acc.Category_1__c.contains('Photography') ||
                   acc.Category_1__c.contains('Chimneys') ||
                   acc.Category_1__c.contains('Tree Removal') ||
                   acc.Category_1__c.contains('Insulation') ||
                   acc.Category_1__c.contains('Windows')
                  ){
                      if(acc.Type == 'Rehab')
                      {
                          if(!requireDocsSet.contains('Hold Harmless Agreement REI') && !uploadedDocs.contains('Hold Harmless Agreement REI')){
                              requireDocsSet.add('Hold Harmless Agreement REI');
                          }
                      }
                  }
            }  
            /* Added new Markets - 5/07/2021 - Isaac A. Huicochea*/
            if(String.isNotBlank(acc.Maint_Category_1__c)){
                if(String.isNotBlank(acc.Market__c))
                {
                    System.debug('acc.Maint_Category_1__c:-----'+acc.Maint_Category_1__c);
                    if(acc.Type == 'Maintenance' && (acc.Market__c.contains('MEM') || acc.Market__c.contains('STL') || acc.Market__c.contains('BHM') || 
                                                     acc.Market__c.contains('HSV') || acc.Market__c.contains('TUS') || acc.Market__c.contains('TLH') || 
                                                     acc.Market__c.contains('JKT') || acc.Market__c.contains('JAN') || acc.Market__c.contains('CHA') || 
                                                     acc.Market__c.contains('BNA')))
                    {
                        if(!requireDocsSet.contains('Hold Harmless Agreement Premier') && !uploadedDocs.contains('Hold Harmless Agreement Premier')){
                            requireDocsSet.add('Hold Harmless Agreement Premier');
                        }
                    }
                    System.debug('acc.Type:-----'+acc.Type);
                    if(acc.Type == 'Maintenance' && (acc.Market__c.contains('DFW') || acc.Market__c.contains('SAN') || 
                                                     acc.Market__c.contains('HOU') || acc.Market__c.contains('LIT') ||
                                                     acc.Market__c.contains('OKC') || acc.Market__c.contains('TUL') ||
                                                     acc.Market__c.contains('AUS')))
                    {
                        if(!requireDocsSet.contains('Hold Harmless Agreement PPMG TX') && !uploadedDocs.contains('Hold Harmless Agreement PPMG TX')){
                            requireDocsSet.add('Hold Harmless Agreement PPMG TX');
                        }
                        System.debug('requireDocsSet-----'+requireDocsSet);
                    }
                }
                
                if(acc.Maint_Category_1__c.contains('Electrical') || 
                   acc.Maint_Category_1__c.contains('HVAC')  ||
                   acc.Maint_Category_1__c.contains('Plumbing') ||
                   acc.Maint_Category_1__c.contains('Foundation')
                  )
                {
                    if(!requireDocsSet.contains('License') && !uploadedDocs.contains('License')){
                        requireDocsSet.add('License');
                    }
                    if(!requireDocsSet.contains('Permits') && !uploadedDocs.contains('Permits')){
                        requireDocsSet.add('Permits');
                    }
                }
                
                if(acc.Maint_Category_1__c.contains('Engineer') ||
                   acc.Maint_Category_1__c.contains('Locks') ||
                   acc.Maint_Category_1__c.contains('Chimneys') ||
                   acc.Maint_Category_1__c.contains('Insulation') ||
                   acc.Maint_Category_1__c.contains('Pest Control')
                  )
                {
                    if(!requireDocsSet.contains('License') && !uploadedDocs.contains('License')){
                        requireDocsSet.add('License');
                    }
                }
                
                if(acc.Maint_Category_1__c.contains('Electrical') || 
                   acc.Maint_Category_1__c.contains('Engineer') ||
                   acc.Maint_Category_1__c.contains('Foundation') ||
                   acc.Maint_Category_1__c.contains('HVAC') ||
                   acc.Maint_Category_1__c.contains('Locks') ||
                   acc.Maint_Category_1__c.contains('Plumbing') ||
                   acc.Maint_Category_1__c.contains('Pest Control') ||
                   acc.Maint_Category_1__c.contains('Roofs') ||
                   acc.Maint_Category_1__c.contains('Chimneys') ||
                   acc.Maint_Category_1__c.contains('Tree Removal') ||
                   acc.Maint_Category_1__c.contains('Insulation') ||
                   acc.Maint_Category_1__c.contains('Windows')
                  )
                {
                    if(!requireDocsSet.contains('Certificate of Insurance - General Liability') && !uploadedDocs.contains('Certificate of Insurance - General Liability')){
                        requireDocsSet.add('Certificate of Insurance - General Liability');
                    }
                    /* Added new Markets - 5/07/2021 - Isaac A. Huicochea*/
                    if(String.isNotBlank(acc.Market__c))
                    {
                        if((acc.Type == 'Maintenance' || acc.Type == 'Rehab & Maintenance') && (acc.Market__c.contains('MEM') || acc.Market__c.contains('STL') || acc.Market__c.contains('BHM') || 
                                                     											acc.Market__c.contains('HSV') || acc.Market__c.contains('TUS') || acc.Market__c.contains('TLH') || 
                                                     											acc.Market__c.contains('JKT') || acc.Market__c.contains('JAN') || acc.Market__c.contains('CHA') || 
                                                     											acc.Market__c.contains('BNA')))
                        {
                            if(!requireDocsSet.contains('Insurance Agreement Premier') && !uploadedDocs.contains('Insurance Agreement Premier')){
                                requireDocsSet.add('Insurance Agreement Premier');
                            }
                        }
                        if((acc.Type == 'Maintenance' || acc.Type == 'Rehab & Maintenance') && (acc.Market__c.contains('DFW') || acc.Market__c.contains('SAN') ||
                                                                                                acc.Market__c.contains('HOU') || acc.Market__c.contains('LIT') ||
                                                                                                acc.Market__c.contains('OKC') || acc.Market__c.contains('TUL') ||
                                                                                                acc.Market__c.contains('AUS')))
                        {
                            if(!requireDocsSet.contains('Insurance Agreement PPMG TX') && !uploadedDocs.contains('Insurance Agreement PPMG TX')){
                                requireDocsSet.add('Insurance Agreement PPMG TX');
                            }
                            if(!requireDocsSet.contains('Hold Harmless Agreement PPMG TX') && !uploadedDocs.contains('Hold Harmless Agreement PPMG TX')){
                                requireDocsSet.add('Hold Harmless Agreement PPMG TX');
                            }
                        }
                    }
                    if(acc.Type == 'Rehab')
                    {
                        if(!requireDocsSet.contains('Insurance Agreement REI') && !uploadedDocs.contains('Insurance Agreement REI')){
                            requireDocsSet.add('Insurance Agreement REI');
                        }
                        if(!requireDocsSet.contains('Hold Harmless Agreement REI') && !uploadedDocs.contains('Hold Harmless Agreement REI')){
                            requireDocsSet.add('Hold Harmless Agreement REI');
                        }
                    }
                }
                if(acc.Maint_Category_1__c.contains('Appliances') || 
                   acc.Maint_Category_1__c.contains('Cages') ||
                   acc.Maint_Category_1__c.contains('Carpet') ||
                   acc.Maint_Category_1__c.contains('Cleaning') ||
                   acc.Maint_Category_1__c.contains('Concrete') ||
                   acc.Maint_Category_1__c.contains('Garage Doors') ||
                   acc.Maint_Category_1__c.contains('Gutters') ||
                   acc.Maint_Category_1__c.contains('Handyman') ||                   
                   acc.Maint_Category_1__c.contains('Countertops') ||
                   acc.Maint_Category_1__c.contains('Hardwoods') ||
                   acc.Maint_Category_1__c.contains('Misc') ||
                   acc.Maint_Category_1__c.contains('Move Outs') ||
                   acc.Maint_Category_1__c.contains('Rehab') ||
                   acc.Maint_Category_1__c.contains('Trash') ||
                   acc.Maint_Category_1__c.contains('Tub/Top Refinishing') ||
                   acc.Maint_Category_1__c.contains('Yard Crew') ||
                   acc.Maint_Category_1__c.contains('Chimneys') ||
                   acc.Maint_Category_1__c.contains('Tree Removal') ||
                   acc.Maint_Category_1__c.contains('Insulation') ||
                   acc.Maint_Category_1__c.contains('Windows')
                  ){              
                      if(acc.Type == 'Rehab & Maintenance' || acc.Type == 'Rehab')
                      {
                          if(!requireDocsSet.contains('Hold Harmless Agreement REI') && !uploadedDocs.contains('Hold Harmless Agreement REI')){
                              requireDocsSet.add('Hold Harmless Agreement REI');
                          }
                      }
                  }   
            } 
            
        }
        
        if(requireDocsSet.size() > 0){
            for(String reqDoc : requireDocsSet){
                contentVersionList.add(new ContentVersion(Attachment_Type__c = reqDoc));
            }
        }        
        
        if(contentVersionList.size() > 0){
            return contentVersionList;
        }
        
        return null;
    } 
    
    
    
    
    @AuraEnabled
    public static void updateFiles(List<ContentVersion> cvList ){
        update cvList;
    }
    
    @AuraEnabled
    public static List<Account> getAccount(Id recordId){
        List<Account> records = [SELECT Id, VendorApprovers__c FROM Account WHERE Id =: recordId];
        return records;
    }
}