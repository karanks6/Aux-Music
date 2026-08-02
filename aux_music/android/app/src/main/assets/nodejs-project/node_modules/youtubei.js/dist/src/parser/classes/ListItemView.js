import { YTNode } from '../helpers.js';
import { Parser } from '../index.js';
import AvatarView from './AvatarView.js';
import RendererContext from './misc/RendererContext.js';
import SubscribeButtonView from './SubscribeButtonView.js';
import Text from './misc/Text.js';
export default class ListItemView extends YTNode {
    static type = 'ListItemView';
    title;
    subtitle;
    selection_text;
    selection_style;
    background_color;
    leading_accessory;
    trailing_button;
    trailing_buttons;
    is_disabled;
    is_selected;
    has_divider_below;
    renderer_context;
    constructor(data) {
        super();
        if ('title' in data) {
            this.title = Text.fromAttributed(data.title);
        }
        if ('subtitle' in data) {
            this.subtitle = Text.fromAttributed(data.subtitle);
        }
        if ('selectionText' in data) {
            this.selection_text = Text.fromAttributed(data.selectionText);
        }
        if ('selectionStyle' in data) {
            this.selection_style = data.selectionStyle;
        }
        if ('backgroundColor' in data) {
            this.background_color = parseInt(data.backgroundColor, 16);
        }
        this.leading_accessory = Parser.parseItem(data.leadingAccessory, AvatarView);
        this.trailing_buttons = Parser.parseArray(data.trailingButtons?.buttons, SubscribeButtonView);
        this.trailing_button = Parser.parseItem(data.trailingButton);
        this.is_disabled = !!data.isDisabled;
        this.is_selected = !!data.isSelected;
        this.has_divider_below = !!data.hasDividerBelow;
        if ('rendererContext' in data) {
            this.renderer_context = new RendererContext(data.rendererContext);
        }
    }
}
//# sourceMappingURL=ListItemView.js.map