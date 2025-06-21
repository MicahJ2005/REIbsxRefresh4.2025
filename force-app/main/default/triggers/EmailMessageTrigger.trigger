// trigger EmailMessageTrigger on EmailMessage (after insert) {
//     boolean active = EmailToCaseAssignmentTrigger__mdt.getInstance('IsActive').Active__c;
//     system.debug('EmailToCaseAssignmentTrigger__mdt Active?'+ active);
//     if (Trigger.isAfter && Trigger.isInsert && active) {
//         EmailMessageHandler.processEmailMessages(Trigger.new);
//     }
// }

trigger EmailMessageTrigger on EmailMessage (after insert) {
    boolean active = EmailToCaseAssignmentTrigger__mdt.getInstance('IsActive').Active__c;
    System.debug('EmailToCaseAssignmentTrigger__mdt Active?' + active);

    if (Trigger.isAfter && Trigger.isInsert && active) {
        // Filter only inbound email messages
        List<EmailMessage> inboundEmails = new List<EmailMessage>();
        for (EmailMessage em : Trigger.new) {
            if (em.Incoming == true) {
                inboundEmails.add(em);
            }
        }

        if (!inboundEmails.isEmpty()) {
            EmailMessageHandler.processEmailMessages(inboundEmails);
        }
    }
}