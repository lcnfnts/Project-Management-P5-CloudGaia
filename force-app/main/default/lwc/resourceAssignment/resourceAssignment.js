import { LightningElement, api, track, wire } from 'lwc';
import getProject from '@salesforce/apex/ProjectWrapper.getProject';
import addResources from '@salesforce/apex/ProjectService.addResources';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {refreshApex} from '@salesforce/apex';

export default class ResourceAssignment extends LightningElement {
    @api recordId;
    @track data;
    error;
    @track requirements=[];
    // variable to use after with the refreshApex
    refresh;

    @wire(getProject, {projectId: '$recordId'})
    theWrapper(result) {
        // using theWrapper(result) structure to use refreshApex
        // Previously used theWrapper( {data, error} ) didn't work refresh apex that way.
        this.refresh = result
        if(result.data) {
          this.data = result.data;
          this.error = undefined;

          const newData = [...result.data.requirementList];
          this.requirements = newData.map(obj => {
            //const projectProduct = obj.projectProduct;
            const { projectProduct } = obj;
            let hoursMissing;
            if( (projectProduct.Quantity__c - projectProduct.Completed_Hours__c) < 0){
              hoursMissing = 0;
            }else{
              hoursMissing = projectProduct.Quantity__c - projectProduct.Completed_Hours__c;
            }
            return {
              // el ...obj me trae copia de un objeto Requirement del wrapper con su projectProduct y su lista de Users
              ...obj,
              projectProduct: {
                ...projectProduct,
                hoursMissing
              }
            };
          });
        } else if(result.error){
          this.error = result.error;
        }
    }


  renderedCallback(){
    if(this.data){
      const userBoxes = this.template.querySelectorAll('.userBox');
      userBoxes.forEach((box) => {
        const parent = box.parentNode;
        const lastChild = parent.lastChild;
        lastChild.classList.add('lastUserBoxChild');
      });
    }
  }

  handleAssignClick(){
    // Get all the checkboxes
    const checkboxes = Array.from(this.template.querySelectorAll('.inputCheckbox'));

    let selectedUsers = [];

    let flag = true;

    checkboxes.forEach((checkbox) => {

      if (checkbox.checked) {
        
        const userBox = checkbox.closest('.userBox');
        const userId = userBox.querySelector('.userBoxParagraph').getAttribute('data-userid');
        const startDate = userBox.querySelector('.startDate').value;
        const finishDate = userBox.querySelector('.closeDate').value;
        const assignedHours = userBox.querySelector('.hoursAssigned').value;
        const assignButton = this.template.querySelector('.assignButton');
        const hoursPendingNode = userBox.parentNode.querySelector('.hoursMissing');
        const hoursPendingNumber = parseInt(hoursPendingNode.textContent.split(': ')[1]);

        if(startDate && finishDate && assignedHours){
          if(new Date(startDate) >= new Date(finishDate) || new Date(startDate) <= new Date()){
            // Means all the fields were filled, but the date were not valid.
            flag = false;
            const newDiv = document.createElement('div');
            newDiv.innerHTML = "Start date must be after today and before finish date";
            // CSS Properties of newDiv
            newDiv.style['color'] = 'red';
            newDiv.style['position'] = 'absolute';
            newDiv.style['top'] = '-10%';
            newDiv.style['right'] = '3%';
            newDiv.style['width'] = 'max-content';
            newDiv.style['background-color'] = 'white';
            newDiv.style['color'] = 'red';
            newDiv.style['padding'] = '0px 4px';
            userBox.appendChild(newDiv);
            userBox.classList.add('validateRed');
            assignButton.disabled = true;
            setTimeout(() => {
              userBox.classList.remove('validateRed');
              userBox.removeChild(newDiv);
              assignButton.disabled = false;
            }, 6000);         
          }else if(new Date(startDate) < new Date(this.data.project.Start_Date__c) || new Date(finishDate) > new Date(this.data.project.Close_Date__c)){
            // Means date ranges are not in the project range.
            flag = false;
            const newDiv = document.createElement('div');
            newDiv.innerHTML = "Date ranges must be in date range of the project";
            // CSS Properties of newDiv
            newDiv.style['color'] = 'red';
            newDiv.style['position'] = 'absolute';
            newDiv.style['top'] = '-10%';
            newDiv.style['right'] = '3%';
            newDiv.style['width'] = 'max-content';
            newDiv.style['background-color'] = 'white';
            newDiv.style['color'] = 'red';
            newDiv.style['padding'] = '0px 4px';
            userBox.appendChild(newDiv);
            userBox.classList.add('validateRed');
            assignButton.disabled = true;
            setTimeout(() => {
              userBox.classList.remove('validateRed');
              userBox.removeChild(newDiv);
              assignButton.disabled = false;
            }, 6000);          
          }
          else if(assignedHours > hoursPendingNumber){
            flag = false;
            const newDiv = document.createElement('div');
            newDiv.innerHTML = "Too many assigned hours";
            // CSS Properties of newDiv
            newDiv.style['color'] = 'red';
            newDiv.style['position'] = 'absolute';
            newDiv.style['top'] = '-10%';
            newDiv.style['right'] = '3%';
            newDiv.style['width'] = 'max-content';
            newDiv.style['background-color'] = 'white';
            newDiv.style['color'] = 'red';
            newDiv.style['padding'] = '0px 4px';
            userBox.appendChild(newDiv);
            userBox.classList.add('validateRed');
            assignButton.disabled = true;
            setTimeout(() => {
              userBox.classList.remove('validateRed');
              userBox.removeChild(newDiv);
              assignButton.disabled = false;
            }, 6000);

          }else{
            // Add the data to the selectedUsers array
            selectedUsers.push({
              Project__c: this.recordId,
              Resource__c: userId,
              Start_Date__c: startDate,
              Close_Date__c: finishDate,
              AssignedHours__c: assignedHours
            });
          }


        }else{

          flag = false;

          const newDiv = document.createElement('div');
          newDiv.innerHTML = "Fill all the fields";
          // CSS Properties of newDiv
          newDiv.style['color'] = 'red';
          newDiv.style['position'] = 'absolute';
          newDiv.style['top'] = '-10%';
          newDiv.style['right'] = '3%';
          newDiv.style['width'] = 'max-content';
          newDiv.style['background-color'] = 'white';
          newDiv.style['color'] = 'red';
          newDiv.style['padding'] = '0px 4px';
          userBox.appendChild(newDiv);
          userBox.classList.add('validateRed');
          assignButton.disabled = true;
          setTimeout(() => {
            userBox.classList.remove('validateRed');
            userBox.removeChild(newDiv);
            assignButton.disabled = false;
          }, 6000);
        }

      }
    });

    if(flag===false){
      selectedUsers = [];
    }else if(selectedUsers.length > 0){
      addResources( { projectId : this.recordId, jsonResources : JSON.stringify(selectedUsers) } )
      .then(response => {
        this.showToastMessage(true);
        refreshApex(this.refresh);
      })
      .catch(error => {
        const str = error.body.pageErrors[0].message
        const regex = /Exception: (.*)/; // regular expression to match the text after "Exception: "
        const match = regex.exec(str); // applying the regular expression on the input string

        if (match) {
          const parsedText = match[1]; // extracting the matched text (group 1) from the match object
          this.showToastMessage(false, parsedText);
        } else {
          this.showToastMessage(false, 'There was an error assigning the resource');
        }
      });
    }else{
      this.showToastMessage(false, 'You must select at least one resource.');
      const assignButton = this.template.querySelector('.assignButton');
      assignButton.disabled = true;
      setTimeout(() => {
        assignButton.disabled = false;
      }, 3000);
    }
  }

  showToastMessage(cond, message){
    if(cond){
        const toast = new ShowToastEvent({
            title: 'Success',
            message: 'Resources allocated successfully.',
            variant: 'success',
        });
        this.dispatchEvent(toast);          
    }else{
        const toast = new ShowToastEvent({
            title: 'Failure',
            message: message,
            variant: 'error',
        });
        this.dispatchEvent(toast);  
    }
  }

}