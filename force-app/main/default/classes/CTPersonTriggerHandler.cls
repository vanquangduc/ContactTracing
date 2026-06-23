public with sharing class CTPersonTriggerHandler {

    public static void beforeInsertHandler(List<Person__c> newList){
        for(Person__c person : newList){
            person.Health_Status__c = 'Green';
            person.Token__c=CTPersonController.getToken(person.Mobile__c);
        }
    }

    public static void beforeUpdateHandler(List<Person__c> newlist, Map<Id,Person__c> oldMap) {
        for(Person__c person : newlist){
            if(person.Health_Status__c != oldMap.get(person.Id).Health_Status__c &&
            Date.today() != oldMap.get(person.Id).Status_Update_Date__c){
                person.Status_Update_Date__c=Date.today();
            }
        }
    }

    public static void afterUpdateHandler(List<Person__c> newlist, Map<Id,Person__c> oldMap) {
        Set<Id> statusChange = new Set<Id>();
        Set<Id> redStatus = new Set<Id>();
        for(Person__c person : newlist){
            if(person.Health_Status__c != oldMap.get(person.Id).Health_Status__c){
                statusChange.add(person.Id);
            }

            if(person.Health_Status__c != oldMap.get(person.Id).Health_Status__c 
            && oldMap.get(person.Id).Health_Status__c != 'Red' 
            && person.Health_Status__c == 'Red'){
                redStatus.add(person.Id);
            }
        }

        Set<Id> alreadyProcessed = new Set<Id>();
        alreadyProcessed.addAll(redStatus);
        Set<Id> orangeStatus = new Set<Id>();
        Set<Id> yellowStatus = new Set<Id>();

        List<Person__c> personToUpdate = new List<Person__c>();

        orangeStatus.addAll(CTPersonController.getCohabitants(redStatus,alreadyProcessed));
        Set<Id> primaryContacts = CTPersonController.getPrimaryContact(redStatus,alreadyProcessed);
        orangeStatus.addAll(primaryContacts);
        yellowStatus.addAll(CTPersonController.getNeighbours(redStatus,alreadyProcessed));
        
        yellowStatus.addAll(CTPersonController.getSecondaryContact(primaryContacts,alreadyProcessed));

        for(Id pid : orangeStatus){
            personToUpdate.add(
                new Person__c(
                    Id=pid,
                    Health_Status__c = 'Orange'
                )
            );
        }

        for(Id pid : yellowStatus){
            personToUpdate.add(
                new Person__c(
                    Id=pid,
                    Health_Status__c = 'Yellow'
                )
            );
        }
        if(!personToUpdate.isEmpty()){
            update personToUpdate;
        }

        List<Location_Tracing__c> locationTraces = CTLocationTracingController.getLocationsByPersonIds(statusChange);
        if(locationTraces != null && locationTraces.size() > 0){
            Set<Id> locationIds = new Set<Id>();
            for (Location_Tracing__c locationTrace : locationTraces) {
                locationIds.add(locationTrace.Location__c);
            }
            CTLocationController.updateRedScore(locationIds);

        }
        
    }

   
}