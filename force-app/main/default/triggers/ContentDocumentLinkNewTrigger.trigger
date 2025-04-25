trigger ContentDocumentLinkNewTrigger on ContentDocumentLink (before insert) {
    if(trigger.isBefore && trigger.isInsert){
        ContentDocumentLinkTriggerHandler.onBeforeInsert(trigger.new);
    }
}