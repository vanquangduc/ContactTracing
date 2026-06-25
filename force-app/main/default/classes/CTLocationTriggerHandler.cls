public with sharing class CTLocationTriggerHandler {
    public static void beforeInsertHandler(List<Location__c> newList) {
        for(Location__c location : newList){
            location.Status__c = 'Green';
        }
    }

    public static void beforeUpdateHandler(List<Location__c> newList, Map<Id,Location__c> oldMap) {
        for(Location__c location : newList){
            if(location.Status__c != oldMap.get(location.Id).Status__c &&
            Date.today() != oldMap.get(location.Id).Status_Update_Date__c){
                location.Status_Update_Date__c = Date.today();
            }
        }
    }

    public static void afterUpdateHandler(List<Location__c> newList, Map<Id,Location__c> oldMap){
        Set<Id> locationIds = new Set<Id>();
        for(Location__c location : newList){
            if(oldMap.get(location.Id).Status__c != 'Red' && location.Status__c == 'Red'){
                locationIds.add(location.Id);
            }
        }
      
        List<Location_Tracing__c> locationTraces = CTLocationTracingController.getLocationsByLocationsIds(locationIds);
        List<Person__c> peopleToUpdate = new List<Person__c>();
        for (Location_Tracing__c trace : locationTraces) {
            peopleToUpdate.add(
                new Person__c(
                    Id=trace.Person__c,
                    Health_Status__c='Yellow'
                )
            );
        }

        if(peopleToUpdate != null && peopleToUpdate.size() > 0){
            update peopleToUpdate;
        }
    }
}