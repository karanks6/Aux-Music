import { YTNode } from '../helpers.js';
import { Text } from '../misc.js';
export default class VideoSummaryParagraphView extends YTNode {
    static type = 'VideoSummaryParagraphView';
    text;
    constructor(data) {
        super();
        this.text = Text.fromAttributed(data.text);
    }
}
//# sourceMappingURL=VideoSummaryParagraphView.js.map