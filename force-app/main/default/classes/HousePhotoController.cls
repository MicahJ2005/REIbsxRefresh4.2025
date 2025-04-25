public class HousePhotoController {
    @AuraEnabled
    public static List<ContentVersion> getConVersionList (Id recordId){
        System.debug('recordId-------'+recordId);
        Set<Id> conDocIds = new Set<Id>();
        for(ContentDocumentLink cdLink: [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: recordId])
        {
            conDocIds.add(cdLink.ContentDocumentId);
        }
        
        return [SELECT Id, ContentDocumentId, Attachment_Type__c,Uploaded_Date__c, Expiration_Date__c, Title, Status__c 
                FROM ContentVersion WHERE ContentDocumentId =: conDocIds  And Photo_Type__c != null
                AND IsLatest = true ORDER BY ContentModifiedDate DESC];
    } 

    @AuraEnabled
    public static void updateFiles(List<ContentVersion> cvList ){
        update cvList;
    }
    
    /*
    @AuraEnabled
    public static Id saveImage(String fileName, String contentType, String data, String recordId, String photoType) {
        List<ContentDocumentLink> contentDocumentRecList = [Select Id,ContentDocumentId from ContentDocumentLink where 
                                                            LinkedEntityId =: recordId ];
        
        List<String> contentDocumentIdList = new List<String>();
        for(ContentDocumentLink contentDocRec  : contentDocumentRecList){
            contentDocumentIdList.add(contentDocRec.ContentDocumentId);
        }
        
        if(contentDocumentRecList.size()  > 0){
            List<ContentVersion> cvRecList = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN : contentDocumentIdList AND
                                              Photo_Type__c  =: photoType ];
            //system.assert(false,cvRecList);
            for(ContentVersion  cvRec : cvRecList){
                cvRec.Photo_Type__c  = '';
            }
            if(cvRecList.size() > 0){
                update cvRecList;
            }
        }
        
        system.debug('#### fileName - '+fileName+', contentType - '+contentType+', photoType - '+photoType );
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.VersionData = EncodingUtil.base64Decode(data);
        cv.Title = photoType;
        cv.PathOnClient = filename;
        cv.Photo_Type__c = photoType;
        cv.Uploaded_Date__c = Date.Today();
        
        insert cv;
        
        List<ContentVersion> cvReturned = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id ];
        
        System.debug('contentDocumentId='+cvReturned[0].ContentDocumentId);               
        if(!cvReturned.isEmpty()) {
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = cvReturned[0].ContentDocumentId;
            cdl.LinkedEntityId = recordId;
            cdl.ShareType = 'I';
            
            insert cdl;
        }
        return cv.Id;
    }
    */
    // 16 Dec
   @AuraEnabled
   public static String getLastDoc(string matterId,String photoType,Integer noOfFiles){
       set<id>setContentDocIds = new set<id>();
      //List<matterDocmentsWrapper> wrapList = new List<matterDocmentsWrapper>();
       
       for(ContentDocumentLink objCDL :[select id, ContentDocumentId, ShareType, LinkedEntityId from ContentDocumentLink where LinkedEntityId=:matterId]){
           setContentDocIds.add(objCDL.ContentDocumentId);
       }
       
       if(setContentDocIds.size()>0){
           list<ContentVersion> listCV= [Select id,Title,FirstPublishLocationId,versiondata,
                                         PathOnClient,ContentDocumentId,ContentModifiedDate,
                                        Description,SharingPrivacy,OwnerId from ContentVersion where ContentDocumentId In : setContentDocIds and isLatest = true order by ContentModifiedDate DESC LIMIT: noOfFiles];
           

           if(listCV.size() > 0){
               for(ContentVersion cv : listCV){
                   cv.Title = photoType;
                   cv.Photo_Type__c = photoType;
                   cv.Uploaded_Date__c = Date.today();
               }
               update listCv;
           }
       }
       
       return 'SUCCESS';
       
   }
    // 16 Dec
}