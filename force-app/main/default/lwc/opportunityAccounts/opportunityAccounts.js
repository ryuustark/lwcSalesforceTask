import { LightningElement, track, wire, api } from 'lwc';
import NAME_FIELD from '@salesforce/schema/Account.Name';
import REVENUE_FIELD from '@salesforce/schema/Account.AnnualRevenue';
import INDUSTRY_FIELD from '@salesforce/schema/Account.Industry';
import getAccounts from '@salesforce/apex/AccountController.getAccounts';
const COLUMNS = [
    { label: 'Account Name', fieldName: NAME_FIELD.fieldApiName, type: 'text' },
    { label: 'Annual Revenue', fieldName: REVENUE_FIELD.fieldApiName, type: 'currency' },
    { label: 'Industry', fieldName: INDUSTRY_FIELD.fieldApiName, type: 'text' }
];
export default class OpportunityAccounts extends LightningElement {
    columns = COLUMNS;
    @track tempSelectedids = [];
    @wire(getAccounts)
    hiddenAccounts;
    @track accounts =[];
    
    handleAddClick(event) {
        this.accounts = hiddenAccounts;
        //handle selected ids
        //Add to the other LWC 
         
    }
    handleRemoveClick(event) {
        var popped = this.accounts.pop();
        
        //Remove from other LWC
    }
}
//Ask: have a paren LWC with the 2 LWC of the requirement? 