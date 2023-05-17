public class Project_Resource_Helper {
    public static void updateCompletedHours(List<Project_Resource__c> resources){
        // Getting the projects with their ProjectProducts related to the project resources modified.
		Set<Id> projectIds = new Set<Id>();
        for(Project_Resource__c pr : resources){
            projectIds.add(pr.Project__c);
        }
        List<Project__c> projectsInvolved = [SELECT Id, (SELECT Id, Role__c, Quantity__c, Completed_Hours__c FROM Project_Products__r) FROM Project__c WHERE Id in :projectIds];
        
        // Getting all the projectResources from the projects modified in order to count their completed hours by role.
        List<Project_Resource__c> projectResources = [SELECT Id, Role__c, Project__c, AssignedHours__c FROM Project_Resource__c WHERE Project__c in :projectsInvolved];
        
        // Map of Projects with their ProjectResources
        Map<Project__c, List<Project_Resource__c>> projectsWithResources = new Map<Project__c, List<Project_Resource__c>>();
        for(Project__c project : projectsInvolved){
            List<Project_Resource__c> projectResourcesOfTheProject = new List<Project_Resource__c>();
            for(Project_Resource__c pr : projectResources){
                if(pr.Project__c == project.Id){
                    projectResourcesOfTheProject.add(pr);
                }
            }
            projectsWithResources.put(project, projectResourcesOfTheProject);
        }
        
        // For each project and for each role of the project I count the hours of that role.
        List<Project_Product__c> ProjectProductsToUpdate = new List<Project_Product__c>();
        for(Project__c project : projectsWithResources.keySet()){
            for(Project_Product__c pp : project.Project_Products__r){
                Integer counter = 0;
            	for(Project_Resource__c presource : projectsWithResources.get(project)){        
                    if(pp.Role__c == presource.Role__c){ 
                        counter = counter + Integer.valueOf(presource.AssignedHours__c);
                        //pp.Completed_Hours__c = pp.Completed_Hours__c + presource.AssignedHours__c;
                    }
                }
				pp.Completed_Hours__c = counter; 
            }
            ProjectProductsToUpdate.addAll(project.Project_Products__r);            
        }
        
        update ProjectProductsToUpdate;   
    }
    
    public static void checkDatesRange(List<Project_Resource__c> projectResources){
        // en los resources me vienen los projectResources que intentan ser insertados.
        Set<Id> resourcesIds = new Set<Id>();
        for(Project_Resource__c pr : projectResources){
            if(!(pr.Start_Date__c > Date.today() && pr.Close_Date__c > pr.Start_Date__c)){
                throw new CustomDatesException('Start date must be after today and before the close date.');
            }            
            resourcesIds.add(pr.Resource__c);
        }
        
        List<User> users = [SELECT Id, Name, (SELECT Id, Project__c, Resource__c, Resource__r.Name, Start_Date__c, Close_Date__c, AssignedHours__c FROM Projects_Resources__r) FROM User WHERE Id in :resourcesIds];
       
        for(User u : users){
            for(Project_Resource__c prInsert : projectResources){
                // Si el usuario corresponde al usuario que se le quiere asignar el proyecto:
                if(u.Id == prInsert.Resource__c && u.Projects_Resources__r.size() > 0){
                    for(Project_Resource__c pr : u.Projects_Resources__r){
                    	// prInsert: el recurso que se quiere insertar - pr: el recurso que ya hay
                        // Significa que las fechas al menos se ingresaron bien. Valido que el usuario no este ocupado en ese rango de fechas
                        if((!(prInsert.Close_Date__c < pr.Start_Date__c || prInsert.Start_Date__c > pr.Close_Date__c)) && prInsert.Id != pr.Id){
                            throw new CustomDatesException('The resource ' + pr.Resource__r.Name + ' is booked between those dates.');                           
                        }
                    }                    
                }
            }
        }
    }
    
    public static void updateName(List<Project_Resource__c> projectResources){
        Set<Id> resourcesIds = new Set<Id>();
        for(Project_Resource__c pr : projectResources){
            resourcesIds.add(pr.Resource__c);
        }
        Map<Id, User> resourcesMap = new Map<Id, User>([SELECT Id, Name FROM User WHERE Id IN :resourcesIds]);
        
        for(Project_Resource__c pr : projectResources){
            String resourceName = '';
            if(resourcesMap.containsKey(pr.Resource__c)){
                resourceName = resourcesMap.get(pr.Resource__c).Name;
            }
            String newName = resourceName;
            pr.Name = newName;
        }
        
    }
}