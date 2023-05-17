public class SquadLeadProjectsWrapper {
	
    @AuraEnabled public List<Project__c> projects;
    @AuraEnabled public boolean hasProjects;
    
    public SquadLeadProjectsWrapper(List<Project__c> projects, boolean hasProjects){
        this.projects = projects;
        this.hasProjects = hasProjects;
    }
    
    @AuraEnabled(cacheable=true)
    public static SquadLeadProjectsWrapper getProjects(){
        
        Id userId = UserInfo.getUserId();
          //Id userId= '005Dp000000OgubIAC';
        List<Project_Resource__c> prs = [SELECT Id, Name, Resource__c, Project__c FROM Project_Resource__c WHERE Resource__c = :userId];
        
        Set<Id> projectIds = new Set<Id>();
        for(Project_Resource__c pr : prs){
            projectIds.add(pr.Project__c);
        }
        
        List<Project__c> projects = [SELECT Id, Name, Squad_Lead__c, Status__c FROM Project__c WHERE Id IN :projectIds AND Squad_Lead__c IN :prs AND Status__c = 'In Progress'];
        
        Boolean hasProjects = false;
        if(projects.size() > 0) {
            hasProjects = true;
        }
        return new SquadLeadProjectsWrapper(projects, hasProjects);
        
    }
}