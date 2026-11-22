# GetApps Privileged – module KernelSU

Biến **Xiaomi GetApps** (`com.xiaomi.market`) thành priv-app trong `/product/priv-app/MiuiMarket` để nó có quyền `INSTALL_PACKAGES` và cài app ngầm như máy gốc.

Dành cho ROM port/ROM sửa không cài sẵn GetApps. Trên các ROM này, GetApps chỉ là app thường. Khi cài app, hệ thống trả về `STATUS_PENDING_USER_ACTION` (`status=-1`), GetApps coi đó là lỗi (error 13) và báo **"Couldn't download"**.

Đã thử trên Redmi K40S (`munch`) chạy HyperOS 4.0 (Android 17), KernelSU (ReSukiSU), với GetApps 4.94.0 và 4.131.s.00.

## Module không kèm APK

Zip **không chứa APK** của Xiaomi. Khi flash, `customize.sh` lấy APK theo thứ tự:

1. `apk/*.apk` trong zip (nếu bạn tự build kèm APK, chỉ để dùng cá nhân);
2. `/sdcard/GetApps/*.apk`;
3. bản GetApps **đang cài trên máy** (`pm path com.xiaomi.market`).

Script cũng giải nén các thư viện `lib/arm64-v8a/*.so` ra cạnh APK, vì app hệ thống không tự giải nén thư viện native.

## Cài đặt

1. Cài GetApps như app thường (hoặc chép APK vào `/sdcard/GetApps/`).
2. KernelSU → Module → Cài đặt → chọn `getapps_privapp.zip` → khởi động lại.
3. Kiểm tra:
   ```sh
   adb shell dumpsys package com.xiaomi.market | grep -E "codePath|PRIVILEGED|INSTALL_PACKAGES: granted"
   ```

## GetApps crash ngay khi mở

KernelSU mặc định **gỡ mount module** khỏi các app không có root. Nếu GetApps chạy trực tiếp từ module (`codePath=/product/priv-app/MiuiMarket`), nó sẽ không thấy APK của chính nó và crash (`DexPathList[[]]`). Có hai cách:

- **Cách A:** KernelSU → Superuser → GetApps → App Profile *Custom* → tắt **Umount modules**.
- **Cách B (giữ được umount):** để GetApps chạy từ **bản cập nhật trong `/data`**. Chỉ cần cập nhật GetApps (trong app hoặc `adb install -r`) lên bản **mới hơn hoặc bằng** bản trong module. Khi đó code nằm trong `/data`, còn đặc quyền vẫn được giữ vì `system_server` vẫn thấy module. Đừng bấm "Gỡ cài đặt bản cập nhật" cho GetApps.

## Build

```sh
python build.py   # -> getapps_privapp.zip
```

## Gỡ

Tắt hoặc gỡ module trong KernelSU rồi khởi động lại. Nếu GetApps không có bản cập nhật trong `/data`, app sẽ biến mất và cần cài lại như app thường. Nếu bị bootloop, vào safe mode của KernelSU (bấm giảm âm lượng nhiều lần khi khởi động).

## Lưu ý

- Với `ro.control_privapp_permissions=enforce`, mọi quyền đặc quyền mà GetApps xin đều phải có trong `privapp-permissions-getapps.xml`, nếu không máy sẽ bootloop. Hãy thêm các quyền còn thiếu vào file này.
- GetApps và mọi APK của Xiaomi thuộc bản quyền của Xiaomi. Repo này chỉ chứa script và file cấu hình.
