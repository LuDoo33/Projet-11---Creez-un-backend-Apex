@isTest
public class TestDataFactoryTest {

    @isTest
    static void testCreateAccount() {
        // Test de la création d'un compte
        Account acc = TestDataFactory.createAccount('Test Account');
        System.assertNotEquals(null, acc.Id, 'Account should be created');
    }

    @isTest
    static void testCreateValidContract() {
        // Test de la création d'un contrat valide
        Account acc = TestDataFactory.createAccount('Test Account');
        Contract contract = TestDataFactory.createValidContract(acc.Id);
        System.assertNotEquals(null, contract.Id, 'Contract should be created');
    }

    @isTest
    static void testCreateProduct() {
        // Test de la création d'un produit
        Product2 product = TestDataFactory.createProduct('Test Product');
        System.assertNotEquals(null, product.Id, 'Product should be created');
    }

    @isTest
    static void testCreatePricebookEntry() {
        // Test de la création d'une entrée de Pricebook
        Product2 product = TestDataFactory.createProduct('Test Product');
        PricebookEntry pbe = TestDataFactory.createPricebookEntry(product.Id, 100.0);
        System.assertNotEquals(null, pbe.Id, 'PricebookEntry should be created');
    }

    @isTest
    static void testCreateOrder() {
        // Test de la création d'une commande
        Account acc = TestDataFactory.createAccount('Test Account');
        Contract contract = TestDataFactory.createValidContract(acc.Id);
        Order order = TestDataFactory.createOrder(acc.Id, contract.Id, 'Draft');
        System.assertNotEquals(null, order.Id, 'Order should be created');
    }

    @isTest
    static void testCreateOrderItem() {
        // Test de la création d'un élément de commande
        Account acc = TestDataFactory.createAccount('Test Account');
        Contract contract = TestDataFactory.createValidContract(acc.Id);
        Order order = TestDataFactory.createOrder(acc.Id, contract.Id, 'Draft');
        OrderItem orderItem = TestDataFactory.createOrderItem(order.Id, 100.0, 1);
        System.assertNotEquals(null, orderItem.Id, 'OrderItem should be created');
    }

    @isTest
    static void testCreateOrderWithItems() {
        // Test de la création d'une commande avec des éléments de commande
        Account acc = TestDataFactory.createAccount('Test Account');
        Contract contract = TestDataFactory.createValidContract(acc.Id);
        Product2 product = TestDataFactory.createProduct('Test Product');
        PricebookEntry pbe = TestDataFactory.createPricebookEntry(product.Id, 100.0);
        OrderItem orderItem = new OrderItem(
            UnitPrice = 100.0,
            Quantity = 1,
            PricebookEntryId = pbe.Id,
            Product2Id = product.Id
        );
        List<OrderItem> orderItems = new List<OrderItem>{orderItem};
        Order orderWithItems = TestDataFactory.createOrderWithItems(acc.Id, contract.Id, 'Draft', orderItems);
        System.assertNotEquals(null, orderWithItems.Id, 'Order with items should be created');
    }

    @isTest
    static void testPricebookCreation() {
        // Test de la création d'un Pricebook standard
        Product2 product = TestDataFactory.createProduct('Test Product');
        Test.startTest();
        PricebookEntry pbe = TestDataFactory.createPricebookEntry(product.Id, 100.0);
        Test.stopTest();
        System.assertNotEquals(null, pbe.Id, 'PricebookEntry should be created');
    }
}
