# 🎬 HƯỚNG DẪN CREDITS SCENE

## 📝 Cách chỉnh sửa Credits

### 1. Mở file `UI/Credits.tscn` trong Godot Editor

### 2. Chỉnh sửa nội dung:

#### **Title (Tiêu đề game):**
- Node: `ScrollContainer/VBoxContainer/Title`
- Text: Đổi "GAME TROLL" thành tên game của bạn

#### **Thank You Message:**
- Node: `ScrollContainer/VBoxContainer/ThankYou`
- Chỉnh sửa lời cảm ơn người chơi

#### **Development Team (Đội ngũ phát triển):**
- Node: `ScrollContainer/VBoxContainer/Credits1`
- Format:
```
[b]Chức vụ[/b]
Tên người 1
Tên người 2

[b]Chức vụ khác[/b]
Tên người
```

#### **Special Thanks (Lời cảm ơn đặc biệt):**
- Node: `ScrollContainer/VBoxContainer/Thanks`
- Thêm tên người/tổ chức muốn cảm ơn

### 3. Tùy chỉnh trong code `UI/Credits.gd`:

```gdscript
@export var scroll_speed: float = 50.0  # Tốc độ scroll (càng cao càng nhanh)
@export var auto_scroll: bool = true     # Tự động scroll hay không
```

---

## 🎮 Cách hoạt động:

1. **Hoàn thành Level 20** → WinScene hiển thị
2. **Click "📜 XEM CREDITS"** → Credits scroll tự động
3. **ESC hoặc Click "Skip"** → Quay về Main Menu
4. **Scroll hết** → Tự động quay về Menu sau 3 giây

---

## 🎨 Màu sắc sử dụng:

- **Title**: Vàng (#FFE64D)
- **Subtitle**: Xám nhạt (#CCCCCC)
- **Development Team**: Vàng cam (#FFCC33)
- **Special Thanks**: Hồng nhạt (#FF99CC)
- **Background**: Tím đậm (#1A0D26)

---

## ✨ Tính năng:

- ✅ Auto scroll mượt mà
- ✅ Hiển thị thống kê (số lần chết, level hoàn thành)
- ✅ Skip bằng ESC
- ✅ Tự động quay về menu khi xem xong
- ✅ Scroll thủ công bằng mũi tên

---

## 📋 Ví dụ Credits:

```
GAME TROLL
Cảm ơn bạn đã chơi!

ĐỘI NGŨ PHÁT TRIỂN

Game Design & Programming
CHiTAN
Meri1405

Level Design
CHiTAN Team

Art & Graphics
Pixel Adventure Assets

Testing & QA
Community Players

LỜI CẢM ƠN ĐẶC BIỆT

Cảm ơn Godot Engine
Cảm ơn cộng đồng Godot Việt Nam
Đặc biệt cảm ơn BẠN!

THỐNG KÊ CỦA BẠN
Số lần chết: 999
Cấp độ hoàn thành: 20/20

Hẹn gặp lại trong các dự án tiếp theo!
© 2025 Game Troll Team
```

---

## 🔧 Debug:

Nếu Credits không hiển thị đúng:
1. Check console log xem có lỗi không
2. Kiểm tra `GameManager` có tồn tại không
3. Thử chạy Credits trực tiếp: F6 trong Godot Editor

---

## 💡 Tips:

- Dùng [b]...[/b] để in đậm
- Dùng [color=red]...[/color] để đổi màu
- Dùng [center]...[/center] để căn giữa
- Thêm Spacer để tạo khoảng trống giữa các phần
