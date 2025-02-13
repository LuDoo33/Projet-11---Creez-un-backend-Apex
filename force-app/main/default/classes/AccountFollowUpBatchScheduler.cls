global class AccountFollowUpBatchScheduler implements Schedulable {

    global void execute(SchedulableContext sc) {
        // Crée une nouvelle instance du batch et l'exécute
        Database.executeBatch(new AccountFollowUpBatch());
    }
}
