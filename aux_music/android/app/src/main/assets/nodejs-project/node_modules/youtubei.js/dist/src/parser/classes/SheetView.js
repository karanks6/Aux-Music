import { YTNode } from '../helpers.js';
import { Parser } from '../index.js';
import RendererContext from './misc/RendererContext.js';
export default class SheetView extends YTNode {
    static type = 'SheetView';
    content;
    footer;
    header;
    renderer_context;
    constructor(data) {
        super();
        this.content = Parser.parseItem(data.content);
        this.footer = Parser.parseItem(data.footer);
        this.header = Parser.parseItem(data.header);
        if ('rendererContext' in data) {
            this.renderer_context = new RendererContext(data.rendererContext);
        }
    }
}
//# sourceMappingURL=SheetView.js.map