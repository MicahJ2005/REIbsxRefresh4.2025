global class SchVendorDocumentExpiredBatch implements Schedulable {
   global void execute(SchedulableContext sc) {
      VendorDocumentExpiredBatch b = new VendorDocumentExpiredBatch(); 
      database.executebatch(b);
   }
}