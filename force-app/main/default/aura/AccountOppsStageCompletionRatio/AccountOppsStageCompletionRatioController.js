({
    doInit : function(component, event, helper) {
        
        var opts = [
            { value: "Created Date", label: "Created Date" },
            { value: "Date Visited", label: "Date Visited" },
            { value: "Contract Accepted Date", label: "Contract Accepted Date" },
            { value: "Purchase Date", label: "Purchase Date" }
        ];
        
        component.set("v.options", opts);
        component.set("v.status","Basic Info");
        
        var action = component.get('c.getRelatedOpportunities');
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS") {
                component.set("v.objWrapper", response.getReturnValue());
                component.set("v.bucketOppList",component.get("v.objWrapper.oppList"));
            }else if (state === "INCOMPLETE") {
                // do something
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Error',
                            message: errors[0].message,
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    recordRedirect : function(component, event, helper) {
        var recordId = event.target.dataset.caseid;
        window.open('/' + recordId);  
    },
    
    onStatusChange:function(component,event,helper){
        var checkCmp = component.find("chkbox").get("v.value");
        if(checkCmp){
            component.set("v.status","List View");
            //component.set("v.objWrapper.oppList",component.get("v.bucketOppList"));
        }else{
            component.set("v.status","Basic Info");
        }
    },
    
    filterByDate : function(component, event, helper) {
        
        var filterValue = component.find("mySelect").get("v.value");
        var oppList = component.get("v.bucketOppList");
        
        var startDate = component.find("input1").get("v.value");
        var endDate = component.find("input2").get("v.value");
        
        var startDate = new Date(startDate);
        var endDate =  new Date(endDate);
        
        if(endDate != null && endDate != 'Invalid Date'){
            endDate.setDate(endDate.getDate() + 1);
        }
        
        var totalAssessments = 0;
        var totalContractedOpp = 0;
        var totalPurchasedOpp = 0;
        
        if(startDate != null && startDate != 'Invalid Date' && (endDate == null || endDate == 'Invalid Date')){
            if(filterValue == 'Created Date'){
                var serverListFilteredbyDate = oppList.filter(item => new Date(item.CreatedDate) >= startDate);  
                for(var i=0; i < serverListFilteredbyDate.length; i++){
                    if(serverListFilteredbyDate[i].Date_Visited__c){
                        totalAssessments ++;
                    }
                    if(serverListFilteredbyDate[i].Contract_Accepted_Date__c){
                        totalContractedOpp ++;
                    }
                    if(serverListFilteredbyDate[i].Contract_Closing_Date__c){
                        totalPurchasedOpp ++;
                    }
                }
                component.set("v.objWrapper.oppList",serverListFilteredbyDate);
                component.set("v.objWrapper.totalOpportunities",serverListFilteredbyDate.length);
                if(serverListFilteredbyDate.length > 0){
                    component.set("v.objWrapper.totalAssessmentOpportunities",totalAssessments);
                    component.set("v.objWrapper.assessmentByTotalOpp",((totalAssessments * 100) / serverListFilteredbyDate.length).toFixed(2));
                    component.set("v.objWrapper.totalContractedOpportunities",totalContractedOpp);
                    component.set("v.objWrapper.contractByAssessments",((totalContractedOpp / totalAssessments) * 100).toFixed(2));
                    component.set("v.objWrapper.contractByOpportunities",((totalContractedOpp / serverListFilteredbyDate.length) * 100).toFixed(2));
                    component.set("v.objWrapper.totalPurchasedOpportunities",totalPurchasedOpp);
                    component.set("v.objWrapper.contractedRatePurchase",((totalPurchasedOpp * 100) / serverListFilteredbyDate.length).toFixed(2));
                }
            }else if(filterValue == 'Date Visited'){
                var serverListFilteredbyDate = oppList.filter(item => new Date(item.Date_Visited__c) >= startDate);   
                for(var i=0; i < serverListFilteredbyDate.length; i++){
                    if(serverListFilteredbyDate[i].Date_Visited__c){
                        totalAssessments ++;
                    }
                    if(serverListFilteredbyDate[i].Contract_Accepted_Date__c){
                        totalContractedOpp ++;
                    }
                    if(serverListFilteredbyDate[i].Contract_Closing_Date__c){
                        totalPurchasedOpp ++;
                    }
                }
                component.set("v.objWrapper.oppList",serverListFilteredbyDate);
                component.set("v.objWrapper.totalOpportunities",serverListFilteredbyDate.length);
                if(serverListFilteredbyDate.length > 0){
                    component.set("v.objWrapper.totalAssessmentOpportunities",totalAssessments);
                    component.set("v.objWrapper.assessmentByTotalOpp",((totalAssessments * 100) / serverListFilteredbyDate.length).toFixed(2));
                    component.set("v.objWrapper.totalContractedOpportunities",totalContractedOpp);
                    component.set("v.objWrapper.contractByAssessments",((totalContractedOpp / totalAssessments) * 100).toFixed(2));
                    component.set("v.objWrapper.contractByOpportunities",((totalContractedOpp / serverListFilteredbyDate.length) * 100).toFixed(2));
                    component.set("v.objWrapper.totalPurchasedOpportunities",totalPurchasedOpp);
                    component.set("v.objWrapper.contractedRatePurchase",((totalPurchasedOpp * 100) / serverListFilteredbyDate.length).toFixed(2));
                }
            }else if(filterValue == 'Contract Accepted Date'){
                var serverListFilteredbyDate = oppList.filter(item => new Date(item.Contract_Accepted_Date__c) >= startDate);   
                for(var i=0; i < serverListFilteredbyDate.length; i++){
                    if(serverListFilteredbyDate[i].Date_Visited__c){
                        totalAssessments ++;
                    }
                    if(serverListFilteredbyDate[i].Contract_Accepted_Date__c){
                        totalContractedOpp ++;
                    }
                    if(serverListFilteredbyDate[i].Contract_Closing_Date__c){
                        totalPurchasedOpp ++;
                    }
                }
                component.set("v.objWrapper.oppList",serverListFilteredbyDate);
                component.set("v.objWrapper.totalOpportunities",serverListFilteredbyDate.length);
                if(serverListFilteredbyDate.length > 0){
                    component.set("v.objWrapper.totalAssessmentOpportunities",totalAssessments);
                    component.set("v.objWrapper.assessmentByTotalOpp",((totalAssessments * 100) / serverListFilteredbyDate.length).toFixed(2));
                    component.set("v.objWrapper.totalContractedOpportunities",totalContractedOpp);
                    component.set("v.objWrapper.contractByAssessments",((totalContractedOpp / totalAssessments) * 100).toFixed(2));
                    component.set("v.objWrapper.contractByOpportunities",((totalContractedOpp / serverListFilteredbyDate.length) * 100).toFixed(2));
                    component.set("v.objWrapper.totalPurchasedOpportunities",totalPurchasedOpp);
                    component.set("v.objWrapper.contractedRatePurchase",((totalPurchasedOpp * 100) / serverListFilteredbyDate.length).toFixed(2));
                }
            }else if(filterValue == 'Purchase Date'){
                var serverListFilteredbyDate = oppList.filter(item => new Date(item.Contract_Closing_Date__c) >= startDate);   
                for(var i=0; i < serverListFilteredbyDate.length; i++){
                    if(serverListFilteredbyDate[i].Date_Visited__c){
                        totalAssessments ++;
                    }
                    if(serverListFilteredbyDate[i].Contract_Accepted_Date__c){
                        totalContractedOpp ++;
                    }
                    if(serverListFilteredbyDate[i].Contract_Closing_Date__c){
                        totalPurchasedOpp ++;
                    }
                }
                component.set("v.objWrapper.oppList",serverListFilteredbyDate);
                component.set("v.objWrapper.totalOpportunities",serverListFilteredbyDate.length);
                component.set("v.objWrapper.totalAssessmentOpportunities",totalAssessments);
                component.set("v.objWrapper.assessmentByTotalOpp",((totalAssessments * 100) / serverListFilteredbyDate.length).toFixed(2));
                component.set("v.objWrapper.totalContractedOpportunities",totalContractedOpp);
                component.set("v.objWrapper.contractByAssessments",((totalContractedOpp / totalAssessments) * 100).toFixed(2));
                component.set("v.objWrapper.contractByOpportunities",((totalContractedOpp / serverListFilteredbyDate.length) * 100).toFixed(2));
                component.set("v.objWrapper.totalPurchasedOpportunities",totalPurchasedOpp);
                component.set("v.objWrapper.contractedRatePurchase",((totalPurchasedOpp * 100) / serverListFilteredbyDate.length).toFixed(2));
            }
        }else if((startDate == null || startDate == 'Invalid Date')  && endDate != null && endDate != 'Invalid Date'){
            if(filterValue == 'Created Date'){
                var serverListFilteredbyDate = oppList.filter(item => new Date(item.CreatedDate) < endDate);   
                for(var i=0; i < serverListFilteredbyDate.length; i++){
                    if(serverListFilteredbyDate[i].Date_Visited__c){
                        totalAssessments ++;
                    }
                    if(serverListFilteredbyDate[i].Contract_Accepted_Date__c){
                        totalContractedOpp ++;
                    }
                    if(serverListFilteredbyDate[i].Contract_Closing_Date__c){
                        totalPurchasedOpp ++;
                    }
                }
                component.set("v.objWrapper.oppList",serverListFilteredbyDate);
                component.set("v.objWrapper.totalOpportunities",serverListFilteredbyDate.length);
                component.set("v.objWrapper.totalAssessmentOpportunities",totalAssessments);
                component.set("v.objWrapper.assessmentByTotalOpp",((totalAssessments * 100) / serverListFilteredbyDate.length).toFixed(2));
                component.set("v.objWrapper.totalContractedOpportunities",totalContractedOpp);
                component.set("v.objWrapper.contractByAssessments",((totalContractedOpp / totalAssessments) * 100).toFixed(2));
                component.set("v.objWrapper.contractByOpportunities",((totalContractedOpp / serverListFilteredbyDate.length) * 100).toFixed(2));
                component.set("v.objWrapper.totalPurchasedOpportunities",totalPurchasedOpp);
                component.set("v.objWrapper.contractedRatePurchase",((totalPurchasedOpp * 100) / serverListFilteredbyDate.length).toFixed(2));
            }else if(filterValue == 'Date Visited'){
                var serverListFilteredbyDate = oppList.filter(item => new Date(item.Date_Visited__c) < endDate);   
                for(var i=0; i < serverListFilteredbyDate.length; i++){
                    if(serverListFilteredbyDate[i].Date_Visited__c){
                        totalAssessments ++;
                    }
                    if(serverListFilteredbyDate[i].Contract_Accepted_Date__c){
                        totalContractedOpp ++;
                    }
                    if(serverListFilteredbyDate[i].Contract_Closing_Date__c){
                        totalPurchasedOpp ++;
                    }
                }
                component.set("v.objWrapper.oppList",serverListFilteredbyDate);
                component.set("v.objWrapper.totalOpportunities",serverListFilteredbyDate.length);
                component.set("v.objWrapper.totalAssessmentOpportunities",totalAssessments);
                component.set("v.objWrapper.assessmentByTotalOpp",((totalAssessments * 100) / serverListFilteredbyDate.length).toFixed(2));
                component.set("v.objWrapper.totalContractedOpportunities",totalContractedOpp);
                component.set("v.objWrapper.contractByAssessments",((totalContractedOpp / totalAssessments) * 100).toFixed(2));
                component.set("v.objWrapper.contractByOpportunities",((totalContractedOpp / serverListFilteredbyDate.length) * 100).toFixed(2));
                component.set("v.objWrapper.totalPurchasedOpportunities",totalPurchasedOpp);
                component.set("v.objWrapper.contractedRatePurchase",((totalPurchasedOpp * 100) / serverListFilteredbyDate.length).toFixed(2));
            }else if(filterValue == 'Contract Accepted Date'){
                var serverListFilteredbyDate = oppList.filter(item => new Date(item.Contract_Accepted_Date__c) < endDate);   
                for(var i=0; i < serverListFilteredbyDate.length; i++){
                    if(serverListFilteredbyDate[i].Date_Visited__c){
                        totalAssessments ++;
                    }
                    if(serverListFilteredbyDate[i].Contract_Accepted_Date__c){
                        totalContractedOpp ++;
                    }
                    if(serverListFilteredbyDate[i].Contract_Closing_Date__c){
                        totalPurchasedOpp ++;
                    }
                }
                component.set("v.objWrapper.oppList",serverListFilteredbyDate);
                component.set("v.objWrapper.totalOpportunities",serverListFilteredbyDate.length);
                component.set("v.objWrapper.totalAssessmentOpportunities",totalAssessments);
                component.set("v.objWrapper.assessmentByTotalOpp",((totalAssessments * 100) / serverListFilteredbyDate.length).toFixed(2));
                component.set("v.objWrapper.totalContractedOpportunities",totalContractedOpp);
                component.set("v.objWrapper.contractByAssessments",((totalContractedOpp / totalAssessments) * 100).toFixed(2));
                component.set("v.objWrapper.contractByOpportunities",((totalContractedOpp / serverListFilteredbyDate.length) * 100).toFixed(2));
                component.set("v.objWrapper.totalPurchasedOpportunities",totalPurchasedOpp);
                component.set("v.objWrapper.contractedRatePurchase",((totalPurchasedOpp * 100) / serverListFilteredbyDate.length).toFixed(2));
            }else if(filterValue == 'Purchase Date'){
                var serverListFilteredbyDate = oppList.filter(item => new Date(item.Contract_Closing_Date__c) < endDate);   
                for(var i=0; i < serverListFilteredbyDate.length; i++){
                    if(serverListFilteredbyDate[i].Date_Visited__c){
                        totalAssessments ++;
                    }
                    if(serverListFilteredbyDate[i].Contract_Accepted_Date__c){
                        totalContractedOpp ++;
                    }
                    if(serverListFilteredbyDate[i].Contract_Closing_Date__c){
                        totalPurchasedOpp ++;
                    }
                }
                component.set("v.objWrapper.oppList",serverListFilteredbyDate);
                component.set("v.objWrapper.totalOpportunities",serverListFilteredbyDate.length);
                component.set("v.objWrapper.totalAssessmentOpportunities",totalAssessments);
                component.set("v.objWrapper.assessmentByTotalOpp",((totalAssessments * 100) / serverListFilteredbyDate.length).toFixed(2));
                component.set("v.objWrapper.totalContractedOpportunities",totalContractedOpp);
                component.set("v.objWrapper.contractByAssessments",((totalContractedOpp / totalAssessments) * 100).toFixed(2));
                component.set("v.objWrapper.contractByOpportunities",((totalContractedOpp / serverListFilteredbyDate.length) * 100).toFixed(2));
                component.set("v.objWrapper.totalPurchasedOpportunities",totalPurchasedOpp);
                component.set("v.objWrapper.contractedRatePurchase",((totalPurchasedOpp * 100) / serverListFilteredbyDate.length).toFixed(2));
            }
        } else if(startDate != null && endDate != null && startDate != 'Invalid Date' && endDate != 'Invalid Date'){
            if(startDate < endDate){
                if(filterValue == 'Created Date'){
                    var serverListFilteredbyDate = oppList.filter(item => new Date(item.CreatedDate) >= startDate && new Date(item.CreatedDate) < endDate );   
                    for(var i=0; i < serverListFilteredbyDate.length; i++){
                        if(serverListFilteredbyDate[i].Date_Visited__c){
                            totalAssessments ++;
                        }
                        if(serverListFilteredbyDate[i].Contract_Accepted_Date__c){
                            totalContractedOpp ++;
                        }
                        if(serverListFilteredbyDate[i].Contract_Closing_Date__c){
                            totalPurchasedOpp ++;
                        }
                    }
                    component.set("v.objWrapper.oppList",serverListFilteredbyDate);
                    component.set("v.objWrapper.totalOpportunities",serverListFilteredbyDate.length);
                    component.set("v.objWrapper.totalAssessmentOpportunities",totalAssessments);
                    component.set("v.objWrapper.assessmentByTotalOpp",((totalAssessments * 100) / serverListFilteredbyDate.length).toFixed(2));
                    component.set("v.objWrapper.totalContractedOpportunities",totalContractedOpp);
                    component.set("v.objWrapper.contractByAssessments",((totalContractedOpp / totalAssessments) * 100).toFixed(2));
                    component.set("v.objWrapper.contractByOpportunities",((totalContractedOpp / serverListFilteredbyDate.length) * 100).toFixed(2));
                    component.set("v.objWrapper.totalPurchasedOpportunities",totalPurchasedOpp);
                    component.set("v.objWrapper.contractedRatePurchase",((totalPurchasedOpp * 100) / serverListFilteredbyDate.length).toFixed(2));
                }else if(filterValue == 'Date Visited'){
                    var serverListFilteredbyDate = oppList.filter(item => new Date(item.Date_Visited__c) >= startDate && new Date(item.Date_Visited__c) < endDate );   
                    for(var i=0; i < serverListFilteredbyDate.length; i++){
                        if(serverListFilteredbyDate[i].Date_Visited__c){
                            totalAssessments ++;
                        }
                        if(serverListFilteredbyDate[i].Contract_Accepted_Date__c){
                            totalContractedOpp ++;
                        }
                        if(serverListFilteredbyDate[i].Contract_Closing_Date__c){
                            totalPurchasedOpp ++;
                        }
                    }
                    component.set("v.objWrapper.oppList",serverListFilteredbyDate);
                    component.set("v.objWrapper.totalOpportunities",serverListFilteredbyDate.length);
                    component.set("v.objWrapper.totalAssessmentOpportunities",totalAssessments);
                    component.set("v.objWrapper.assessmentByTotalOpp",((totalAssessments * 100) / serverListFilteredbyDate.length).toFixed(2));
                    component.set("v.objWrapper.totalContractedOpportunities",totalContractedOpp);
                    component.set("v.objWrapper.contractByAssessments",((totalContractedOpp / totalAssessments) * 100).toFixed(2));
                    component.set("v.objWrapper.contractByOpportunities",((totalContractedOpp / serverListFilteredbyDate.length) * 100).toFixed(2));
                    component.set("v.objWrapper.totalPurchasedOpportunities",totalPurchasedOpp);
                    component.set("v.objWrapper.contractedRatePurchase",((totalPurchasedOpp * 100) / serverListFilteredbyDate.length).toFixed(2));
                }else if(filterValue == 'Contract Accepted Date'){
                    var serverListFilteredbyDate = oppList.filter(item => new Date(item.Contract_Accepted_Date__c) >= startDate && new Date(item.Contract_Accepted_Date__c) < endDate );   
                    for(var i=0; i < serverListFilteredbyDate.length; i++){
                        if(serverListFilteredbyDate[i].Date_Visited__c){
                            totalAssessments ++;
                        }
                        if(serverListFilteredbyDate[i].Contract_Accepted_Date__c){
                            totalContractedOpp ++;
                        }
                        if(serverListFilteredbyDate[i].Contract_Closing_Date__c){
                            totalPurchasedOpp ++;
                        }
                    }
                    component.set("v.objWrapper.oppList",serverListFilteredbyDate);
                    component.set("v.objWrapper.totalOpportunities",serverListFilteredbyDate.length);
                    component.set("v.objWrapper.totalAssessmentOpportunities",totalAssessments);
                    component.set("v.objWrapper.assessmentByTotalOpp",((totalAssessments * 100) / serverListFilteredbyDate.length).toFixed(2));
                    component.set("v.objWrapper.totalContractedOpportunities",totalContractedOpp);
                    component.set("v.objWrapper.contractByAssessments",((totalContractedOpp / totalAssessments) * 100).toFixed(2));
                    component.set("v.objWrapper.contractByOpportunities",((totalContractedOpp / serverListFilteredbyDate.length) * 100).toFixed(2));
                    component.set("v.objWrapper.totalPurchasedOpportunities",totalPurchasedOpp);
                    component.set("v.objWrapper.contractedRatePurchase",((totalPurchasedOpp * 100) / serverListFilteredbyDate.length).toFixed(2));
                }else if(filterValue == 'Purchase Date'){
                    var serverListFilteredbyDate = oppList.filter(item => new Date(item.Contract_Closing_Date__c) >= startDate && new Date(item.Contract_Closing_Date__c) < endDate );   
                    for(var i=0; i < serverListFilteredbyDate.length; i++){
                        if(serverListFilteredbyDate[i].Date_Visited__c){
                            totalAssessments ++;
                        }
                        if(serverListFilteredbyDate[i].Contract_Accepted_Date__c){
                            totalContractedOpp ++;
                        }
                        if(serverListFilteredbyDate[i].Contract_Closing_Date__c){
                            totalPurchasedOpp ++;
                        }
                    }
                    component.set("v.objWrapper.oppList",serverListFilteredbyDate);
                    component.set("v.objWrapper.totalOpportunities",serverListFilteredbyDate.length);
                    component.set("v.objWrapper.totalAssessmentOpportunities",totalAssessments);
                    component.set("v.objWrapper.assessmentByTotalOpp",((totalAssessments * 100) / serverListFilteredbyDate.length).toFixed(2));
                    component.set("v.objWrapper.totalContractedOpportunities",totalContractedOpp);
                    component.set("v.objWrapper.contractByAssessments",((totalContractedOpp / totalAssessments) * 100).toFixed(2));
                    component.set("v.objWrapper.contractByOpportunities",((totalContractedOpp / serverListFilteredbyDate.length) * 100).toFixed(2));
                    component.set("v.objWrapper.totalPurchasedOpportunities",totalPurchasedOpp);
                    component.set("v.objWrapper.contractedRatePurchase",((totalPurchasedOpp * 100) / serverListFilteredbyDate.length).toFixed(2));
                }
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message: 'Start date cannot be greater than end date',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
        }
    }
})