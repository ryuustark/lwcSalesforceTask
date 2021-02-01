import { LightningElement, track, wire, api } from 'lwc';
import getOrderProducts from '@salesforce/apex/orderProducts.getOrderOrderProducts';
import UpdateOrderProducts from '@salesforce/apex/orderProducts.UpdateOrderProducts';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const COLUMNS = [
    {label: 'Name', fieldName: 'productName', type: 'text'},
    {label: 'List Price', fieldName: 'listPrice', type: 'currency', cellAttributes: { alignment: 'right' } },
    {label: 'Quantity', fieldName: 'Quantity', type: 'numeric', cellAttributes: { alignment: 'center' }},
    {label: 'Total Price', fieldName: 'totalPrice',type: 'currency', cellAttributes: { alignment: 'right' } }
];

export default class OrderProductsList extends LightningElement {
    columns = COLUMNS;
    @api recordid;
    @api pricebookentryid;
    @api insertedproducts = [];
    @track orderproducts = [];
    @track record;
    @track insert = false;
    // get OrderItems from the order
    @wire(getOrderProducts,  {orderId: '$recordid'}) //8014x0000004N79AAE//products;     @wire(getProducts,  {pricebookId: '$PBId'})
    wiredCase({error , data}) {
      if(data)
      {
        this.orderproducts = data;
        console.log('>>> pricebookentryid: ' + JSON.stringify(this.pricebookentryid));
      } else if(error) {
        console.warn('>>>Log Data Error: ' + JSON.stringify(error))
      }
    };
    //Called from Component 1, with the products that will be added
    @api handleAddedProducts(products)
    {
        this.insertedproducts = products;
        //call Apex Method
        UpdateOrderProducts(
          {OPw : this.orderproducts, 
          productsToInsert : this.insertedproducts,
          OrderId : this.recordid,
          PricebookEntryId : this.pricebookentryid
           })
          .then(r => {
            this.orderproducts = r;
          });
          //show success toas when inserted
          this.showSuccessToast();

    }

    showSuccessToast() {
        const evt = new ShowToastEvent({
            title: 'Toast Success',
            message: 'Opearion sucessful ' + this.insertedproducts.length + ' Product(s) were added.',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }


}