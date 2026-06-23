public with sharing class ContactTriggerHandler {
    public static void run(){
        updateActiveContact((List<Contact>)Trigger.new, (List<Contact>)Trigger.old, (Map<Id,Contact>)Trigger.oldMap, Trigger.operationType);

    }

    public static void updateActiveContact(
        List<Contact> newList,
        List<Contact> oldList,
        Map<Id,Contact> oldMap,
        System.TriggerOperation operationType
    ){
        Set<Id> accountIds = new Set<Id>();
        if(
            operationType == System.TriggerOperation.AFTER_DELETE){
            for(Contact con : oldList){
                if(con.AccountId != null){
                    accountIds.add(con.AccountId);
                }
            }
        }else if(operationType == System.TriggerOperation.AFTER_INSERT || operationType == System.TriggerOperation.AFTER_UNDELETE){
            for(Contact con : newList){
                if(con.AccountId != null){
                    accountIds.add(con.AccountId);
                }
            }
        }else if(operationType == System.TriggerOperation.AFTER_UPDATE){
             if(oldMap != null){
                for(Contact con : newList){
                    Contact oldCon = oldMap.get(con.Id);
                    if(oldCon.Active__c != con.Active__c || oldCon.AccountId != con.AccountId ){
                        if(oldCon.AccountId != null){
                            accountIds.add(oldCon.AccountId);
                        }

                        if(con.AccountId != null){
                            accountIds.add(con.AccountId);
                        }
                    }
                    
                }  
            }
        }

        if(accountIds.isEmpty()){
            return;
        }else{
            recalculateAccountCounts(accountIds);
        }
    }

    private static void recalculateAccountCounts(Set<Id> accountIds){
        Map<Id,Integer> countContactByAccounts = new Map<Id,Integer>();
        for(AggregateResult ar :[
            SELECT AccountId accountId,
            COUNT(Id) total
            FROM Contact
            WHERE AccountId IN :accountIds AND Active__c = true
            GROUP BY AccountId
        ]){
            countContactByAccounts.put((Id)ar.get('accountId'), (Integer)ar.get('total'));
        }

        // Not Optimize waste 2 SOQL and 1 DML
        /*
        Map<Id,Account> getAccountList = new Map<Id, Account>([SELECT Id, Active_Contacts__c FROM Account WHERE Id IN :accountIds]);

        for(Id id : countContactByAccounts.keySet()){
            getAccountList.get(id).Active_Contacts__c = countContactByAccounts.get(id);
        }

        update getAccountList.values();
        */

        List<Account> updateAccountList = new List<Account>();

        for(Id id : accountIds){
            updateAccountList.add(
                new Account(
                    Id = id,
                    Active_Contacts__c = countContactByAccounts.containsKey(id) ? countContactByAccounts.get(id) : 0
                )
            );
        }

        update updateAccountList;

    }

}