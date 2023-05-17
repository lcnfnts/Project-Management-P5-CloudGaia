public class Project_Task_Helper {
    public static void validateFields(List<Project_Task__c> projectTasks){

        // First we validate Close Date > Start Date and Estimated_Time > 0
        for(Project_Task__c pt : projectTasks){
            if(pt.Estimated_Hours__c <= 0){
                throw new TaskException('Estimated time must be greater than 0.');
            }else if(pt.Close_Date__c <= pt.Start_Date__c || pt.Start_Date__c < Date.today()){
                throw new TaskException('Start Date must be today or after today and before Close Date');
            }
        }
        
		// We get the project resources that are linked to the created or updated tasks.
        Set<Id> prIds = new Set<Id>();
        for(Project_Task__c pt : projectTasks){
            prIds.add(pt.Project_Resource__c);
        }
        List<Project_Resource__c> prs = [SELECT Id, Start_Date__c, Close_Date__c, AssignedHours__c,
                                         (SELECT Id, Estimated_Hours__c FROM Project_Tasks__r WHERE Status__c !='Completed')
                                         FROM Project_Resource__c WHERE Id IN :prIds];
        
        // We get the tasks that are before the trigger 
        
        for(Project_Resource__c pr : prs){
            // Sum completed hours for a project resource
            Integer completedHours = 0;
            for(Project_Task__c pt : projectTasks){
                if(pr.Id == pt.Project_Resource__c){
                    // Check the task is in the project resource time range.
                    if(!(pt.Start_Date__c >= pr.Start_Date__c && pt.Close_Date__c <= pr.Close_Date__c)){
                        throw new TaskException('Task date range must be in the Project Resource date range: ' + pr.Start_Date__c + ' - ' + pr.Close_Date__c);
                    }else{
                        // Here we should sum the amount of tasks completed hours and check if it's not greater 
                        if(pr.Project_Tasks__r.size()>0){
                            for(Project_Task__c actualPt : pr.Project_Tasks__r){
                                completedHours = completedHours + actualPt.Estimated_Hours__c.intValue();
                            }                            
                        }
                        if((pt.Estimated_Hours__c + completedHours) > pr.AssignedHours__c){
                            pt.addError('The project resource only has: ' + String.valueOf(pr.AssignedHours__c.intValue() - completedHours) + ' hours left.');
                            throw new TaskException('The project resource only has: ' + String.valueOf(pr.AssignedHours__c.intValue() - completedHours) + ' hours left.');
                        }
                    }
                }
            }
        }
    }
    
    public static void updateProjectResourceField(List<Project_Task__c> projectTasks){
        Set<Id> prIds = new Set<Id>();
        for(Project_Task__c pt : projectTasks){
            prIds.add(pt.Project_Resource__c);
        }
        
        List<Project_Resource__c> projectResources = [SELECT Id, Recorded_Hours__c, (SELECT Id, Recorded_Hours__c FROM Project_Tasks__r)
                                                      FROM Project_Resource__c WHERE ID in :prIds];
        
        if(projectResources.size() > 0){
            for(Project_Resource__c pr : projectResources){
                Integer hoursCounter = 0;
                for(Project_Task__c pt : pr.Project_Tasks__r){
                    if(pt.Recorded_Hours__c == null){
                        pt.Recorded_Hours__c = 0;
                    }
                    hoursCounter = hoursCounter + pt.Recorded_Hours__c.intValue();
                }
                pr.Recorded_Hours__c = hoursCounter;
            }
			update projectResources;            
        }
    }
}