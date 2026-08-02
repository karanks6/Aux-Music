import type { RawNode } from '../types/RawResponse.js';
import { YTNode } from '../helpers.js';
import NavigationEndpoint from './NavigationEndpoint.js';
interface ButtonContent {
    button_text: string;
    accessibility_text: string;
    image_name: string;
    subscribe_state_subscribed: boolean;
    endpoint: NavigationEndpoint;
}
interface BellAccessibilityData {
    off_label?: string;
    all_label?: string;
    occasional_label?: string;
    disabled_label?: string;
}
interface ButtonStyle {
    unsubscribed_state_style?: string;
    subscribed_state_style?: string;
}
export default class SubscribeButtonView extends YTNode {
    #private;
    static type: string;
    subscribe_button_content: ButtonContent;
    unsubscribe_button_content: ButtonContent;
    disable_notification_bell: boolean;
    button_style?: ButtonStyle;
    is_signed_out: boolean;
    background_style: string;
    disable_subscribe_button: boolean;
    on_show_subscription_options?: NavigationEndpoint;
    channel_id: string;
    enable_subscribe_button_post_click_animation: boolean;
    bell_accessibility_data?: BellAccessibilityData;
    constructor(data: RawNode);
}
export {};
