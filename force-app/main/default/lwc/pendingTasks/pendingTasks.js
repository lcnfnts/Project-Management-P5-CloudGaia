import { LightningElement, wire, api } from 'lwc';
import getTasks from '@salesforce/apex/PendingTasksWrapper.getTasks';

export default class PendingTasks extends LightningElement {
    @api recordId;
    data;
    error;
    
    @wire(getTasks, {projectId: '$recordId'})
    theWrapper(result) {
        if(result.data) {
          this.data = result.data;
          console.log('aca esta la data');
          console.log(this.data);
        } else if(result.error){
          this.error = result.error;
        }
    }

}