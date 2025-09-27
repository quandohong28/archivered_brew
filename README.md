# Archived Homebrew Installer

Một script giúp cài đặt **Homebrew** cho các bản macOS cũ (High Sierra → Sonoma) bằng cách sử dụng lại installer script tại commit tương ứng.  
Ngoài ra còn có bước sync `homebrew/core`, update, doctor và cleanup theo flow giống Homebrew chính thức.

## 🚀 Tính năng

- Hỗ trợ nhiều bản macOS:
  - `high_sierra`
  - `mojave`
  - `catalina`
  - `big_sur`
  - `monterey`
  - `ventura`
  - `sonoma`
- Có thể chạy installer từ **local file** hoặc tải trực tiếp từ GitHub.
- Chế độ **dry-run** (`--dry-run`) để test trước mà không thực sự chạy lệnh.
- Sync `homebrew/core` về branch `main`.
- Chạy `brew update`, `brew doctor` và untap `homebrew/core`.
- Log màu sắc cho dễ đọc.

## 📦 Yêu cầu

- macOS (10.13 High Sierra trở lên)

## 🔧 Cách dùng

Clone repo này:

```bash
git clone https://github.com/yourname/archived-brew.git
cd archived-brew
chmod +x auto_run.sh
```

Chạy script với quyền `sudo`:

```bash
sudo ./auto_run.sh --macos-version <version> [--local-file <path>] [--dry-run]
```

Tham số:
- `--version <macos version>`: Bắt buộc. Chọn bản macOS từ danh sách trên.
- `--local <boolean>`: Tùy chọn. Nếu có, sử dụng file installer local thay vì tải từ GitHub.