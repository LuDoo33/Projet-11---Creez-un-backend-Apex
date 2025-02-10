@isTest
public class TestDataFactoryTest {

    @isTest
    static void testCreateAccount() {
        // Test de la création d'un compte
        Account acc = TestDataFactory.createAccount('Test Account');
        System.assertNotEquals(null, acc.Id, 'Account dois etre cree');
    }

    @isTest
    static void testCreateValidContract() {
        // Test de la création d'un contrat valide
        Account acc = TestDataFactory.createAccount('Test Account');
        Contract contract = TestDataFactory.createValidContract(acc.Id);
        System.assertNotEquals(null, contract.Id, 'Contrat dois etre cree');
    }

    @isTest
    static void testCreateProduct() {
        // Test de la création d'un produit
        Product2 product = TestDataFactory.createProduct('Test Product');
        System.assertNotEquals(null, product.Id, 'Produit dois etre cree');
    }

    @isTest
    static void testCreatePricebookEntry() {
        // Test de la création d'une entrée de Pricebook
        Product2 product = TestDataFactory.createProduct('Test Product');
        PricebookEntry pbe = TestDataFactory.createPricebookEntry(product.Id, 100.0);
        System.assertNotEquals(null, pbe.Id, 'PricebookEntry dois etre cree');
    }

    @isTest
    static void testCreateOrderWithItems() {
        // Créer un compte, un produit, et une entrée de Pricebook
        Account acc = TestDataFactory.createAccount('Test Account');
        Product2 product = TestDataFactory.createProduct('Test Product');
        PricebookEntry pbe = TestDataFactory.createPricebookEntry(product.Id, 100.0);
    
        // Créer des éléments de commande associés à la commande
        OrderItem orderItem = new OrderItem(
            UnitPrice = 100.0,
            Quantity = 1,
            PricebookEntryId = pbe.Id,
            Product2Id = product.Id
        );
    
        List<OrderItem> orderItems = new List<OrderItem>{orderItem};
    
        // Créer une commande avec les éléments de commande
        Order orderWithItems = TestDataFactory.createOrderWithItems(acc.Id, null, 'Draft', orderItems);
    
        // Vérifier que la commande a bien été créée avec des éléments
        System.assertNotEquals(null, orderWithItems.Id, 'Commandes avec produits dois être crees');
    
        // Vérifier que les éléments de commande sont bien associés à la commande
        List<OrderItem> createdOrderItems = [SELECT Id, OrderId FROM OrderItem WHERE OrderId = :orderWithItems.Id];
        System.assertEquals(orderItems.size(), createdOrderItems.size(), 'La commande doit contenir le nombre correct d/elements de commande');
    }
    
    @isTest
    static void testPricebookCreation() {
        // Test de la création d'un Pricebook standard
        Product2 product = TestDataFactory.createProduct('Test Product');
        Test.startTest();
        PricebookEntry pbe = TestDataFactory.createPricebookEntry(product.Id, 100.0);
        Test.stopTest();
        System.assertNotEquals(null, pbe.Id, 'PricebookEntry dois etre cree');
    }
}
