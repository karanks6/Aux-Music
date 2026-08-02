import type { ObservedArray } from '../helpers.js';
import type { RawNode } from '../types/RawResponse.js';
import { YTNode } from '../helpers.js';
import AvatarView from './AvatarView.js';
import RendererContext from './misc/RendererContext.js';
import SubscribeButtonView from './SubscribeButtonView.js';
import Text from './misc/Text.js';
export default class ListItemView extends YTNode {
    static type: string;
    title?: Text;
    subtitle?: Text;
    selection_text?: Text;
    selection_style?: 'LIST_ITEM_SELECTION_STYLE_UNSPECIFIED' | 'LIST_ITEM_SELECTION_STYLE_DEFAULT' | 'LIST_ITEM_SELECTION_STYLE_CHECKBOX' | 'LIST_ITEM_SELECTION_STYLE_RADIO' | 'LIST_ITEM_SELECTION_STYLE_TOGGLE';
    background_color?: number;
    leading_accessory: AvatarView | null;
    trailing_button: YTNode | null;
    trailing_buttons: ObservedArray<SubscribeButtonView>;
    is_disabled: boolean;
    is_selected: boolean;
    has_divider_below: boolean;
    renderer_context?: RendererContext;
    constructor(data: RawNode);
}
