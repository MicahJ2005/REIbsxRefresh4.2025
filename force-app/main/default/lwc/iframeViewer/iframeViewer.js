import { LightningElement, api } from 'lwc';

export default class IframeViewer extends LightningElement {
    @api iframeUrl; // Make URL configurable via markup or JS
}