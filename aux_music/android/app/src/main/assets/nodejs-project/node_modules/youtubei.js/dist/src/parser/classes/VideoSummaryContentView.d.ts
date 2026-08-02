import type { ObservedArray } from '../helpers.js';
import { YTNode } from '../helpers.js';
import { type RawNode } from '../index.js';
import DislikeButtonView from './DislikeButtonView.js';
import LikeButtonView from './LikeButtonView.js';
import VideoSummaryParagraphView from './VideoSummaryParagraphView.js';
export default class VideoSummaryContentView extends YTNode {
    static type: string;
    dislike_button_view?: DislikeButtonView | null;
    like_button_view?: LikeButtonView | null;
    paragraphs: ObservedArray<VideoSummaryParagraphView>;
    constructor(data: RawNode);
}
