trigger EmailMessageTrigger on EmailMessage (after insert) {
    boolean active = EmailToCaseAssignmentTrigger__mdt.getInstance('IsActive').Active__c;
    system.debug('EmailToCaseAssignmentTrigger__mdt Active?'+ active);
    if (Trigger.isAfter && Trigger.isInsert && active) {
        EmailMessageHandler.processEmailMessages(Trigger.new);
    }
}