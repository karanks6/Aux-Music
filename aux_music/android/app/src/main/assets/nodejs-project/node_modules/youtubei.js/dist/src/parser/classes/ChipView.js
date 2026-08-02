import { YTNode } from '../helpers.js';
import NavigationEndpoint from './NavigationEndpoint.js';
export default class ChipView extends YTNode {
    static type = 'ChipView';
    accessibility_hint;
    accessibility_label;
    text;
    trailing_text;
    display_type;
    max_text_width;
    secondary_accessibility_label;
    original_text;
    tap_command;
    secondary_tap_command;
    chip_entity_key;
    selected;
    get endpoint() {
        return this.tap_command;
    }
    constructor(data) {
        super();
        if ('accessibilityHint' in data) {
            this.accessibility_hint = data.accessibilityHint;
        }
        if ('accessibilityLabel' in data) {
            this.accessibility_label = data.accessibilityLabel;
        }
        if ('chipEntityKey' in data) {
            this.chip_entity_key = data.chipEntityKey;
        }
        if ('text' in data) {
            this.text = data.text;
        }
        if ('trailingText' in data) {
            this.trailing_text = data.trailingText;
        }
        if ('displayType' in data) {
            this.display_type = data.displayType;
        }
        if ('maxTextWidth' in data) {
            this.max_text_width = data.maxTextWidth;
        }
        if ('originalText' in data) {
            this.original_text = data.originalText;
        }
        if ('secondaryAccessibilityLabel' in data) {
            this.secondary_accessibility_label = data.secondaryAccessibilityLabel;
        }
        if ('tapCommand' in data) {
            this.tap_command = new NavigationEndpoint(data.tapCommand);
        }
        if ('secondaryTapCommand' in data) {
            this.secondary_tap_command = new NavigationEndpoint(data.secondaryTapCommand);
        }
        this.selected = !!data.selected;
    }
}
//# sourceMappingURL=ChipView.js.map