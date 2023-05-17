public class PendingTasksWrapper {
	@AuraEnabled public List<Project_Task__c> tasks;
    @AuraEnabled public Boolean hasTasks;
    
    public PendingTasksWrapper(List<Project_Task__c> tasks, Boolean hasTasks){
        this.tasks = tasks;
        this.hasTasks = hasTasks;
    }
    
    @AuraEnabled(cacheable=true)
    public static PendingTasksWrapper getTasks(Id projectId){
        // Initialization of variables
        List<Project_Task__c> tasks = [SELECT Id, Summary__c, Estimated_Hours__c, Recorded_Hours__c, Status__c, Project_Resource__r.Resource__r.Name, Project_Resource__r.Project__c
                                       FROM Project_Task__c 
                                       WHERE Status__c != 'Completed' AND Project_Resource__r.Project__c = :projectId];
        Boolean hasTasks = false;
        if(tasks.size() > 0) hasTasks = true;	
        
        return new PendingTasksWrapper(tasks, hasTasks);
    }
}