import { LightningElement, api, track } from 'lwc';
import getMyOrders from '@salesforce/apex/OrderController.getMyOrders';
import createDraftOrder from '@salesforce/apex/OrderController.createDraftOrder';

const COLUMNS = [
    { label: 'Order Name', fieldName: 'Name' },
    { label: 'Status', fieldName: 'Status__c' },
    { label: 'Order Date', fieldName: 'Order_Date__c', type: 'date' },
    { label: 'Total Amount', fieldName: 'Total_Amount__c', type: 'currency' },
    { label: 'Payment Status', fieldName: 'Payment_Status__c' },
    {
        type: 'button',
        typeAttributes: {
            label: 'Open',
            name: 'open',
            variant: 'brand'
        }
    }
];

export default class OrderList extends LightningElement {
    @api accountId;
    @api contactId;

    @track orders = [];
    @track errorMessage = '';

    isLoading = false;
    columns = COLUMNS;

    connectedCallback() {
        this.loadOrders();
    }

    get hasOrders() {
        return this.orders && this.orders.length > 0;
    }

    get hasNoOrders() {
        return !this.isLoading && !this.errorMessage && this.orders.length === 0;
    }

    async loadOrders() {
        if (!this.accountId) {
            this.errorMessage = 'AccountId is required.';
            return;
        }

        this.isLoading = true;
        this.errorMessage = '';

        try {
            const result = await getMyOrders({ accountId: this.accountId });
            this.orders = result || [];
        } catch (error) {
            this.orders = [];
            this.errorMessage = this.normalizeError(error);
        } finally {
            this.isLoading = false;
        }
    }

    async handleCreateOrder() {
        if (!this.accountId || !this.contactId) {
            this.errorMessage = 'AccountId and ContactId are required to create an order.';
            return;
        }

        this.isLoading = true;
        this.errorMessage = '';

        try {
            const newOrderId = await createDraftOrder({
                accountId: this.accountId,
                contactId: this.contactId
            });

            await this.loadOrders();

            this.dispatchEvent(
                new CustomEvent('orderselected', {
                    detail: { orderId: newOrderId }
                })
            );
        } catch (error) {
            this.errorMessage = this.normalizeError(error);
        } finally {
            this.isLoading = false;
        }
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        if (actionName === 'open') {
            this.dispatchEvent(
                new CustomEvent('orderselected', {
                    detail: { orderId: row.Id }
                })
            );
        }
    }

    normalizeError(error) {
        if (error?.body?.message) {
            return error.body.message;
        }

        if (error?.message) {
            return error.message;
        }

        return 'An unexpected error occurred.';
    }
}