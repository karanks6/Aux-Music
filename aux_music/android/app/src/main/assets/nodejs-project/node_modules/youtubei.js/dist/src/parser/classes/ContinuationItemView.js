import { YTNode } from '../helpers.js';
import NavigationEndpoint from './NavigationEndpoint.js';
export default class ContinuationItemView extends YTNode {
    static type = 'ContinuationItemView';
    trigger;
    endpoint;
    constructor(data) {
        super();
        this.trigger = data.trigger;
        this.endpoint = new NavigationEndpoint(data.continuationCommand);
    }
}
//# sourceMappingURL=ContinuationItemView.js.map