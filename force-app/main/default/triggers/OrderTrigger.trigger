trigger OrderTrigger on Order (before update, after insert, after delete) {
    
    // Avant mise à jour : validation des commandes avant activation
    if (Trigger.isBefore && Trigger.isUpdate) {
        OrderTriggerHandler.validateOrderActivation(Trigger.new);
    }

    // Après insertion : mettre à jour l'Account associé (champ Active__c)
    if (Trigger.isAfter && Trigger.isInsert) {
        OrderTriggerHandler.updateAccountAfterInsert(Trigger.new);
    }

    // Après suppression : mettre à jour l'Account associé
    if (Trigger.isAfter && Trigger.isDelete) {
        OrderTriggerHandler.updateAccountAfterDelete(Trigger.old);
    }
}
