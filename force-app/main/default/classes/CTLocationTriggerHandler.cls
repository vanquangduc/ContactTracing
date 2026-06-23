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
            if(location.Status__c != oldMap.get(location.Id).Status__c && location.Status__c == 'Red'){
                locationIds.add(location.Id);
            }
        }
      
        Set<Id> personIds = CTPersonController.getPeopleByLocations(locationIds, new List<String>{'Green','Yellow'});
        List<Person__c> peopleToUpdate = new List<Person__c>();
        for (Id per : personIds) {
            peopleToUpdate.add(
                new Person__c(
                    Id=per,
                    Health_Status__c='Yellow'
                )
            );
        }

        if(peopleToUpdate != null && peopleToUpdate.size() > 0){
            update peopleToUpdate;
        }
    }
}