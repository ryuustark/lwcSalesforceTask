import { LightningElement,track , wire, api } from 'lwc';
import getProducts from '@salesforce/apex/orderAvalaibleProducts.getOrderAvalaibleProducts';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const COLUMNS = [
  {label: 'Name', fieldName: 'productName', type: 'text'},
  //{label: 'PricebookEntryId', fieldName: 'PricebookEntryId', type: 'text', typeAttributes: {display: 'none'}},
  {label: 'List Price', fieldName: 'listPrice', type: 'currency', cellAttributes: { alignment: 'center' } }
];

export default class OrderProductsAvalaible extends LightningElement {
    columns = COLUMNS;
    @api recordId;
    @api products = [];
    @track pricebookEntryId;
    @track PricebookEntries = [];
    @track record;
    @track temp;
    @track PBId;
    @track selectedProducts = [];
    @wire(getRecord, { recordId: '$recordId', fields: ['Order.Pricebook2Id'] })
    wiredPricebook({ error, data }) {
        if (data) {
            this.record = data;
            //console.log('>>>PB Record Data: ' + JSON.stringify(this.record));
            this.PBId = this.record.fields.Pricebook2Id.value;
            //console.log('>>>PB Record Data Pricebook ID: ' + JSON.stringify(this.PBId));
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.record = undefined;
        }
    };

    @wire(getProducts,  {PBId: '$PBId'}) //8014x0000004N79AAE//products;     @wire(getProducts,  {pricebookId: '$PBId'})
    wiredCase({error , data}) {
      if(data)
      {
          this.PricebookEntries = data;
          this.pricebookEntryId = data.pricebookEntryId;
          //console.log('>>>Log Data: ' + JSON.stringify(this.PricebookEntries.pricebookEntryId));
          //console.log('>>>Log Data UnitPrice: ' + JSON.stringify(this.PricebookEntries[0].UnitPrice));
          //console.log('>>>Log Data Name: ' + JSON.stringify(this.PricebookEntries[0].Product2.Name));
          
        console.log('>>>Log Data ProductWrapper: ' + JSON.stringify(this.PricebookEntries));
      } else if(error) {
        console.warn('>>>Log Data Error: ' + JSON.stringify(error))
      }
  };
  
  
  
  handleAddClick(event) {
    //console.log(">>> Add3 ");     
    this.selectedProducts = this.template.querySelector("lightning-datatable").getSelectedRows();    
    if(this.selectedProducts.length > 0){
      console.log(">>> Sending Products to add..." );
      console.log(">>> selectedProducts..." + JSON.stringify(this.selectedProducts));
      
      //send data to child LWC
      this.template.querySelector("c-order-products-list").handleAddedProducts(this.selectedProducts);
    } else {
      this.showErrorToast();
    }
    
  }
  
     
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
