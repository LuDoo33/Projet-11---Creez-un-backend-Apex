public with sharing class OrderTriggerHandler {

    // RG-01 : Vérifie qu'un Order possède au moins un produit pour passer en "Active"
    public static void validateOrderActivation(List<Order> orders) {
        Set<Id> orderIds = new Set<Id>();
        Set<Id> contractIds = new Set<Id>();  // Ajouter un Set pour collecter les IDs des contrats

        // Collecte des IDs des commandes et des contrats
        for (Order order : orders) {
            if (order.Status == 'Active') {
                orderIds.add(order.Id);
                if (order.ContractId != null) {
                    contractIds.add(order.ContractId);  // Ajouter l'ID du contrat pour la vérification
                }
            }
        }

        // Vérification des produits
        if (!orderIds.isEmpty()) {
            Map<Id, AggregateResult> orderProductCounts = new Map<Id, AggregateResult>(
                [SELECT OrderId Id, COUNT(Id) recordCount 
                 FROM OrderItem 
                 WHERE OrderId IN :orderIds 
                 GROUP BY OrderId]
            );

            // Si des contrats sont associés, chargez-les tous en une seule requête
            Map<Id, Contract> contractMap = new Map<Id, Contract>();
            if (!contractIds.isEmpty()) {
                contractMap = new Map<Id, Contract>([SELECT Id, Status FROM Contract WHERE Id IN :contractIds]);
            }

            // Vérification des conditions sur chaque commande
            for (Order order : orders) {
                if (order.Status == 'Active') {
                    // Vérification des produits
                    if (orderProductCounts.get(order.Id) == null) {
                        order.addError('Vous ne pouvez pas activer une commande sans y associer au moins un produit.');
                    }

                    // Vérification du contrat associé
                    if (order.ContractId != null) {
                        // Vérifie si le contrat existe dans le map et si son statut est "Active"
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
    }

    // RG-02 : Met à jour le champ Active__c après l'insertion d'une commande
    public static void afterInsert(List<Order> orders) {
        updateAccountActiveFlag(orders, true);
    }

    // RG-02 : Met à jour le champ Active__c après la suppression d'une commande
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
