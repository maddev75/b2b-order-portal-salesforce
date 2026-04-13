import { LightningElement, api, track } from 'lwc';
import getOrderDetail from '@salesforce/apex/OrderController.getOrderDetail';
import submitOrder from '@salesforce/apex/OrderController.submitOrder';

const LINE_COLUMNS = [
    { label: 'Product', fieldName: 'Product__c' },
    { label: 'Quantity', fieldName: 'Quantity__c', type: 'number' },
    { label: 'Unit Price', fieldName: 'Unit_Price__c', type: 'currency' },
    { label: 'Line Total', fieldName: 'Line_Total__c', type: 'currency' }
];

export default class OrderDetail extends LightningElement {
    @api orderId;

    @track detail;
    @track errorMessage = '';

    isLoading = false;
    lineColumns = LINE_COLUMNS;

    connectedCallback() {
        this.loadOrderDetail();
    }

    async loadOrderDetail() {
        if (!this.orderId) {
            this.errorMessage = 'OrderId is required.';
            return;
        }

        this.isLoading = true;
        this.errorMessage = '';

        try {
            const result = await getOrderDetail({ orderId: this.orderId });
            this.detail = result;
            console.log('Result-Order-Detail-1', result);
        } catch (error) {
            this.detail = null;
            this.errorMessage = this.normalizeError(error);
        } finally {
            this.isLoading = false;
        }
    }

    get orderRecord() {
        return this.detail?.orderRecord;
    }

    get orderLines() {
        return this.detail?.orderLines || [];
    }

    get hasOrder() {
        return !!this.orderRecord;
    }

    get hasLines() {
        return this.orderLines.length > 0;
    }

    get hasNoLines() {
        return this.hasOrder && this.orderLines.length === 0;
    }

    get isDraft() {
        return this.orderRecord?.Status__c === 'Draft';
    }

    handleBackToList() {
        this.dispatchEvent(new CustomEvent('backtolist'));
    }

    async handleSubmitOrder() {
        if (!this.orderId) {
            this.errorMessage = 'OrderId is required.';
            return;
        }

        this.isLoading = true;
        this.errorMessage = '';

        try {
            await submitOrder({ orderId: this.orderId });
            await this.loadOrderDetail();
        } catch (error) {
            this.errorMessage = this.normalizeError(error);
        } finally {
            this.isLoading = false;
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

    async handleLineAdded() {
        await this.loadOrderDetail();
    }

    async handleLineUpdated() {
        await this.loadOrderDetail();
    }
    
    async handleLineDeleted() {
        await this.loadOrderDetail();
    }
}