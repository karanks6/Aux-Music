import { YTNode } from '../helpers.js';
export default class PageIndicatorView extends YTNode {
    static type = 'PageIndicatorView';
    indicator_count;
    selected_index;
    constructor(data) {
        super();
        this.indicator_count = data.indicatorCount ?? 0;
        this.selected_index = data.selectedIndex ?? 0;
    }
}
//# sourceMappingURL=PageIndicatorView.js.map