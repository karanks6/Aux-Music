import { YTNode } from '../helpers.js';
import { type RawNode } from '../index.js';
import RendererContext from './misc/RendererContext.js';
export default class SheetView extends YTNode {
    static type: string;
    content: YTNode | null;
    footer: YTNode | null;
    header: YTNode | null;
    renderer_context?: RendererContext;
    constructor(data: RawNode);
}
