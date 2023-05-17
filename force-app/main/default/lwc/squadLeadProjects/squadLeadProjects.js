import { LightningElement, wire, track } from 'lwc';
import getProjects from '@salesforce/apex/SquadLeadProjectsWrapper.getProjects';
import { NavigationMixin } from 'lightning/navigation';

export default class SquadLeadProjects extends NavigationMixin(LightningElement){
    @track data;
    error;

    @wire(getProjects)
    theWrapper(result) {
        if(result.data) {
            this.data = result.data;
            this.error = undefined;
        }else if(result.error){
            this.data = undefined
            this.error = result.error;
            console.log(this.error);
        }
    }

    handleSectionToggle(event) {
        const openSections = event.detail.openSections;

        if (openSections.length === 0) {
            this.activeSectionsMessage = 'All sections are closed';
        } else {
            this.activeSectionsMessage =
                'Open sections: ' + openSections.join(', ');
        }
    }

    handleProjectClick(e){
        const projectId = e.currentTarget.dataset.projectid;

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: projectId,
                objectApiName: 'Project__c',
                actionName: 'view'
            }
        });
    }
}