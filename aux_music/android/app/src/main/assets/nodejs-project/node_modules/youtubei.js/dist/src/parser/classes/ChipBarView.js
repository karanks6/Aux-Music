import { YTNode } from '../helpers.js';
import { Parser } from '../index.js';
import RendererContext from './misc/RendererContext.js';
import ChipView from './ChipView.js';
export default class ChipBarView extends YTNode {
    static type = 'ChipBarView';
    chips;
    chip_bar_state_entity_key;
    renderer_context;
    constructor(data) {
        super();
        this.chips = Parser.parseArray(data.chips, ChipView);
        this.chip_bar_state_entity_key = data.chipBarStateEntityKey;
        if ('rendererContext' in data) {
            this.renderer_context = new RendererContext(data.rendererContext);
        }
    }
}
//# sourceMappingURL=ChipBarView.js.map