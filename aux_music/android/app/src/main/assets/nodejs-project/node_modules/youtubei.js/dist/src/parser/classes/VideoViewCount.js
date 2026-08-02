import { Text } from '../misc.js';
import { YTNode } from '../helpers.js';
export default class VideoViewCount extends YTNode {
    static type = 'VideoViewCount';
    original_view_count;
    unlabeled_view_count_value;
    short_view_count;
    extra_short_view_count;
    view_count;
    is_live;
    constructor(data) {
        super();
        if ('originalViewCount' in data) {
            this.original_view_count = parseInt(data.originalViewCount);
        }
        if ('unlabeledViewCountValue' in data) {
            this.unlabeled_view_count_value = new Text(data.unlabeledViewCountValue);
        }
        if ('shortViewCount' in data) {
            this.short_view_count = new Text(data.shortViewCount);
        }
        if ('extraShortViewCount' in data) {
            this.extra_short_view_count = new Text(data.extraShortViewCount);
        }
        if ('viewCount' in data) {
            this.view_count = new Text(data.viewCount);
        }
        this.is_live = !!data.isLive;
    }
}
//# sourceMappingURL=VideoViewCount.js.map