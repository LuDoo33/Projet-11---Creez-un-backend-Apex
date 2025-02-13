@isTest
private class AccountFollowUpBatchTest {

    @isTest
    static void testBatchCreation() {
        // Préparer les données
        Account acc = new Account(Name = 'Test Account');
        insert acc;

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
        // Créer un compte sans ordre ni tâche existante
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        // Lancer le batch
        Test.startTest();
        AccountFollowUpBatch batch = new AccountFollowUpBatch();
        Id batchProcessId = Database.executeBatch(batch);
        Test.stopTest();
        
        // Vérifier si une tâche a été créée
        List<Task> createdTasks = [SELECT Id, Status, Subject, WhatId FROM Task WHERE WhatId = :testAccount.Id];
        
        // S'assurer qu'une tâche a été créée
        System.assertEquals(1, createdTasks.size(), 'Une tâche de suivi doit être créée pour le compte');
        
        // Vérifier le statut de la tâche
        Task createdTask = createdTasks[0];
        System.assertEquals('Nouvelle', createdTask.Status, 'Le statut de la tâche doit être "Nouvelle"');
    }

    @isTest
    static void testScheduledBatch() {
        Test.startTest();
        
        // Planification du batch avec une expression CRON correcte
        String cronExpression = '0 0 6 ? * 2#1 *'; // Premier lundi de chaque mois à 6h00
        String jobName = 'Account Follow-Up Batch Job';
    
        // Planification du job en utilisant la classe Scheduler
        AccountFollowUpBatchScheduler schedulerInstance = new AccountFollowUpBatchScheduler();
        System.schedule(jobName, cronExpression, schedulerInstance);
    
        Test.stopTest();
    
        // Vérification que la planification a bien été effectuée
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, State FROM CronTrigger WHERE CronJobDetail.Name = :jobName LIMIT 1];
        System.assertEquals(cronExpression, ct.CronExpression, 'L\'expression CRON ne correspond pas');
        System.assertEquals('WAITING', ct.State, 'Le job planifié n\'est pas dans l\'état attendu');
    }
}
