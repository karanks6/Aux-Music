import { YTNode } from '../../helpers.js';
import { Parser } from '../../index.js';
import VideoViewCount from '../VideoViewCount.js';
export default class UpdateViewershipAction extends YTNode {
    static type = 'UpdateViewershipAction';
    view_count_node;
    /**
     * @deprecated Use `view_count_node.view_count` instead.
     */
    get view_count() {
        return this.view_count_node?.view_count;
    }
    /**
     * @deprecated Use `view_count_node.extra_short_view_count` instead.
     */
    get extra_short_view_count() {
        return this.view_count_node?.extra_short_view_count;
    }
    /**
     * @deprecated Use `view_count_node.short_view_count` instead.
     */
    get short_view_count() {
        return this.view_count_node?.short_view_count;
    }
    /**
     * @deprecated Use `view_count_node.original_view_count` instead.
     */
    get original_view_count() {
        return this.view_count_node?.original_view_count;
    }
    /**
     * @deprecated Use `view_count_node.unlabeled_view_count_value` instead.
     */
    get unlabeled_view_count_value() {
        return this.view_count_node?.unlabeled_view_count_value;
    }
    /**
     * @deprecated Use `view_count_node.is_live` instead.
     */
    get is_live() {
        return this.view_count_node?.is_live;
    }
    constructor(data) {
        super();
        this.view_count_node = Parser.parseItem(data.viewCount, VideoViewCount);
    }
}
//# sourceMappingURL=UpdateViewershipAction.js.map