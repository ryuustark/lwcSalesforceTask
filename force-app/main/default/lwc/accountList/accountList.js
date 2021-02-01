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
export default class AccountList extends LightningElement {
    columns = COLUMNS;
    @track tempSelectedids = [];
    @api oppAccoutns = [];
    @wire(getAccounts)
    accounts;
    @track accountsTrack;
    handleAddClick(event) {
        this.accountsTrack = this.accounts;
        console.log(">>> Add6 ");
        console.log(">>> accounts..." + this.accountsTrack);
        var AccsToInsert = this.template.querySelectoy("lightning-datatable").getSelectedRows();
        console.log(">>> AccsToInsert..." + this.AccsToInsert);
        //handle selected ids
        //Add to the other LWC 
          
    }
    handleRemoveClick(event) {
        console.warn(">>> Remove ");
        //Remove from other LWC Optional
    }
}
//Ask: have a paren LWC with the 2 LWC of the requirement? 