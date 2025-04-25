/**
 * @description       : 
 * @author            : 
 * @group             : 
 * @last modified on  : 02-18-2022
 * @last modified by  : Michael Lloyd (Demand Chain)
**/
public without sharing class ContentDocumentLinkTriggerHandler{
    
    public static void onBeforeInsert(List<ContentDocumentLink> cdlList){
        for(ContentDocumentLink cdl: cdlList){
            //commented and replaced with more specific logic
            //if(String.valueOf(cdl.LinkedEntityId).contains('001')){
            System.debug('LinkedEntityId: ' + cdl.LinkedEntityId);
            System.debug('shareType: ' + cdl.ShareType);
            System.debug('cdl: ' + cdl);
            Id linkedEntity = cdl.LinkedEntityId;
            if (linkedEntity.getSObjectType().getDescribe().getName() == 'Account') {
                cdl.ShareType = 'I';
            }
        }
    }
}