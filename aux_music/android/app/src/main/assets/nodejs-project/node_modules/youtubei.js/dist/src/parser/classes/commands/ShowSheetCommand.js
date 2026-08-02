import { YTNode } from '../../helpers.js';
import { Parser } from '../../index.js';
export default class ShowSheetCommand extends YTNode {
    static type = 'ShowSheetCommand';
    inline_content;
    remove_default_padding;
    constructor(data) {
        super();
        this.inline_content = Parser.parseItem(data.panelLoadingStrategy?.inlineContent);
        this.remove_default_padding = !!data.removeDefaultPadding;
    }
}
//# sourceMappingURL=ShowSheetCommand.js.map