public class ProjectWrapper {
    
    public class Requirements{
        public Requirements(Project_Product__c pp, List<User> u){
            projectProduct = pp;
            users = u;
        }
        @AuraEnabled
        public Project_Product__c projectProduct;
        @AuraEnabled
        public List<User> users;
    }
    @AuraEnabled
    public Boolean hasRequirements;
    @AuraEnabled
    public Boolean economicStatus;
    @AuraEnabled
    public Boolean isInKickoff;
    @auraEnabled
    public Project__c project;
    @auraEnabled
    public List<Requirements> requirementList;
    
    public ProjectWrapper (Project__c Project, List<Requirements> requirements, Boolean hasRequirements, Boolean economicStatus, Boolean isInKickoff){
        this.project = project;
        this.requirementList = requirements;
        this.hasRequirements = hasRequirements;
        this.economicStatus = economicStatus;
        this.isInKickoff = isInKickoff;
    }      	 


    @AuraEnabled(cacheable=true)
    public static ProjectWrapper getProject (Id projectId) {
        
        List<Requirements> requirementList = new List<Requirements>();
        
        // Information related to the project.
        Project__c project = [SELECT Id, Name, Amount__c, Client__c, Close_Date__c, Start_Date__c, Cost__c, Status__c, Economic_Status__c
                              FROM Project__c WHERE Id = :projectId];
        
        Boolean economicStatus = false;
        if(project.Cost__c <= project.Amount__c){
           economicStatus = true;
        }
        
        Boolean isInKickoff = false;
        if(project.Status__c == 'Pre-Kickoff'){
            isInKickoff = true;
        }
        
        
        // Project products of the project.
        List<Project_Product__c> allProjectProducts = [SELECT Id, Project__c, Quantity__c, Amount__c, Role__c, Completed_Hours__c 
													FROM Project_Product__c 
                                                    WHERE Project__c = :projectId];
        
        List<Project_Product__c> projectProducts = new List<Project_Product__c>();
        for(Project_Product__c pp : allProjectProducts){          
            if(pp.Quantity__c > pp.Completed_Hours__c){
                projectProducts.add(pp);
            }
        }
        System.debug(projectProducts);
        
        // Roles required in the project.
        Set<String> rolesNames = new Set<String>();
        for(Project_Product__c pp : projectProducts){
            rolesNames.add(pp.Role__c);
        }
        
        // Resources with the role required for the project.
        List<User> resourcesWithRoles = [SELECT Id, Name, Rate__c, UserRole.Name FROM User WHERE UserRole.Name IN :rolesNames];    
        Set<Id> possibleResources = new Set<Id>();
        for(User u : resourcesWithRoles){
            possibleResources.add(u.Id);
        }
        
        // Users which will NOT be available for resource in the project because they have that date range booked
        List<Project_Resource__c> projectResources = [SELECT Id, Resource__c, Start_Date__c, Close_Date__c 
                                                      FROM Project_Resource__c WHERE Resource__c IN :possibleResources];

        Set<Id> projectResourcesNotAvailable = new Set<Id>();
        for(Project_Resource__c pr : projectResources){
            if(pr.Start_Date__c < project.Start_Date__c && pr.Close_Date__c > project.Start_Date__c ||
               pr.Start_Date__c < project.Close_Date__c && pr.Close_Date__c > project.Close_Date__c ||
               pr.Start_Date__c == project.Start_Date__c && pr.Close_Date__c == project.Close_Date__c||
               pr.Start_Date__c < project.Start_Date__c && pr.Close_Date__c > project.Close_Date__c){
               	 projectResourcesNotAvailable.add(pr.Resource__c);
               }
        }
        
        List<User> usersAvailable = [SELECT Id, Name, Rate__c, UserRole.Name FROM User
                                    WHERE UserRole.Name IN :rolesNames AND ID NOT IN :projectResourcesNotAvailable];
        
        Map<String, List<User>> productsWithUsers = new Map<String, List<User>>();
        for(Project_Product__c pp : projectProducts){
            List<User> usersWithRoleOfPP = new List<User>();
            for(User u : usersAvailable){
                if(u.UserRole.Name == pp.Role__c){
                    usersWithRoleOfPP.add(u);
                }
            }
            Requirements r = new Requirements(pp, usersWithRoleOfPP);
            requirementList.add(r);
        }
        Boolean hasRequirements = false;
        if(requirementList.size() > 0){
           hasRequirements = true;
        }
        
        ProjectWrapper wrapper = new ProjectWrapper(project, requirementList, hasRequirements, economicStatus, isInKickoff);
        return wrapper;
    }
}