({
    MAX_FILE_SIZE: 4500000, //Max file size 4.5 MB 
    CHUNK_SIZE: 750000,      //Chunk Max size 750Kb 

    fetchContentVersions: function(component, event, helper) {
        var action = component.get("c.getConVersionList");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var records =response.getReturnValue();
                console.log('records---'+records);
                records.forEach(function(record){
                    record.linkName = '/lightning/r/ContentDocument/'+record.ContentDocumentId+'/view';
                });
                component.set("v.data", records);
            }
        });
        $A.enqueueAction(action);
	},
    
    
    uploadHelper: function(component, event, helper) {
        // create a FileReader object 
        if(component.get("v.homefile.Photo_Type__c") == null || component.get("v.homefile.Photo_Type__c") == undefined
           || component.find("fileId").get("v.files")[0] == null ){
           var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Error!",
                                "message": "Please Select Both Photo Type AND FIle."
                            });
                            toastEvent.fire(); 
            
        } else {
            var maxWidth = component.get("v.width");
        var maxHeight = component.get("v.height");
        //var file = event.getSource().get("v.files")[0];
        var file = component.find("fileId").get("v.files")[0];
        console.log('helper file - ', file);

        var objFileReader = new FileReader();
        // set onload function of FileReader object
        //objFileReader.readAsDataURL(file); 
        objFileReader.onload = $A.getCallback(function() {
            console.log('objFileReader - ', objFileReader);           
            var sx, sy, scale, p1,
                img     = document.createElement("img"),
                canvas  = document.createElement("canvas"),
                context = canvas.getContext("2d");
            img.src     = objFileReader.result;
            function getMeta() {
                img.onload = $A.getCallback(function() {
                    console.log('image - ',img);
                    console.log('image.width - ',img.width, '  - maxWidth - ', maxWidth);
                    console.log('image.height - ',img.height, '  - maxHeight - ', maxHeight);
                    if(img.width > maxWidth || img.height > maxHeight) {
                        console.log('if - ');
                        scale = Math.min(maxWidth/img.width, maxHeight/img.height);
                        sx    = Math.floor(img.width*scale);
                        sy    = Math.floor(img.height*scale);
                    } else {
                        console.log('else - ');
                        sx = img.width;
                        sy = img.height;
                    }
                    canvas.width = sx;
                    canvas.height = sy;
                    console.log('canvas - ', canvas);
                    context.drawImage(img, 0, 0, sx, sy);
                    console.log('context - ', context);
                    /* If we need high quality image, so quality factor can be increased 
                    * from 0.5 to 1.0 */
                    p1 = canvas.toDataURL(file.type, 1.0).match(/data:(.+);base64,(.+)/);
                    //p1 = canvas.toDataURL(file.type, 1.0).match(/data:(.+);base64,(.+)/);
                    console.log('p1 - ', p1);
                    
                    var action = component.get("c.saveImage");  
                    console.log('action 1 - ', action);
                    action.setParams({  
                        "fileName" : file.name,
                        "contentType" : file.type,
                        "data" : p1[2],
                        "recordId" : component.get("v.recordId"),
                        "photoType" : component.get("v.homefile.Photo_Type__c")
                    });
                    console.log('action 2 - ', action);
                    action.setCallback(this,function(response){ 
                        console.log('action 3 - ', response);
                        var state = response.getState();  
                        if(state=='SUCCESS'){    
                            
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Success!",
                                "message": "File has been uploaded successfully."
                            });
                            toastEvent.fire();
                            helper.fetchContentVersions(component, event, helper);
                            component.set("v.showLoadingSpinner", false);
                           $A.get('e.force:refreshView').fire();
                            
                        }  
                    });  
                    $A.enqueueAction(action);
                });
            }
            getMeta();
        });
 
        objFileReader.readAsDataURL(file);
        }
        
    }, 
    
    uploadPDFFile: function(component, event, helper){
         var file = component.find("fileId").get("v.files")[0];
    var reader = new FileReader();
        reader.onloadend = $A.getCallback(function() {
            var dataURL = reader.result;
            var content = dataURL.match(/,(.*)$/)[1];
            var action = component.get("c.saveImage");  
                    console.log('action 1 - ', action);
                    action.setParams({  
                        "fileName" : file.name,
                        "contentType" : file.type,
                        "data" : content,
                        "recordId" : component.get("v.recordId"),
                        "photoType" : component.get("v.homefile.Photo_Type__c")
                    });
                    console.log('action 2 - ', action);
                    action.setCallback(this,function(response){ 
                        console.log('action 3 - ', response);
                        var state = response.getState();  
                        if(state=='SUCCESS'){    
                            
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Success!",
                                "message": "File has been uploaded successfully."
                            });
                            toastEvent.fire();
                            helper.fetchContentVersions(component, event, helper);
                            component.set("v.showLoadingSpinner", false);
                           $A.get('e.force:refreshView').fire();
                            
                        }  
                    });  
                    $A.enqueueAction(action);
                
        });
        
        reader.readAsDataURL(file);
}

    
})