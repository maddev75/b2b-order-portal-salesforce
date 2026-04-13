import { LightningElement, api } from 'lwc';

export default class OrderApp extends LightningElement {
    @api accountId;
    @api contactId;

    selectedOrderId = null;

    get showList() {
        return !this.selectedOrderId;
    }

    get showDetail() {
        return !!this.selectedOrderId;
    }

    handleOrderSelected(event) {
        this.selectedOrderId = event.detail.orderId;
    }

    handleBackToList() {
        this.selectedOrderId = null;
    }
}