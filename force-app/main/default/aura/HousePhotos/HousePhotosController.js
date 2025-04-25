({
    init : function(component, event, helper) {
        component.set('v.columns', [
            {label: 'Photo Type', fieldName: 'linkName', type: 'url', 
             typeAttributes: {label: { fieldName: 'Title' }, target: '_blank'}},
            {label: 'Uploaded Date', fieldName: 'Uploaded_Date__c', type: 'date-local'}
        ]);
        //helper.fetchAccountDetails(component, event, helper);
        helper.fetchContentVersions(component, event, helper);
    },
    handelActiveButton: function(cmp, event, helper){
        var photoType = cmp.get("v.homefile.Photo_Type__c");
        if(photoType != ''){
            cmp.set("v.activeButton", false);
        }else{
            cmp.set("v.activeButton", true);
        }
    },
    handleSaveEdition: function (cmp, event, helper) {
        var draftValues = event.getParam('draftValues');
        console.log(draftValues);
        var action = cmp.get("c.updateFiles");
        action.setParams({"cvList" : draftValues});
        action.setCallback(this, function(response) {
            var state = response.getState();
            $A.get('e.force:refreshView').fire();
            
        });
        $A.enqueueAction(action);
        
        document.location.reload(true);
    },
    handleUploadFinished : function(component, event, helper){
        var uploadedFiles = event.getParam("files");
        //alert(uploadedFiles.length);
        //component.set("v.PublishPopUp",true);
        
        var action = component.get("c.getLastDoc");
        
        action.setParams({
            'matterId':component.get("v.recordId"),
            'photoType':component.get("v.homefile.Photo_Type__c"),
            'noOfFiles': uploadedFiles.length
            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS") {
                var res = response.getReturnValue();
                //component.set("v.matterWrapperPublish",response.getReturnValue());
                if(res == 'SUCCESS'){
                    //alert('SUCCESS');
                    var a = component.get('c.init');
                    $A.enqueueAction(a);
                }
            }
        });
        $A.enqueueAction(action);
        
    },
    /*
    handleFilesChange : function (component, event,helper) {
        var files = event.getSource().get("v.files");
        console.log('picklist selected' + component.get("v.homefile.Photo_Type__c"));
        
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            console.log('All Files ', event.getSource().get("v.files"));
            fileName = event.getSource().get("v.files")[0]['name'];
            component.set("v.fileName", fileName);
        }
    },
    */
    /*
    doSave1: function(component, event, helper) {
        console.log('In Save');
        if(component.get("v.homefile.Photo_Type__c") == null || component.get("v.homefile.Photo_Type__c") == undefined
           || component.find("fileId").get("v.files") == null ||
           component.get("v.homefile.Photo_Type__c") == ''){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Please Select Both Photo Type AND FIle."
            });
            toastEvent.fire(); 
            
        } else if (component.find("fileId").get("v.files").length > 0) {
           
            if (component.find("fileId").get("v.files") != null && component.find("fileId").get("v.files").length > 0) {
                var file = component.find("fileId").get("v.files")[0];
                var sFileName = file['name'];
                //var fileType = event.getSource().getLocalId();
                //console.log("## fileType" + fileType + sFileName);
                var fileExtentions = component.get("v.acceptPhoto");
                var acceptedfileExtentions = component.get("v.acceptedFile");
                var blnValid = false;
                var fileValid = false;
                for (var j = 0; j < fileExtentions.length; j++) {
                    var sCurExtension = fileExtentions[j];
                    console.log("## sCurExtension " + sCurExtension);
                    if (sFileName.substr(sFileName.length - sCurExtension.length, sCurExtension.length).toLowerCase() == sCurExtension.toLowerCase()) {
                        blnValid = true;
                        break;
                    }
                    
                }
                
                for (var j = 0; j < acceptedfileExtentions.length; j++) {
                    console.log('sFileName' + sFileName);
                    var sCurExtension = acceptedfileExtentions[j];
                    if (sFileName.substr(sFileName.length - sCurExtension.length, sCurExtension.length).toLowerCase() == sCurExtension.toLowerCase()) {
                        fileValid = true;
                        break;
                    }
                    
                }
                
                if(fileValid) {  
                    
                    if (blnValid) {
                         component.set("v.showLoadingSpinner", true);
                        helper.uploadHelper(component, event, helper);
                    }
                    else{
                         component.set("v.showLoadingSpinner", true);
                        helper.uploadPDFFile(component, event, helper);
                    }
                } else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Only png; jpg; gif; tif; tiff; and pdf are accepted"
                    });
                    toastEvent.fire(); 
                }
                
            } 
            
            
            
            
            
            // helper.uploadHelper(component, event, helper);
        } else {
            alert('Please Select a Valid File');
        }
    }
    */
})