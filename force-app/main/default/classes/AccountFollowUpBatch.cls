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

        // Collecte les IDs des comptes à traiter
        for (Account acc : scope) {
            accountIds.add(acc.Id);
        }

        // RG-03 Vérifie les tâches existantes pour les comptes sélectionnés
        Map<Id, Task> existingTasks = new Map<Id, Task>();

        // Récupère toutes les tâches en une seule requête SOQL
        for (Task t : [SELECT Id, WhatId 
                       FROM Task 
                       WHERE WhatId IN :accountIds 
                       AND Subject = 'Call']) {
            existingTasks.put(t.WhatId, t);
        }

        List<Task> tasksToCreate = new List<Task>();

        // Crée des tâches seulement pour les comptes qui n'ont pas encore de tâche "Call"
        for (Account acc : scope) {
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

        // Si des tâches doivent être créées, les insérer
        if (!tasksToCreate.isEmpty()) {
            insert tasksToCreate;
        }
    }

    global void finish(Database.BatchableContext context) {
        // Actions post-traitement si nécessaire
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
