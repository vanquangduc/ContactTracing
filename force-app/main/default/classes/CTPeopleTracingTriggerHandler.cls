public with sharing class CTPeopleTracingTriggerHandler {
    public static void beforeInsertHandler(List<People_Tracing__c> newList) {
        List<People_Tracing__c> duplicates = CTPeopleTracingController.checkDuplicates(newList);
        if (!duplicates.isEmpty()) {
            // Handle duplicates
            for (People_Tracing__c duplicate : duplicates) {
                duplicate.addError('Duplicate record found for Person 1 and Person 2 combination.');
            }
        }
    }
}