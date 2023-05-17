public class ProjectService {
    
	@AuraEnabled
    public static void addResources(Id projectId, String jsonResources){
        // A este método le llega un projectId y los recursos que se le van a asignar en formato JSON
		/*{	
			"Project__c":"a01Do0000175yFaIAI",
			"Resource__c":"005Do000001SUJEIA4",
			"Start_Date__c":"2023-04-21",
			"Close_Date__c":"2023-04-24",
			"AssignedHours__c":20
		}*/
        List<Project_Resource__c> projectResources = (List<Project_Resource__c>) JSON.deserializeStrict(jsonResources, List<Project_Resource__c>.class);
        insert projectResources;                         
    }
}