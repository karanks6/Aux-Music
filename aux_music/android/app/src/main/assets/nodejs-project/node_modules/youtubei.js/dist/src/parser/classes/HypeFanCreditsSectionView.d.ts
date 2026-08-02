import { YTNode } from '../helpers.js';
import { type RawNode } from '../index.js';
import SectionHeaderView from './SectionHeaderView.js';
export default class HypeFanCreditsSectionView extends YTNode {
    static type: string;
    header: SectionHeaderView | null;
    constructor(data: RawNode);
}
