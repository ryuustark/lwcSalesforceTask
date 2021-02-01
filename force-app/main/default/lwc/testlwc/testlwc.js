import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import ACCOUNT_NAME_FIELD from '@salesforce/schema/Account.Name';
import REVENUE_FIELD from '@salesforce/schema/Account.AnnualRevenue';
export default class wireGetAccounts extends LightningElement {
    @api recordId;
    data;
    error;
    @wire(getRecord, { recordId: '$recordId', fields: [ACCOUNT_NAME_FIELD, REVENUE_FIELD] })
    wiredAccount({data, error}) {
        console.log('Execute logic each time a new value is provisioned');
        if (data) {
            this.data = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.data = undefined;
        }
    }
}

/*const COLS = [
    { label: 'First Name', fieldName: 'firstName', editable: false },
    { label: 'Last Name', fieldName: 'lastName', editable: false },
    { label: 'Email', fieldName: 'email', editable: false },
    { label: 'Phone', fieldName: 'cell', editable: false }
    ]; */