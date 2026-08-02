import { YTNode } from '../helpers.js';
import type { RawNode } from '../index.js';
export default class ThumbnailOverlayTitleView extends YTNode {
    static type: string;
    title: string;
    subtitle: string;
    constructor(data: RawNode);
}
