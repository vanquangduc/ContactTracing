trigger ContactTriggerv2 on Contact (after insert, after update, after delete, after undelete) {
    switch on Trigger.operationType {
        when AFTER_INSERT{
            ContactTriggerHandlerv2.afterInsertHandler(Trigger.new);
        }

        when AFTER_UPDATE{
            ContactTriggerHandlerv2.afterUpdateHandler(Trigger.new, Trigger.oldMap);
        }

        when AFTER_DELETE{
            ContactTriggerHandlerv2.afterDeleteHandler(Trigger.old);
        }

        when AFTER_UNDELETE{
            ContactTriggerHandlerv2.afterUndeleteHandler(Trigger.new);
        }

    }

}