import { YTNode } from '../helpers.js';
import { type RawNode } from '../index.js';
import ThumbnailView from './ThumbnailView.js';
interface StackColor {
    light_theme?: number;
    dark_theme?: number;
}
export default class CollectionThumbnailView extends YTNode {
    static type: string;
    primary_thumbnail: ThumbnailView | null;
    stack_color?: StackColor;
    constructor(data: RawNode);
}
export {};
