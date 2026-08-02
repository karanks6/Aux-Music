import { YTNode, type ObservedArray } from '../helpers.js';
import { type RawNode } from '../index.js';
import RendererContext from './misc/RendererContext.js';
import ChipView from './ChipView.js';
export default class ChipBarView extends YTNode {
    static type: string;
    chips: ObservedArray<ChipView>;
    chip_bar_state_entity_key?: string;
    renderer_context?: RendererContext;
    constructor(data: RawNode);
}
