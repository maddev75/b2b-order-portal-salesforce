import { LightningElement, api, track } from 'lwc';
import getActiveProducts from '@salesforce/apex/ProductController.getActiveProducts';
import addOrderLine from '@salesforce/apex/OrderController.addOrderLine';

export default class OrderLineForm extends LightningElement {
    @api orderId;

    @track products = [];
    @track errorMessage = '';

    isLoading = false;
    selectedProductId = '';
    quantity = 1;

    connectedCallback() {
        this.loadProducts();
    }

    get productOptions() {
        return (this.products || []).map(product => ({
            label: product.Name,
            value: product.Id
        }));
    }

    async loadProducts() {
        this.isLoading = true;
        this.errorMessage = '';

        try {
            const result = await getActiveProducts();
            this.products = result || [];
        } catch (error) {
            this.products = [];
            this.errorMessage = this.normalizeError(error);
        } finally {
            this.isLoading = false;
        }
    }

    handleProductChange(event) {
        this.selectedProductId = event.detail.value;
    }

    handleQuantityChange(event) {
        this.quantity = parseInt(event.detail.value, 10);
    }

    async handleAddLine() {
        if (!this.orderId) {
            this.errorMessage = 'OrderId is required.';
            return;
        }

        if (!this.selectedProductId) {
            this.errorMessage = 'Please select a product.';
            return;
        }

        if (!this.quantity || this.quantity <= 0) {
            this.errorMessage = 'Quantity must be greater than 0.';
            return;
        }

        this.isLoading = true;
        this.errorMessage = '';

        try {
            await addOrderLine({
                orderId: this.orderId,
                productId: this.selectedProductId,
                quantity: this.quantity
            });

            this.selectedProductId = '';
            this.quantity = 1;

            this.dispatchEvent(new CustomEvent('lineadded'));
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
}