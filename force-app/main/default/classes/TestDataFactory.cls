public class TestDataFactory {

    // Méthode pour créer un enregistrement Account
    public static Account createAccount(String name) {
        Account acc = new Account(Name = name, Active__c = false);
        insert acc;
        return acc;
    }

    // Méthode pour créer un enregistrement Contract avec un statut valide
    public static Contract createValidContract(Id accountId) {
        Contract contract = new Contract(
            AccountId = accountId,
            Status = 'Draft', // Utiliser un statut valide par défaut
            StartDate = Date.today()
        );
        insert contract;
        return contract;
    }

    // Méthode pour créer un enregistrement Product
    public static Product2 createProduct(String name) {
        Product2 product = new Product2(Name = name, IsActive = true);
        insert product;
        return product;
    }

    // Méthode pour créer un enregistrement PricebookEntry
    public static PricebookEntry createPricebookEntry(Id productId, Decimal unitPrice) {
        // Récupérer l'ID du Pricebook standard
        Id pricebookId = Test.getStandardPricebookId();
        System.debug('Pricebook ID from Test.getStandardPricebookId(): ' + pricebookId);

        if (pricebookId == null) {
            // Si aucun Pricebook standard n'est trouvé, créer un Pricebook standard
            Pricebook2 standardPricebook = new Pricebook2(Name = 'Standard Pricebook', IsActive = true);
            insert standardPricebook;
            pricebookId = standardPricebook.Id;
            System.debug('Standard Pricebook created: ' + standardPricebook);
        }

        // Créer l'entrée de Pricebook pour le produit avec un prix standard
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = productId,
            UnitPrice = unitPrice,
            IsActive = true
        );
        insert pbe;

        return pbe;  // Retourne l'entrée du Pricebook
    }

    // Méthode pour créer un enregistrement Order
    public static Order createOrder(Id accountId, Id contractId, String status) {
        Order order = new Order(
            AccountId = accountId,
            ContractId = contractId,
            Status = status,
            EffectiveDate = Date.today(),
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert order;
        return order;
    }

    // Méthode pour créer un enregistrement OrderItem
    public static OrderItem createOrderItem(Id orderId, Decimal unitPrice, Integer quantity) {
        Product2 product = createProduct('Test Product');
        PricebookEntry standardPbe = createPricebookEntry(product.Id, unitPrice);
        OrderItem orderItem = new OrderItem(
            OrderId = orderId,
            UnitPrice = unitPrice,
            Quantity = quantity,
            PricebookEntryId = standardPbe.Id,
            Product2Id = product.Id
        );
        insert orderItem;
        return orderItem;
    }

    // Méthode pour créer un enregistrement Order avec des OrderItems
    public static Order createOrderWithItems(Id accountId, Id contractId, String status, List<OrderItem> orderItems) {
        Order order = new Order(
            AccountId = accountId,
            ContractId = contractId,
            Status = status,
            EffectiveDate = Date.today(),
            Pricebook2Id = Test.getStandardPricebookId()
        );

        // Insérer l'Order
        insert order;

        // Ajouter les OrderItems à l'Order en utilisant une relation parent-enfant
        for (OrderItem item : orderItems) {
            item.OrderId = order.Id;
        }

        // Insérer les OrderItems
        insert orderItems;

        return order;
    }
}
