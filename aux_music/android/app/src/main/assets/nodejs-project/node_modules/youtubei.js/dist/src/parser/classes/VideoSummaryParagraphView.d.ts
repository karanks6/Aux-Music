import { YTNode } from '../helpers.js';
import { type RawNode } from '../index.js';
import { Text } from '../misc.js';
export default class VideoSummaryParagraphView extends YTNode {
    static type: string;
    text: Text;
    constructor(data: RawNode);
}
