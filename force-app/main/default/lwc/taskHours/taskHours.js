import { LightningElement, api } from 'lwc';

export default class TaskHours extends LightningElement {
    @api task;
    get isStarted(){
        if(this.task.Status__c === 'In Progress'){
            return true;
        }
        return false;
    };
    get notStarted(){
        if(this.task.Status__c === 'Not Started'){
            return true;
        }
        return false;
    };


}