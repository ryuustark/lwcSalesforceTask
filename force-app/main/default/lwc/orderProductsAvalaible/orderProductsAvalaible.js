import { LightningElement,track , wire, api } from 'lwc';
import getProducts from '@salesforce/apex/orderAvalaibleProducts.getOrderAvalaibleProducts';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const COLUMNS = [
  {label: 'Name', fieldName: 'productName', type: 'text'},
  {label: 'List Price', fieldName: 'listPrice', type: 'currency', cellAttributes: { alignment: 'center' } }
];

export default class OrderProductsAvalaible extends LightningElement {
    columns = COLUMNS;
    @api recordId;
    @api products = []; //Avalaible products in the order
    @track pricebookEntryId; 
    @track PricebookEntries = []; //PricebookEntries related to the products
    @track record;
    @track PBId;
    @track selectedProducts = [];
    //get data from the record
    @wire(getRecord, { recordId: '$recordId', fields: ['Order.Pricebook2Id'] })
    wiredPricebook({ error, data }) {
        if (data) {
            this.record = data;
            this.PBId = this.record.fields.Pricebook2Id.value;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.record = undefined;
        }
    };
    //get productEntries from Order from Apex
    @wire(getProducts,  {PBId: '$PBId'}) //8014x0000004N79AAE//products;     @wire(getProducts,  {pricebookId: '$PBId'})
    wiredCase({error , data}) {
      if(data)
      {
          this.PricebookEntries = data;
          this.pricebookEntryId = data.pricebookEntryId;
      } else if(error) {
        console.warn('>>>Log Data Error: ' + JSON.stringify(error))
      }
  };
  
  
  //Send Selected products to the Component 2
  handleAddClick(event) {  
    this.selectedProducts = this.template.querySelector("lightning-datatable").getSelectedRows();    
    if(this.selectedProducts.length > 0){
      //send data to child LWC
      this.template.querySelector("c-order-products-list").handleAddedProducts(this.selectedProducts);
    } else {
      this.showErrorToast();
    }
    
  }
  
     //Show error in case the user do not select any products
    showErrorToast() {
      const evt = new ShowToastEvent({
          title: 'No Products Selected',
          message: 'Please, select Products to add to the Order.',
          variant: 'error',
          mode: 'dismissable'
      });
      this.dispatchEvent(evt);
  }
}
