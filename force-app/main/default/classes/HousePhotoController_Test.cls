@isTest
public class HousePhotoController_Test {
    
    @isTest
    public static void Test(){
        
        Account acc = new Account();
        acc.name = 'Test Acc' ;
        insert acc;
        
        ContentVersion cvl = new Contentversion(); 
        cvl.Title = 'Test Title'; 
        cvl.PathOnClient = 'PathOnTest'; 
        cvl.VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body');
        cvl.FirstPublishLocationId = acc.id;
        
        List<ContentVersion> cvlist = new List<ContentVersion>(); 
        cvlist.add(cvl); 
        insert cvlist;
		
        HousePhotoController.getConVersionList(acc.Id);
        HousePhotoController.updateFiles(cvlist);
        //(String fileName, String contentType, String data, String recordId, String photoType)
        //(string matterId,String photoType,Integer noOfFiles)
        HousePhotoController.getLastDoc(acc.Id,'Living Room',1);
        
    }
}