import { YTNode } from '../helpers.js';
import { Parser } from '../index.js';
import DislikeButtonView from './DislikeButtonView.js';
import LikeButtonView from './LikeButtonView.js';
import VideoSummaryParagraphView from './VideoSummaryParagraphView.js';
export default class VideoSummaryContentView extends YTNode {
    static type = 'VideoSummaryContentView';
    dislike_button_view;
    like_button_view;
    paragraphs;
    constructor(data) {
        super();
        if ('dislikeButtonViewModel' in data) {
            this.dislike_button_view = Parser.parseItem(data.dislikeButtonViewModel, DislikeButtonView);
        }
        if ('likeButtonViewModel' in data) {
            this.like_button_view = Parser.parseItem(data.likeButtonViewModel, LikeButtonView);
        }
        this.paragraphs = Parser.parseArray(data.paragraphs, VideoSummaryParagraphView);
    }
}
//# sourceMappingURL=VideoSummaryContentView.js.map