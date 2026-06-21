@SuppressWarnings('PMD.ApexCRUDViolation,PMD.ApexDoc')

public with sharing class CTPersonController {

    public static String getToken(String mobile){
        Blob targetBlob = Blob.valueOf(mobile);
        Blob hash = Crypto.generateDigest('MD5', targetBlob);
        String result = EncodingUtil.base64Encode(hash);
        return result;
    }

    public static List<Person__c> getRecentHealthChanges() {
        return [SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c
        FROM Person__c 
        ORDER BY Status_Update_Date__c DESC NULLS LAST
        LIMIT 100];
    }

    public static List<Person__c> searchPeople(String searchTerm) {
        searchTerm = searchTerm+'%';
        return [SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c
        FROM Person__c
        WHERE Name LIKE :searchTerm OR Mobile__c LIKE :searchTerm OR Token__c LIKE :searchTerm
        ORDER BY Status_Update_Date__c DESC NULLS LAST ];  
    }

    public static Person__c getPersonById(String personId) {
        List<Person__c> personList = new List<Person__c>([SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c
        FROM Person__c
        WHERE Id=:personId]);
        if(personList != null && personList.size() > 0){
            return personList[0];
        }
        return null;
    }
}