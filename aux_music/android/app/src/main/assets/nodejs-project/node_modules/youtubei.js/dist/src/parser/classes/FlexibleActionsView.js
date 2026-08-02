import { YTNode } from '../helpers.js';
import { Parser } from '../index.js';
import ButtonView from './ButtonView.js';
import ToggleButtonView from './ToggleButtonView.js';
import SubscribeButtonView from './SubscribeButtonView.js';
export default class FlexibleActionsView extends YTNode {
    static type = 'FlexibleActionsView';
    actions_rows;
    style;
    constructor(data) {
        super();
        this.actions_rows = data.actionsRows.map((row) => ({
            actions: Parser.parseArray(row.actions, [ButtonView, ToggleButtonView, SubscribeButtonView])
        }));
        this.style = data.style;
    }
}
//# sourceMappingURL=FlexibleActionsView.js.map