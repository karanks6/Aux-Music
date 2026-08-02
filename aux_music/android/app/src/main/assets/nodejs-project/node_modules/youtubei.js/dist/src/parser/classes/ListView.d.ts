import type { ObservedArray } from '../helpers.js';
import type { RawNode } from '../types/RawResponse.js';
import { YTNode } from '../helpers.js';
import ListItemView from './ListItemView.js';
import DownloadListItemView from './DownloadListItemView.js';
import RendererContext from './misc/RendererContext.js';
export default class ListView extends YTNode {
    static type: string;
    items: ObservedArray<ListItemView | DownloadListItemView>;
    renderer_context?: RendererContext;
    constructor(data: RawNode);
}
