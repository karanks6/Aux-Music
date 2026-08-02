import { YTNode } from '../helpers.js';
import { Parser } from '../index.js';
import SectionHeaderView from './SectionHeaderView.js';
export default class HypeFanCreditsSectionView extends YTNode {
    static type = 'HypeFanCreditsSectionView';
    header;
    constructor(data) {
        super();
        this.header = Parser.parseItem(data.header, SectionHeaderView);
    }
}
//# sourceMappingURL=HypeFanCreditsSectionView.js.map