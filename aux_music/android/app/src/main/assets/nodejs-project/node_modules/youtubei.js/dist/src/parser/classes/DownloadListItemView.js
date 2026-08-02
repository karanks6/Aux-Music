import { YTNode } from '../helpers.js';
import RendererContext from './misc/RendererContext.js';
export default class DownloadListItemView extends YTNode {
    static type = 'DownloadListItemView';
    renderer_context;
    constructor(data) {
        super();
        if ('rendererContext' in data) {
            this.renderer_context = new RendererContext(data.rendererContext);
        }
    }
}
//# sourceMappingURL=DownloadListItemView.js.map