import { YTNode } from '../helpers.js';
import { Text } from '../misc.js';
import { type RawNode } from '../index.js';
export default class PlayerCaptchaView extends YTNode {
    static type: string;
    captcha_loading_message?: Text;
    challenge_reason?: Text;
    captcha_successful_message?: Text;
    captcha_cookie_set_failure_message?: Text;
    captcha_failed_message?: Text;
    constructor(data: RawNode);
}
