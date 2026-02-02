# Hướng dẫn Checkpoint cho Special Level

## Vấn đề
Special Level và Level thường đang dùng chung checkpoint script, gây ra lỗi khi hoàn thành Special Level nó sẽ cố gắng chuyển sang level theo số (VD: Level 1, 2, 3...) thay vì quay về menu hoặc nơi đã chỉ định.

## Giải pháp
Đã tạo `checkpoint_special.gd` - một script checkpoint riêng cho Special Level với các tính năng:

### Tính năng chính
1. **TÁCH BIỆT hoàn toàn** với hệ thống level number
2. **Không ảnh hưởng** đến `current_level` của level thường
3. **Linh hoạt** với 3 tùy chọn khi hoàn thành:
   - `Back to Menu`: Quay về menu chính
   - `Custom Scene`: Chuyển đến scene bất kỳ
   - `Level Select`: Quay về màn hình chọn level

### Cách sử dụng

#### Bước 1: Tạo checkpoint scene cho Special Level
Nếu chưa có checkpoint scene, tạo mới hoặc copy từ checkpoint thường.

#### Bước 2: Đổi script
Trong Inspector của checkpoint node:
- Xóa script cũ (`checkpoint.gd`)
- Gán script mới: `res://All_Level/Special_Level/Special_Level_1/scenes/checkpoint_special.gd`

#### Bước 3: Cấu hình trong Inspector

**Export Variables:**
- **Completion Action**: Chọn hành động khi hoàn thành
  - `Back to Menu` (mặc định)
  - `Custom Scene` 
  - `Level Select`
  
- **Next Scene Path**: Đường dẫn scene tiếp theo (dùng khi chọn Custom Scene)
  - VD: `res://Scene Main Start/main.tscn`
  
- **Special Level Name**: Tên hiển thị trong console
  - VD: `"SPECIAL LEVEL 1"`
  
- **Wait Time**: Thời gian chờ (giây) trước khi chuyển scene
  - Mặc định: `2.0`

### Ví dụ cấu hình

#### Special Level 1 - Quay về menu
```
Completion Action: "Back to Menu"
Special Level Name: "SPECIAL LEVEL 1"
Wait Time: 2.0
```

#### Special Level 2 - Chuyển sang Special Level 3
```
Completion Action: "Custom Scene"
Next Scene Path: "res://All_Level/Special_Level/Special_Level_3/Special_Level_3.tscn"
Special Level Name: "SPECIAL LEVEL 2"
Wait Time: 2.0
```

## Files liên quan
- **Script mới**: `All_Level/Special_Level/Special_Level_1/scenes/checkpoint_special.gd`
- **Script cũ** (dùng cho level thường): `Checkpoint/Level_X/checkpoint.gd`

## Lưu ý
- ✅ Level thường (1-50) vẫn dùng checkpoint cũ bình thường
- ✅ Special Level dùng checkpoint_special.gd
- ✅ Không xung đột với nhau
- ✅ Có thể copy checkpoint_special.gd sang các Special Level khác

## Debug
Khi hoàn thành Special Level, console sẽ hiển thị:
```
✨ Special checkpoint ready: SPECIAL LEVEL 1
🎉 SPECIAL LEVEL 1 COMPLETED! 🎉
🎯 Action: Back to Menu
🏠 Returning to main menu...
```
