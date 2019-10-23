import { LightningElement,api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getContacts from '@salesforce/apex/RelatedContactsController.getContacts';
import pullContacts from '@salesforce/apex/RelatedContactsController.pullContacts';
import getAccounts from '@salesforce/apex/RelatedContactsController.getAccounts';
import ACCOUNT_CONTACT from '@salesforce/schema/AccountContactRelation';
import ACC_FIELD from '@salesforce/schema/AccountContactRelation.AccountId';
import CON_FIELD from '@salesforce/schema/AccountContactRelation.ContactId';
import ROLES_FIELD from '@salesforce/schema/AccountContactRelation.Roles';


 
export default class RelatedContacts extends NavigationMixin (LightningElement) {
    @api recordId;
    @wire(getContacts, {accId:'$recordId'})
      contacts;
    
    @wire(pullContacts, {accId:'$recordId'})
      allContacts;

    @wire(getAccounts, {accId:'$recordId'})
      allAccounts;        


    contactId;
    accountId;
    roles;

    // getting Role for new Relation from text field
    handleRole(event) {
        this.roles = event.target.value;
    }

    // getting Id values from 'select for:each' for contacts and accounts
    changeHandler(event) {
        const field = event.target.name;
        const val = event.target.value;
        if (field === 'contactSelect') {
            this.contactId = val;
            }

        if (field === 'accountSelect') {
            this.accountId = val;
            }   
        }    

    // creating new ACR object and showing result plate for user    
    createRelation() {
       const fields = {};
       fields[CON_FIELD.fieldApiName] = this.contactId;
       fields[ACC_FIELD.fieldApiName] = this.accountId;
       fields[ROLES_FIELD.fieldApiName] = this.roles;

       const recordInput = { apiName: ACCOUNT_CONTACT.objectApiName, fields };
       createRecord(recordInput)
           .then(acr => {
               this.contactId = acr.ContactId;
               this.accountId = acr.AccountId;
               this.roles = acr.Roles;
               this.dispatchEvent(
                   new ShowToastEvent({
                       title: 'Success',
                       message: 'Relation created',
                       variant: 'success',
                   }),
               );
           })
           .catch(error => {
               this.dispatchEvent(
                   new ShowToastEvent({
                       title: 'Error creating record',
                       message: error.body.message,
                       variant: 'error',
                   }),
               );
           });
   }
}
