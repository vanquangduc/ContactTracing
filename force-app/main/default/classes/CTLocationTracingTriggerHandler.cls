public with sharing class CTLocationTracingTriggerHandler {
    public static void beforeInsertHandler(List<Location_Tracing__c> newList) {
        List<Location_Tracing__c> duplicateList = CTLocationTracingController.checkDuplicates(newList);
        if (!duplicateList.isEmpty()) {
            for (Location_Tracing__c record : duplicateList) {
                record.addError('Duplicate record found for the same location and date.');  
            }
        }   
    }
}