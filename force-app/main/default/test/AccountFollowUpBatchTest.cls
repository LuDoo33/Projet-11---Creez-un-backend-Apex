@isTest
private class AccountFollowUpBatchTest {

    @isTest
    static void testBatchCreation() {
        // Utiliser TestDataFactory pour créer un compte
        Account acc = TestDataFactory.createAccount('Test Account');

        // Ajouter une tâche de type "Call" pour simuler une tâche existante
        Task existingTask = new Task(
            Subject = 'Call',
            WhatId = acc.Id,
            Status = 'Completed',
            Priority = 'Normal',
            ActivityDate = System.today()
        );
        insert existingTask;

        // Lancer le batch
        Test.startTest();
        AccountFollowUpBatch batch = new AccountFollowUpBatch();
        Database.executeBatch(batch, 1);  
        Test.stopTest();

        // Vérifier qu'aucune nouvelle tâche n'a été créée car une tâche "Call" existait déjà
        List<Task> tasks = [SELECT Id, Subject, WhatId FROM Task WHERE WhatId = :acc.Id];
        System.assertEquals(1, tasks.size(), 'Une tâche "Call" existe déjà pour le compte.');

        // Vérifier que la tâche est de type "Call"
        System.assertEquals('Call', tasks[0].Subject, 'Le sujet de la tâche doit être "Call"');
    }

    @isTest
    static void testNoTasksExisting() {
        // Utiliser TestDataFactory pour créer un compte
        Account testAccount = TestDataFactory.createAccount('Test Account');

        // Lancer le batch
        Test.startTest();
        AccountFollowUpBatch batch = new AccountFollowUpBatch();
        Database.executeBatch(batch);
        Test.stopTest();

        // Vérifier si une tâche a été créée
        List<Task> createdTasks = [SELECT Id, Status, Subject, WhatId FROM Task WHERE WhatId = :testAccount.Id];

        // S'assurer qu'une tâche a été créée
        System.assertEquals(1, createdTasks.size(), 'Une tâche de suivi doit être créée pour le compte');

        // Vérifier le statut de la tâche
        Task createdTask = createdTasks[0];
        System.assertEquals('Nouvelle', createdTask.Status, 'Le statut de la tâche doit être "Nouvelle"');
    }
}
