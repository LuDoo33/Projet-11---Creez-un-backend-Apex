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
        Test.startTest();  // Démarre le test uniquement pour le bloc DML.
        try {
            update order;  // Tentative de mise à jour, cela devrait lever une exception
            System.assert(false, 'Expected exception not thrown');
        } catch (DmlException e) {
            // Si exception levée, on vérifie le message d'erreur
            System.assert(e.getMessage().contains('Vous ne pouvez pas activer une commande sans y associer au moins un produit.'), 'Unexpected error message');
        }

        // Ajouter un produit à la commande
        OrderItem orderItem = TestDataFactory.createOrderItem(order.Id, 100.0, 1);

        // Mettre à jour la commande pour l'activer
        order.Status = 'Active';
        update order;  // Mise à jour sans exception attendue cette fois

        // Vérifier que la commande est active
        order = [SELECT Status FROM Order WHERE Id = :order.Id];
        System.assertEquals('Active', order.Status);

        // Créer une commande avec un contrat inactif
        Contract inactiveContract = TestDataFactory.createValidContract(acc.Id);
        inactiveContract.Status = 'Inactive';
        update inactiveContract;
        Order orderWithInactiveContract = TestDataFactory.createOrder(acc.Id, inactiveContract.Id, 'Draft');
        orderWithInactiveContract.Status = 'Active';

        try {
            update orderWithInactiveContract;  // Mise à jour avec contrat inactif
            System.assert(false, 'Expected exception not thrown');
        } catch (DmlException e) {
            // Si exception levée, on vérifie le message d'erreur
            System.assert(e.getMessage().contains('Le contrat associé doit être actif pour activer cette commande.'), 'Unexpected error message');
        }
        Test.stopTest();  // Arrêter le test après la gestion de l'exception
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
