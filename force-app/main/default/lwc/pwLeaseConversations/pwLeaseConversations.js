import { LightningElement, api, wire } from 'lwc';
import getLeaseConversations from '@salesforce/apex/PWLeaseConversationsController.getLeaseConversations';

export default class PwLeaseConversations extends LightningElement {
    @api recordId; // Assume used on PW_Lease__c record page
    conversations = [];
    error;

    connectedCallback() {
        this.loadConversations();
    }

    loadConversations() {
        getLeaseConversations({ leaseId: this.recordId })
            .then((result) => {
                console.log(result.length);
                this.conversations = result;
                if(result.length === 0){
                    this.conversations = false;
                }
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error.body?.message || error.message;
                this.conversations = false;
            });
    }
}