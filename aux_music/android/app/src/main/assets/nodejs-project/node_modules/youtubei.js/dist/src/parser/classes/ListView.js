import { YTNode } from '../helpers.js';
import { Parser } from '../index.js';
import ListItemView from './ListItemView.js';
import DownloadListItemView from './DownloadListItemView.js';
import RendererContext from './misc/RendererContext.js';
export default class ListView extends YTNode {
    static type = 'ListView';
    items;
    renderer_context;
    constructor(data) {
        super();
        this.items = Parser.parseArray(data.listItems, [ListItemView, DownloadListItemView]);
        if ('rendererContext' in data) {
            this.renderer_context = new RendererContext(data.rendererContext);
        }
    }
}
//# sourceMappingURL=ListView.js.map