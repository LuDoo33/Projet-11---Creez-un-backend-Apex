public with sharing class OrderTriggerHandler {

    // Méthode pour valider l'activation de la commande
    public static void validateOrderActivation(List<Order> orders) {
        Set<Id> orderIds = new Set<Id>();
        Set<Id> contractIds = new Set<Id>();

        for (Order order : orders) {
            if (order.Status == 'Active') {
                orderIds.add(order.Id);
                if (order.ContractId != null) {
                    contractIds.add(order.ContractId);
                }
            }
        }

        // RG-01 : Vérification que la commande a au moins un produit avant activation
        Map<Id, List<OrderItem>> orderItemMap = new Map<Id, List<OrderItem>>();
        for (OrderItem item : [SELECT OrderId FROM OrderItem WHERE OrderId IN :orderIds]) {
            if (!orderItemMap.containsKey(item.OrderId)) {
                orderItemMap.put(item.OrderId, new List<OrderItem>());
            }
            orderItemMap.get(item.OrderId).add(item);
        }

        // RG-02 : Vérification que le contrat associé est actif avant d'activer la commande
        Map<Id, Contract> contractMap = new Map<Id, Contract>([SELECT Id, Status FROM Contract WHERE Id IN :contractIds]);

        for (Order order : orders) {
            if (order.Status == 'Active') {
                // Vérification des produits
                if (!orderItemMap.containsKey(order.Id) || orderItemMap.get(order.Id).isEmpty()) {
                    order.addError('Vous ne pouvez pas activer une commande sans y associer au moins un produit.');
                }

                // Vérification du contrat
                if (order.ContractId != null) {
                    Contract contract = contractMap.get(order.ContractId);
                    if (contract == null) {
                        order.addError('Le contrat associé à cette commande est introuvable.');
                    } else if (contract.Status != 'Active') {
                        order.addError('Le contrat associé doit être actif pour activer cette commande.');
                    }
                } else {
                    order.addError('Aucun contrat n\'est associé à cette commande.');
                }
            }
        }
    }

    // Méthode après insertion : mettre à jour le champ Active__c sur l'Account associé
    public static void afterInsert(List<Order> orders) {
        Set<Id> accountIds = new Set<Id>();
        for (Order ord : orders) {
            if (ord.AccountId != null) {
                accountIds.add(ord.AccountId);
            }
        }

        // Mise à jour du champ Active__c de l'Account associé
        List<Account> accountsToUpdate = [SELECT Id, Active__c FROM Account WHERE Id IN :accountIds];
        for (Account acc : accountsToUpdate) {
            acc.Active__c = true; // Cocher la case Active__c
        }
        update accountsToUpdate;
    }

    // Méthode après suppression : mettre à jour le champ Active__c de l'Account associé
    public static void afterDelete(List<Order> orders) {
        Set<Id> accountIds = new Set<Id>();
        for (Order ord : orders) {
            if (ord.AccountId != null) {
                accountIds.add(ord.AccountId);
            }
        }

        // Vérification si un autre Order existe pour chaque Account et mise à jour de Active__c
        List<Account> accountsToUpdate = [SELECT Id, Active__c, (SELECT Id FROM Orders) FROM Account WHERE Id IN :accountIds];
        for (Account acc : accountsToUpdate) {
            if (acc.Orders.isEmpty()) { // Aucun autre Order rattaché à l'Account
                acc.Active__c = false; // Décocher la case Active__c
            }
        }
        update accountsToUpdate;
    }
}
