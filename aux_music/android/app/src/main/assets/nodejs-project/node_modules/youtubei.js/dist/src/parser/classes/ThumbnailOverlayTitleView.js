import { YTNode } from '../helpers.js';
export default class ThumbnailOverlayTitleView extends YTNode {
    static type = 'ThumbnailOverlayTitleView';
    title;
    subtitle;
    constructor(data) {
        super();
        this.title = data.title?.content ?? '';
        this.subtitle = data.subtitle?.content ?? '';
    }
}
//# sourceMappingURL=ThumbnailOverlayTitleView.js.map