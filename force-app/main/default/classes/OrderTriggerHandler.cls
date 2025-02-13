public with sharing class OrderTriggerHandler {

    // RG-01 : Vérifie qu'un Order possède au moins un produit pour passer en "Active"
    public static void validateOrderActivation(List<Order> orders) {
        Set<Id> orderIds = new Set<Id>();
        Set<Id> contractIds = new Set<Id>();
        Map<Id, Order> activeOrders = new Map<Id, Order>();
 
        for (Order order : orders) {
            if (order.Status == 'Active') {
                orderIds.add(order.Id);
                activeOrders.put(order.Id, order);
                if (order.ContractId != null) {
                    contractIds.add(order.ContractId);
                }
            }
        }
 
        if (!orderIds.isEmpty()) {
            Map<Id, Integer> orderProductCountsMap = new Map<Id, Integer>();
            for (AggregateResult ar : [SELECT OrderId Id, COUNT(Id) recordCount 
                                       FROM OrderItem 
                                       WHERE OrderId IN :orderIds 
                                       GROUP BY OrderId]) {
                orderProductCountsMap.put((Id) ar.get('Id'), (Integer) ar.get('recordCount'));
            }
 
            Map<Id, Contract> contractMap = contractIds.isEmpty() ? 
                new Map<Id, Contract>() : 
                new Map<Id, Contract>([SELECT Id, Status FROM Contract WHERE Id IN :contractIds]);
 
            for (Order order : activeOrders.values()) {
                Integer productCount = orderProductCountsMap.get(order.Id);
                if (productCount == null || productCount == 0) {
                    order.addError('Vous ne pouvez pas activer une commande sans y associer au moins un produit.');
                }
 
                Contract contract = (order.ContractId != null) ? contractMap.get(order.ContractId) : null;
                if (contract == null) {
                    order.addError('Aucun contrat n\'est associé à cette commande.');
                } else if (contract.Status != 'Active') {
                    order.addError('Le contrat associé doit être actif pour activer cette commande.');
                }
            }
        }
    }
 
    // RG-02 : Met à jour le champ Active__c après l'insertion d'une commande
    public static void updateAccountAfterInsert(List<Order> orders) {
        updateAccountActiveFlag(orders, true);
    }
 
    // Met à jour le champ Active__c après la suppression d'une commande
    public static void updateAccountAfterDelete(List<Order> orders) {
        updateAccountActiveFlag(orders, false);
    }
 
    private static void updateAccountActiveFlag(List<Order> orders, Boolean isInsert) {
        Set<Id> accountIds = new Set<Id>();
        for (Order order : orders) {
            if (order.AccountId != null) {
                accountIds.add(order.AccountId);
            }
        }
 
        if (!accountIds.isEmpty()) {
            List<Account> accountsToUpdate = [SELECT Id, Active__c FROM Account WHERE Id IN :accountIds];
            Map<Id, Account> accountMap = new Map<Id, Account>(accountsToUpdate);
 
            Map<Id, AggregateResult> orderCounts = new Map<Id, AggregateResult>(
                [SELECT AccountId Id, COUNT(Id) orderCount
                 FROM Order
                 WHERE AccountId IN :accountIds
                 GROUP BY AccountId]
            );
 
            for (Account acc : accountMap.values()) {
                Integer orderCount = (orderCounts.containsKey(acc.Id)) ?
                    (Integer) orderCounts.get(acc.Id).get('orderCount') : 0;
 
                acc.Active__c = (isInsert || orderCount > 0);
            }
 
            if (!accountsToUpdate.isEmpty()) {
                update accountsToUpdate;
            }
        }
    }
 }
 