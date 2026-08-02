import { YTNode } from '../helpers.js';
import type { RawNode } from '../types/RawResponse.js';
import RendererContext from './misc/RendererContext.js';
export default class DownloadListItemView extends YTNode {
    static type: string;
    renderer_context?: RendererContext;
    constructor(data: RawNode);
}
