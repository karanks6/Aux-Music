import { YTNode } from '../helpers.js';
import type { RawNode } from '../index.js';
export default class PageIndicatorView extends YTNode {
    static type: string;
    indicator_count: number;
    selected_index: number;
    constructor(data: RawNode);
}
