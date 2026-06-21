public with sharing class CTLocationTracingController {
    public static List<Location_Tracing__c> getVisitors(String locationId) {
        return [SELECT Id, Name, Person__c, Person__r.Name, Location__c,Location__r.Name,Visit_Date__c
        FROM Location_Tracing__c
        ORDER BY Visit_Date__c DESC];
    }

    public static List<Location_Tracing__c> getLocationsByPersonIds(Set<Id> personIds){
        return [SELECT Id, Name, Person__c, Person__r.Name, Location__c,Location__r.Name,Visit_Date__c
        FROM Location_Tracing__c
        WHERE Person__c IN :personIds AND Visit_Date__c >= :Date.today().addDays(-10)
        ORDER BY Visit_Date__c DESC];
    }
    /*
    Visit_Date__c >= :Date.today().addDays(-10) OR Visit_Date__c = LAST_N_DAYS:10
    */

    public static List<Location_Tracing__c> getLocationsByLocationsIds(Set<Id> locationIds) {
        return [SELECT Id, Name, Person__c, Person__r.Name, Person__r.Health_Status__c ,Location__c,Location__r.Name,Visit_Date__c
        FROM Location_Tracing__c
        WHERE Id IN :locationIds 
            AND Person__r.Health_Status__c = 'Green' 
            AND Visit_Date__c >= :Date.today().addDays(-10)
        ORDER BY Visit_Date__c DESC];
    }

    public static List<Location_Tracing__c> checkDuplicates(List<Location_Tracing__c> locationTraces) {
        // Get Location Ids and Person Ids from provided location traces list
        Set<Id> locationTraceIds = new Set<Id>();
        Set<Id> personIds = new Set<Id>();

        for(Location_Tracing__c trace : locationTraces){
            locationTraceIds.add(trace.Location__c);
            personIds.add(trace.Person__c);
        }

        // [Location1, {Person1, Person2}]
        Map<Id,Set<Id>> mapExistingRecord = new Map<Id,Set<Id>>();
        // Initialize value to store duplicate
        List<Location_Tracing__c> duplicatedList = new List<Location_Tracing__c>();

        List<Location_Tracing__c> existingRecord = new List<Location_Tracing__c>(
            [SELECT Id, Name, Location__c, Person__c
            FROM Location_Tracing__c
            WHERE Location__c IN :locationTraceIds AND Person__c IN :personIds]);

        
        if(existingRecord != null && existingRecord.size() > 0){
            //Loop through existing record to add value to map variable
            for(Location_Tracing__c trace : existingRecord){
                if(!mapExistingRecord.containsKey(trace.Location__c)){
                    mapExistingRecord.put(trace.Location__c, new Set<Id>());
                }

                mapExistingRecord.get(trace.Location__c).add(trace.Person__c);
            }

            // Loop through provided locationTraces to check
            // If the location contain in the existing records?
            // YES => Check if contain same person? => add to duplicates list
            // NO => Skip
            for(Location_Tracing__c trace : locationTraces){
                if(mapExistingRecord.containsKey(trace.Location__c) 
                && mapExistingRecord.get(trace.Location__c).contains(trace.Person__c)){
                    duplicatedList.add(trace);
                }
            }
        }

        return duplicatedList;
    }
}