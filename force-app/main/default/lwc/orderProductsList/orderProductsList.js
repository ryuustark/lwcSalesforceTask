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

    @api handleAddedProducts(products)
    {
        this.insertedproducts = products;
        //console.log('>>>sent products: ' + JSON.stringify(this.insertedproducts));
        UpdateOrderProducts(
          {OPw : this.orderproducts, 
          productsToInsert : this.insertedproducts,
          OrderId : this.recordid,
          PricebookEntryId : this.pricebookentryid
           })
          .then(r => {
            this.orderproducts = r;
          });
          //console.log('>>>Order products Change: ' + JSON.stringify(this.orderproducts));

        //********* volver a poner success toast cuando ya funcione */
        //this.showSuccessToast();

    }

    showSuccessToast() {
        const evt = new ShowToastEvent({
            title: 'Toast Success',
            message: 'Opearion sucessful ' + this.selectedProducts.length + ' Products were added.',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }


}