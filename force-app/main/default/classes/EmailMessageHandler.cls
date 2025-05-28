public class EmailMessageHandler {
    public static void processEmailMessages(List<EmailMessage> emailMessages) {
        // Map to hold email addresses to look up
        Set<String> emailSet = new Set<String>();

        // Map of EmailMessage Id to Related CaseId
        Map<string, Set<String>> caseIdToEmailMap = new Map<string, Set<String>>();
        Map<string, string> emailToCaseIdMap = new Map<string, string>();

        for (EmailMessage em : emailMessages) {
            if (em.ParentId != null && String.valueOf(em.ParentId).startsWith('500')) { // Case Ids start with '500'
                

                // Add ToAddress and CcAddress emails to the set
                emailSet.addAll(parseEmailAddresses(em.ToAddress));
                emailSet.addAll(parseEmailAddresses(em.CcAddress));
                caseIdToEmailMap.put(em.ParentId, emailSet);
                for(string s : emailSet) {
                    emailToCaseIdMap.put(s, em.ParentId);
                }
            }
        }

        if (emailSet.isEmpty()) {
            return;
        }


        // Get related cases
        Map<string, Contact> emailToContactMap = new Map<string, Contact>();
        // Query Contacts that match these emails and are Investors
        for(Contact c: [
                    SELECT Id, Name, Email, Type__c,
                            AccountId, Account.Customer_Service_Assignment__c
                    FROM Contact
                    WHERE Email IN :emailToCaseIdMap.keySet()
                    AND Type__c = 'Investor'
                ]){
                    emailToContactMap.put(c.Email.toLowerCase(), c);
                }



        Set<Id> caseRecordTypeIds = new Set<Id>();

        for (RecordType rt : [
            SELECT Id 
            FROM RecordType 
            WHERE SobjectType = 'Case' 
            AND DeveloperName IN ('Customer_Service', 'Email_to_Case')
        ]) {
            caseRecordTypeIds.add(rt.Id);
        }

        List<Case> relatedCaseList = [SELECT Id, ContactId, AccountId, OwnerId
                                    FROM Case 
                                    WHERE Id 
                                    IN :emailToCaseIdMap.values()
                                    AND RecordTypeId IN: caseRecordTypeIds];

        List<Case> casesToupdate  = new List<Case>();
        
        User blake = [SELECT Id FROM User WHERE Name = 'Blake Clothier' AND IsActive = true LIMIT 1];
       
        if(relatedCaseList.size() > 0) {
            for(Case c : relatedCaseList) {
                for(string email: caseIdToEmailMap.get(c.Id)) {
                    if(emailToContactMap.containsKey(email.toLowerCase())){
                        c.ContactId = emailToContactMap.get(email.toLowerCase()).Id;
                        c.AccountId = emailToContactMap.get(email.toLowerCase()).AccountId;
                        if(emailToContactMap.get(email.toLowerCase()).Account.Customer_Service_Assignment__c!=null){
                            c.OwnerId = emailToContactMap.get(email.toLowerCase()).Account.Customer_Service_Assignment__c;
                        }
                        else{
                            /// default for any case that does not have a related Custom Service Assignment
                             c.OwnerId = blake.Id;
                        }
                        
                        casesToupdate.add(c);
                    }
                }
            }
        }
     
        system.debug('casesToupdate: '+ casesToupdate);
        if(casesToupdate.size() > 0) {
            update casesToupdate;
        }
    }

    private static List<String> parseEmailAddresses(String addresses) {
        List<String> cleaned = new List<String>();
        if (String.isBlank(addresses)) return cleaned;

        for (String email : addresses.split(';')) {
            email = email.trim();
            if (!String.isBlank(email)) {
                cleaned.add(email.toLowerCase());
            }
        }
        return cleaned;
    }
}