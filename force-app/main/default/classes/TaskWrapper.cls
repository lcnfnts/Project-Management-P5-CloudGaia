public class TaskWrapper {
    
    public class TaskWrapperContainer{     
        @AuraEnabled public Project__c project;
        @AuraEnabled public List<Project_Task__c> tasks;
        @AuraEnabled public Integer projectPendingTasks;
        
        public TaskWrapperContainer(Project__c project, List<Project_Task__c> tasks, Integer pendingTasks){
            this.project = project;
            this.tasks = tasks;
            this.projectPendingTasks = pendingTasks;
        }
    }
    
    // List of projects with his uncompleted tasks
    @AuraEnabled public List<TaskWrapperContainer> projectWithTasks;
    @AuraEnabled public Boolean hasTasks;
    
    public TaskWrapper(List<TaskWrapperContainer> projectWithTasks, Boolean hasTasks){
        this.projectWithTasks = projectWithTasks;
        this.hasTasks = hasTasks;
    }
    
	@AuraEnabled(cacheable=true)
    public static TaskWrapper getTaskWrapper(){
        Id userId = UserInfo.getUserId();
        
        // All my assignments to projects
        List<Project_Resource__c> projectResources = [SELECT Id, Project__c, Start_Date__c, (SELECT Id, Summary__c, Status__c, Estimated_Hours__c, Recorded_Hours__c FROM Project_Tasks__r WHERE Status__c != 'Completed' ORDER BY Status__c DESC, Summary__c ASC)
                                                      FROM Project_Resource__c
                                                      WHERE Resource__c = :userId
                                                      ORDER BY Start_Date__c];
        
        // All my assignments where I have pending tasks.
        List<Project_Resource__c> projectResourcesWithTasks = new List<Project_Resource__c>();
        for(Project_Resource__c pr : projectResources){
            if(pr.Project_Tasks__r.size() > 0){
                projectResourcesWithTasks.add(pr);
            }
        }
        
        // Ids of the projects where I'm working and I have pending tasks.
        Set<Id> projectIds = new Set<Id>();
        for(Project_Resource__c pr : projectResourcesWithTasks){
            projectIds.add(pr.Project__c);
        }
        List<Project__c> projects = [SELECT Id, Name, Pending_Tasks__c FROM Project__c WHERE Id IN :projectIds];
        
        
        // Initialize my TaskWrapperContainer list.
        List<TaskWrapperContainer> taskWrapperList = new List<TaskWrapperContainer>();
        
        
        for(Project__c project : projects){
            List<Project_Task__c> projectTasks = new List<Project_Task__c>();
            for(Project_Resource__c pr : projectResourcesWithTasks){
                if(pr.Project__c == project.Id){
                    projectTasks.addAll(pr.Project_Tasks__r);
                }
            }   
            taskWrapperList.add(new TaskWrapperContainer(project, projectTasks, projectTasks.size()));
        }
        Boolean hasTasks = false;
        if(taskWrapperList.size() > 0){
            hasTasks = true;
        }
        return new TaskWrapper(taskWrapperList, hasTasks);
    } 
}