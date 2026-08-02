import { Text } from '../misc.js';
import { YTNode } from '../helpers.js';
import type { RawNode } from '../index.js';
export default class VideoViewCount extends YTNode {
    static type: string;
    original_view_count?: number;
    unlabeled_view_count_value?: Text;
    short_view_count?: Text;
    extra_short_view_count?: Text;
    view_count?: Text;
    is_live: boolean;
    constructor(data: RawNode);
}
