trigger ContactTrigger on Contact (after insert, after update, after delete, after undelete) {
    System.debug('Trigger Size: ' + Trigger.size);
    System.debug('Trigger Is Executing: ' + Trigger.isExecuting);
    System.debug('Operation Type ' + Trigger.operationType);
    
    ContactTriggerHandler.run();

}