public with sharing class OrderTriggerHandler {

    // RG-01 : Vérifie qu'un Order possède au moins un produit pour passer en "Active"
    public static void validateOrderActivation(List<Order> orders) {
        Set<Id> orderIds = new Set<Id>();
        Set<Id> contractIds = new Set<Id>();

        // Collecte des IDs des commandes et des contrats pour les seules commandes actives
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
            // Vérification des produits associés
            Map<Id, AggregateResult> orderProductCounts = new Map<Id, AggregateResult>(
                [SELECT OrderId Id, COUNT(Id) recordCount 
                 FROM OrderItem 
                 WHERE OrderId IN :orderIds 
                 GROUP BY OrderId]
            );

            // Chargement des contrats associés
            Map<Id, Contract> contractMap = contractIds.isEmpty() ? 
                new Map<Id, Contract>() :
                new Map<Id, Contract>([SELECT Id, Status FROM Contract WHERE Id IN :contractIds]);

            // Vérification des conditions sur chaque commande active
            for (Order order : activeOrders.values()) {
                // Vérification des produits
                if (orderProductCounts.get(order.Id) == null) {
                    order.addError('Vous ne pouvez pas activer une commande sans y associer au moins un produit.');
                }

                // Vérification du contrat associé
                if (order.ContractId != null) {
                    Contract contract = contractMap.get(order.ContractId);
                    if (contract == null || contract.Status != 'Active') {
                        order.addError('Le contrat associé doit être actif pour activer cette commande.');
                    }
                } else {
                    order.addError('Aucun contrat n\'est associé à cette commande.');
                }
            }
        }
    }

    // RG-02 : Met à jour le champ Active__c après l'insertion d'une commande
    public static void afterInsert(List<Order> orders) {
        updateAccountActiveFlag(orders, true);
    }

    // Met à jour le champ Active__c après la suppression d'une commande
    public static void afterDelete(List<Order> orders) {
        updateAccountActiveFlag(orders, false);
    }

    // Mise à jour du champ Active__c sur le compte en fonction des commandes insérées ou supprimées
    private static void updateAccountActiveFlag(List<Order> orders, Boolean isInsert) {
        Set<Id> accountIds = new Set<Id>();
        for (Order order : orders) {
            if (order.AccountId != null) {
                accountIds.add(order.AccountId);
            }
        }

        if (!accountIds.isEmpty()) {
            List<Account> accountsToUpdate = [SELECT Id, Active__c FROM Account WHERE Id IN :accountIds];

            for (Account acc : accountsToUpdate) {
                if (isInsert) {
                    acc.Active__c = true;
                } else {
                    Integer orderCount = [SELECT COUNT() FROM Order WHERE AccountId = :acc.Id];
                    if (orderCount == 0) {
                        acc.Active__c = false;
                    }
                }
            }

            if (!accountsToUpdate.isEmpty()) {
                update accountsToUpdate;
            }
        }
    }
}
