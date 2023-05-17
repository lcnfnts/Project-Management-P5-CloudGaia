import { LightningElement, api, wire, track } from 'lwc';
import getTaskWrapper from '@salesforce/apex/TaskWrapper.getTaskWrapper';
import updateTaskStatus from '@salesforce/apex/ProjectTaskService.updateTaskStatus';
import updateRecordedHours from '@salesforce/apex/ProjectTaskService.updateRecordedHours';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class TaskManagement extends LightningElement {
    @track data;
    error;
    refresh;

    // Var to store the data with an additional calculated field "isStarted" based on the data from the inner class in taskWrapper.
    @track TaskWrapperContainer = [];

    @wire(getTaskWrapper)
    theWrapper(result) {
        // using theWrapper(result) structure to use refreshApex
        // Previously used theWrapper( {data, error} ) didn't work refresh apex that way.
        this.refresh = result
        if(result.data) {
          this.data = result.data;

          const newData = [...result.data.projectWithTasks];
          this.TaskWrapperContainer = newData.map(obj => {
            const tasks = obj.tasks.map( task => {
              let isStarted = false;
              if(task.Status__c === 'In Progress'){
                isStarted = true;
              }
              return {
                ...task,
                isStarted
              }
            })
            return{
              ...obj,
              tasks
            }
          });
        }else if(result.error){
          this.error = result.error;
        }
    }

    handleStartClick(e){
      const taskId = e.target.dataset.taskid;

      updateTaskStatus( { taskId : taskId, status : 'In Progress' } )
      .then( result => {
        const toast = new ShowToastEvent({
          title: 'Success',
          message: 'Task status successfully updated',
          variant: 'success',
        });
      this.dispatchEvent(toast);  
        refreshApex(this.refresh);
      })
      .catch ( error =>{
        console.log(error);
        const toast = new ShowToastEvent({
          title: 'Failed to update task status',
          message: error,
          variant: 'error',
      });
      this.dispatchEvent(toast);
      });

    }
    
    handleCompleteClick(e){
      const taskId = e.target.dataset.taskid;


      updateTaskStatus( { taskId : taskId, status : 'Completed' } )
      .then( result => {
        const toast = new ShowToastEvent({
          title: 'Success',
          message: 'Task status successfully updated',
          variant: 'success',
        });
      this.dispatchEvent(toast);  
        refreshApex(this.refresh);
      })
      .catch ( error =>{
        console.log(error);
        const toast = new ShowToastEvent({
          title: 'Failed to update task status',
          message: error.body.message,
          variant: 'error',
      });
      this.dispatchEvent(toast); 
      });
    }

    handleSubmitClick(e){
      const taskId = e.target.dataset.taskid;
      const input = this.template.querySelector(`input[data-taskid=${taskId}]`);
      const recordedHours = input.value;
      if(!recordedHours){
        return null;
      }
      
      updateRecordedHours( { taskId : taskId, recordedHours : recordedHours } )
      .then( result => {
        refreshApex(this.refresh);
        input.value = null;
        })
      .catch( error =>{
        console.log('Paso por el catch');
        console.log(error);
        const toast = new ShowToastEvent({
          title: 'Failed to add hours',
          message: error.body.message,
          variant: 'error',
        });
        this.dispatchEvent(toast); 
      });

    }

    renderedCallback() {
      if (this.data) {
        const buttons = Array.from(this.template.querySelectorAll('lightning-button'));
        const completedButtons = buttons.filter(button => button.disabled);
        completedButtons.forEach(button => {
          const taskLayout = button.closest('.taskLayout');
          const estimatedHours = taskLayout.querySelector('.estimatedHours').textContent;
          const recordedHours = taskLayout.querySelector('.recordedHours').textContent;
          if (estimatedHours === recordedHours) {
            button.disabled = false;
          }
        });
      }
    }
}