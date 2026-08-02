import { YTNode } from '../helpers.js';
import { Text } from '../misc.js';
export default class PlayerCaptchaView extends YTNode {
    static type = 'PlayerCaptchaView';
    captcha_loading_message;
    challenge_reason;
    captcha_successful_message;
    captcha_cookie_set_failure_message;
    captcha_failed_message;
    constructor(data) {
        super();
        if ('captchaLoadingMessage' in data) {
            this.captcha_loading_message = Text.fromAttributed(data.captchaLoadingMessage);
        }
        if ('challengeReason' in data) {
            this.challenge_reason = Text.fromAttributed(data.challengeReason);
        }
        if ('captchaSuccessfulMessage' in data) {
            this.captcha_successful_message = Text.fromAttributed(data.captchaSuccessfulMessage);
        }
        if ('captchaCookieSetFailureMessage' in data) {
            this.captcha_cookie_set_failure_message = Text.fromAttributed(data.captchaCookieSetFailureMessage);
        }
        if ('captchaFailedMessage' in data) {
            this.captcha_failed_message = Text.fromAttributed(data.captchaFailedMessage);
        }
    }
}
//# sourceMappingURL=PlayerCaptchaView.js.map