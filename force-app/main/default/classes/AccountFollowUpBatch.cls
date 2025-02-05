global class AccountFollowUpBatch implements Database.Batchable<SObject>, Schedulable {

    global Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator([
            SELECT Id, Name, OwnerId 
            FROM Account 
            WHERE Id NOT IN (SELECT AccountId FROM Order) 
        ]);
    }

    global void execute(Database.BatchableContext context, List<Account> scope) {
        Set<Id> accountIds = new Set<Id>();

        for (Account acc : scope) {
            accountIds.add(acc.Id);
        }

        // Vérifie les tâches existantes pour les comptes sélectionnés - RG03
        Map<Id, Task> existingTasks = new Map<Id, Task>();
        for (Task t : [SELECT Id, WhatId 
                       FROM Task 
                       WHERE WhatId IN :accountIds 
                       AND Subject = 'Call']) {
            existingTasks.put(t.WhatId, t);
        }

        List<Task> tasksToCreate = new List<Task>();

        for (Account acc : scope) {
            // Crée une tâche uniquement si aucune tâche existante
            if (!existingTasks.containsKey(acc.Id)) {
                tasksToCreate.add(new Task(
                    Subject = 'Call',
                    Status = 'Nouvelle',
                    Priority = 'Normale',
                    OwnerId = acc.OwnerId,
                    WhatId = acc.Id,
                    ActivityDate = Date.today().addDays(5)
                ));
            }
        }

        if (!tasksToCreate.isEmpty()) {
            insert tasksToCreate;
        }
    }

    global void finish(Database.BatchableContext context) {
        // Actions post-traitement si besoin
    }

    // Planification du batch
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new AccountFollowUpBatch());
    }

    // Méthode pour programmer le batch avec une expression CRON
    public static void scheduleBatch() {
        String cronExpression = '0 0 6 ? * 2#1 *'; // Premier lundi de chaque mois à 6h00
        System.schedule('Account Follow-Up Batch', cronExpression, new AccountFollowUpBatch());
    }
}
