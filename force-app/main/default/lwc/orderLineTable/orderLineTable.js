import { LightningElement, api, track } from 'lwc';
import updateOrderLine from '@salesforce/apex/OrderController.updateOrderLine';
import deleteOrderLine from '@salesforce/apex/OrderController.deleteOrderLine';

export default class OrderLineTable extends LightningElement {
    _orderLines = [];

    @track linesState = [];
    @track errorMessage = '';

    isLoading = false;

    @api isDraft = false;

    @api
    get orderLines() {
        return this._orderLines;
    }

    set orderLines(value) {
        this._orderLines = value || [];
        this.linesState = this._orderLines.map(line => ({
            ...line,
            editQuantity: line.Quantity__c,
            productLabel: this.resolveProductLabel(line)
        }));
    }

    get normalizedLines() {
        return this.linesState;
    }

    get hasLines() {
        return this.linesState && this.linesState.length > 0;
    }

    get hasNoLines() {
        return !this.isLoading && this.linesState.length === 0;
    }

    get disableActions() {
        return !this.isDraft;
    }

    resolveProductLabel(line) {
        if (line?.Product__r?.Name) {
            return line.Product__r.Name;
        }

        return line.Product__c || 'Unknown Product';
    }

    get isActionDisabled() {
        return this.disableActions || this.isLoading;
    }

    handleQuantityChange(event) {
        const lineId = event.target.dataset.lineId;
        const newQuantity = parseInt(event.detail.value, 10);

        this.linesState = this.linesState.map(line => {
            if (line.Id === lineId) {
                return {
                    ...line,
                    editQuantity: newQuantity
                };
            }
            return line;
        });
    }

    async handleUpdateLine(event) {
        const lineId = event.target.dataset.lineId;
        const targetLine = this.linesState.find(line => line.Id === lineId);

        if (!targetLine) {
            this.errorMessage = 'Order line not found.';
            return;
        }

        if (!targetLine.editQuantity || targetLine.editQuantity <= 0) {
            this.errorMessage = 'Quantity must be greater than 0.';
            return;
        }

        this.isLoading = true;
        this.errorMessage = '';

        try {
            await updateOrderLine({
                lineId: lineId,
                quantity: targetLine.editQuantity
            });

            this.dispatchEvent(new CustomEvent('lineupdated'));
        } catch (error) {
            this.errorMessage = this.normalizeError(error);
        } finally {
            this.isLoading = false;
        }
    }

    async handleDeleteLine(event) {
        const lineId = event.target.dataset.lineId;

        this.isLoading = true;
        this.errorMessage = '';

        try {
            await deleteOrderLine({ lineId });
            this.dispatchEvent(new CustomEvent('linedeleted'));
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