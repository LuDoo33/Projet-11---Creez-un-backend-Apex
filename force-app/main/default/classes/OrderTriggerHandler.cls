public with sharing class OrderTriggerHandler {

    // Méthode pour valider l'activation de la commande
    public static void validateOrderActivation(List<Order> orders) {
        for (Order order : orders) {
            // RG-01 : Vérification que la commande a au moins un produit avant activation
            if (order.Status == 'Active') {
                List<OrderItem> products = [SELECT Id FROM OrderItem WHERE OrderId = :order.Id];
                if (products.isEmpty()) {
                    order.addError('Vous ne pouvez pas activer une commande sans y associer au moins un produit.');
                }
            }

            // RG-02 : Vérification que le contrat associé est actif avant d'activer la commande
            if (order.Status == 'Active') {
                if (order.ContractId != null) {
                    // Requête pour récupérer le contrat associé à la commande
                    Contract contract = [SELECT Status FROM Contract WHERE Id = :order.ContractId LIMIT 1];
                    if (contract != null) {
                        // Si le contrat est inactif, on ajoute une erreur à la commande
                        if (contract.Status != 'Active') {
                            order.addError('Le contrat associé doit être actif pour activer cette commande.');
                        }
                    } else {
                        // Si aucun contrat n'est trouvé, on ajoute également une erreur
                        order.addError('Le contrat associé à cette commande est introuvable.');
                    }
                } else {
                    // Si aucun contrat n'est associé à la commande, on ajoute une erreur
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
