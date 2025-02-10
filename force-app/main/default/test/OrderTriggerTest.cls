@isTest
public class OrderTriggerTest {

    @isTest
    static void testBeforeUpdate() {
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
        try {
            update order;
            System.assert(false, 'Exception attendue non levée');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Vous ne pouvez pas activer une commande sans y associer au moins un produit.'), 'erreur non attendue');
        }
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
