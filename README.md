# bas_pay_flutter

Flutter plugin for the BAS Payment SDK on Android, iOS, and Web.

## Supported platforms

| Platform | Integration |
|----------|-------------|
| Android | Native WebView via bundled `bas_pay` AAR + method channel |
| iOS | Native WebView via `bas_pay` XCFramework + method channel |
| Web | Hosted payment UI in a popup + `postMessage` result bridge |

## Usage

```dart
import 'package:bas_pay_flutter/bas_pay_flutter.dart';
import 'package:bas_pay_flutter/models/init_bas_sdk_model.dart';

final BasPayFlutter basPay = BasPayFlutter();

final InitBasSdkModel model = InitBasSdkModel.dev(
  trxToken: 'your-trx-token',
  userIdentifier: '733733733', // optional
  language: 'ar', // optional, default ar
);
// or InitBasSdkModel.prod(...) / InitBasSdkModel.sandbox(...)

final result = await basPay.callBasPay(model: model);

if (result.resultStatus && result.resultModel?.status == true) {
  // payment success
} else {
  // handle failure: result.resultModel?.message
}
```

## Flutter Web

On web, `callBasPay()` opens the hosted BAS Pay app in a popup window:

- **Production:** `https://bas-pay.web.app` (use `InitBasSdkModel.prod`)
- **Development:** `https://bas-pay-dev.web.app` (use `InitBasSdkModel.dev`)
- **Sandbox:** `https://bas-pay-sandbox.web.app` (use `InitBasSdkModel.sandbox`)

The popup returns payment results to your app through `window.postMessage`. Your merchant app must call `callBasPay()` from a **user gesture** (for example a button `onPressed`). Browsers block popups opened without user interaction.

### Web requirements

1. Allow popups for your merchant domain.
2. Use a recent hosted SDK build that supports `embedded=popup` (deployed `bas_sdk_web`).
3. Call `callBasPay()` only after a tap/click.

### Web error codes

| Code | Meaning |
|------|---------|
| `601` | Popup blocked by the browser |
| `602` | User closed the popup before completing payment |
| `603` | Payment session timed out (default 30 minutes) |

### Local development

When testing against a locally served `bas_sdk_web` instance, postMessage origins from `http://localhost` and `http://127.0.0.1` are accepted.

To point the plugin at local hosting during development, change the base URL in `lib/web/bas_pay_host_urls.dart` or use the deployed `dev` / `sandbox` environment.

## Android setup

The plugin bundles `bas_pay-release.aar` and requires `BankySDKManager-release.aar` in `android/libs/`.

## iOS setup

Requires the `bas_pay` XCFramework linked by the plugin pod.

## Related projects

| Project | Role |
|---------|------|
| `bas_pay_library` | KMP native SDK source |
| `bas_sdk_web` | Hosted Flutter Web payment UI |
| `android-sample` | Native Android integration sample |
