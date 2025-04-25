global class SchVendorDocumentExpiryReminder implements Schedulable {
   global void execute(SchedulableContext sc) {
      VendorDocumentExpiryReminder b = new VendorDocumentExpiryReminder(); 
      database.executebatch(b);
   }
}