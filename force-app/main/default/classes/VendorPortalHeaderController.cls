global class VendorPortalHeaderController 
{
    global String profileImageUrl { get; set; }
    public String fileName { get; set; }
    public String file { get; set; }
    List<user> lstuser;
    public Boolean displayPopup {get;set;}
    
    global VendorPortalHeaderController () 
    {
        fileName = '';
        file = '';
        lstuser = [select FullPhotoURL from User where Id =: UserInfo.getUserId()];
        if(lstuser != NULL && !lstuser.isEmpty() && lstuser[0].FullPhotoURL != NULL ){
            profileImageUrl=lstuser[0].FullPhotoURL;
        }
        system.debug('profileImageUrl===========' + profileImageUrl);
    }
    
    public void upload() {
       
        List<Network> vendorCommunity = [SELECT Id, Name FROM Network WHERE Name = 'Vendor Portal'];
        Id communityId = vendorCommunity[0].Id;
        
        file = file.replace(System.URL.getSalesforceBaseURL().toExternalForm()+'/', '');
        
        ConnectApi.BinaryInput fileUpload = new ConnectApi.BinaryInput(EncodingUtil.base64Decode(file), 'image/jpg', fileName);  
        ConnectApi.Photo photoProfile =  ConnectApi.UserProfiles.setPhoto(communityId, UserInfo.getUserId(), fileUpload);
        
        lstuser = [select FullPhotoURL from User where Id =: UserInfo.getUserId()];
        if(lstuser != NULL && !lstuser.isEmpty() && lstuser[0].FullPhotoURL != NULL ){
            profileImageUrl=lstuser[0].FullPhotoURL;
        }
    }
}