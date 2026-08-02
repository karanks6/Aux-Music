import { YTNode } from '../helpers.js';
import { type RawNode } from '../index.js';
import NavigationEndpoint from './NavigationEndpoint.js';
export default class ChipView extends YTNode {
    static type: string;
    accessibility_hint?: string;
    accessibility_label?: string;
    text?: string;
    trailing_text?: string;
    display_type?: 'CHIP_VIEW_MODEL_DISPLAY_TYPE_UNSPECIFIED' | 'CHIP_VIEW_MODEL_DISPLAY_TYPE_DROP_DOWN' | 'CHIP_VIEW_MODEL_DISPLAY_TYPE_DROP_DOWN_WITH_CLEAR' | 'CHIP_VIEW_MODEL_DISPLAY_TYPE_FILTER' | 'CHIP_VIEW_MODEL_DISPLAY_TYPE_NO_ICON' | 'CHIP_VIEW_MODEL_DISPLAY_TYPE_ADJUST' | 'CHIP_VIEW_MODEL_DISPLAY_TYPE_CLEAR' | 'CHIP_VIEW_MODEL_DISPLAY_TYPE_ADD' | 'CHIP_VIEW_MODEL_DISPLAY_TYPE_SPARK';
    max_text_width?: number;
    secondary_accessibility_label?: string;
    original_text?: string;
    tap_command?: NavigationEndpoint;
    secondary_tap_command?: NavigationEndpoint;
    chip_entity_key?: string;
    selected: boolean;
    get endpoint(): NavigationEndpoint | undefined;
    constructor(data: RawNode);
}
