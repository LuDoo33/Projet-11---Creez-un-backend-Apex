@isTest
public class OrderTriggerHandlerTest {

    @isTest
    static void testValidateOrderActivation() {
        // Créer un compte
        Account acc = TestDataFactory.createAccount('Test Account');
    
        // Créer un contrat actif
        Contract contract = TestDataFactory.createValidContract(acc.Id);
        contract.Status = 'Active';
        update contract;
    
        // Créer une commande sans produits
        Order order = TestDataFactory.createOrder(acc.Id, contract.Id, 'Draft');
    
        // Mettre à jour la commande pour l'activer
        order.Status = 'Active';
    
        Test.startTest();
    
        // Test de validation sans produit
        Database.SaveResult resultWithoutProduct = Database.update(order, false);
        Boolean errorFound = false;
    
        if (!resultWithoutProduct.isSuccess()) {
            for (Database.Error error : resultWithoutProduct.getErrors()) {
                System.debug('Erreur capturée (produit manquant) : ' + error.getMessage());
                if (error.getMessage().contains('Vous ne pouvez pas activer une commande sans y associer au moins un produit.')) {
                    errorFound = true;
                }
            }
        }
        
        System.assert(!resultWithoutProduct.isSuccess(), 'Erreur de validation attendue mais la mise à jour a reussi');
        System.assert(errorFound, 'Message d/erreur attendu non trouvé pour le produit manquant');
    
        // Ajouter un produit à la commande
        OrderItem orderItem = TestDataFactory.createOrderItem(order.Id, 100.0, 1);
    
        // Mettre à jour la commande pour l'activer
        order.Status = 'Active';
        update order;
    
        // Vérifier que la commande est active
        order = [SELECT Status FROM Order WHERE Id = :order.Id];
        System.assertEquals('Active', order.Status);
    
        // Créer une commande avec un contrat inactif
        Contract inactiveContract = TestDataFactory.createValidContract(acc.Id);
        inactiveContract.Status = 'Inactive';
        update inactiveContract;
        Order orderWithInactiveContract = TestDataFactory.createOrder(acc.Id, inactiveContract.Id, 'Draft');
        orderWithInactiveContract.Status = 'Active';
    
        // Test de validation avec contrat inactif
        Database.SaveResult resultInactiveContract = Database.update(orderWithInactiveContract, false);
        errorFound = false;
    
        if (!resultInactiveContract.isSuccess()) {
            for (Database.Error error : resultInactiveContract.getErrors()) {
                System.debug('Erreur capturée (contrat inactif) : ' + error.getMessage());
                if (error.getMessage().contains('Le contrat associé doit être actif pour activer cette commande.')) {
                    errorFound = true;
                }
            }
        }
    
        System.assert(!resultInactiveContract.isSuccess(), 'Erreur validation attendue mais la mise a jour a reussi');
        System.assert(errorFound, 'Message d/erreur attendu non trouve pour le contrat inactif');
    
        Test.stopTest();
    }
 
    @isTest
    static void testAfterInsert() {
        // Créer un compte
        Account acc = TestDataFactory.createAccount('Test Account');

        // Créer une commande
        Order order = TestDataFactory.createOrder(acc.Id, null, 'Draft');

        // Vérifier que le champ Active__c est mis à jour
        acc = [SELECT Active__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(true, acc.Active__c);
    }

    @isTest
    static void testAfterDelete() {
        // Créer un compte
        Account acc = TestDataFactory.createAccount('Test Account');

        // Créer une commande
        Order order = TestDataFactory.createOrder(acc.Id, null, 'Draft');

        // Supprimer la commande
        Test.startTest();
        delete order;
        Test.stopTest();

        // Vérifier que le champ Active__c est mis à jour
        acc = [SELECT Active__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(false, acc.Active__c);
    }
}
