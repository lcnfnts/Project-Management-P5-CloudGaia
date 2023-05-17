@isTest
public class Test_SquadLeadProjectsWrapper {

    @isTest
    static void testgetProjects(){
        
        Id u = userinfo.getUserId();
        //Id u= '005Dp000000OgubIAC';
        Project__c p1 = new Project__c(Start_Date__c = Date.today(),
                                       Close_Date__c = Date.today().addDays(7),
                                       Status__c = 'Pre-Kickoff'
                                       );
        
        insert p1;
        
  
        Project_Resource__c pr1 =  new Project_Resource__c(
            Project__c = p1.Id,
            Resource__c = u,
            AssignedHours__c = 20,
            Start_Date__c = Date.today().addDays(3),
            Close_Date__c = Date.today().addDays(6)
        );
        
        insert pr1;
        
        p1.Squad_Lead__c = pr1.Id;
        update p1;
        p1.Status__c = 'In Progress';
        update p1;
        
        
        //List<Project_Resource__c> resources = [SELECT id, Project__c, Name, Resource__c FROM Project_Resource__c WHERE Resource__c =:u];
        //List<Project__c> projects = [SELECT id, Squad_Lead__c FROM Project__c WHERE id =:p1.Id];
        
          
        
        Test.startTest();
        SquadLeadProjectsWrapper wrapper = SquadLeadProjectsWrapper.getProjects();
        System.debug(u);
        System.debug(pr1);
        System.debug(p1);
        System.debug(wrapper);
        
        Test.stopTest();
        
        //System.assertEquals(pr1.id, wrapper.projects[0].Squad_Lead__c, 'ss');
        System.assertEquals(1, wrapper.projects.size(), 'Expected to have 1 projects');
        System.assertEquals(true, wrapper.hasProjects, 'Expected to have projects');
        

    }
}