# Gravity Field Zone - Vùng Trọng Lực Tùy Chỉnh

## 📖 Mô tả
Vùng thay đổi hướng và cường độ trọng lực. Khác với GravityZone (hút vào tâm), GravityFieldZone chỉ thay đổi vector trọng lực trong vùng.

## 🎮 Cách sử dụng

### 1. Thêm vào Scene:
- Kéo `CHiTAN/GravityFieldZone.tscn` vào Level
- Hoặc tạo Area2D mới và attach script `GravityFieldZone.gd`

### 2. Tùy chỉnh trong Inspector:

#### **Gravity Settings:**
- **`custom_gravity`** (Vector2): Hướng và cường độ trọng lực
  - `(0, 980)`: Trọng lực bình thường xuống dưới
  - `(0, -980)`: Trọng lực ngược lên trên (anti-gravity)
  - `(980, 0)`: Trọng lực sang phải
  - `(-980, 0)`: Trọng lực sang trái
  - `(490, 490)`: Trọng lực chéo 45°

- **`gravity_multiplier`** (1.0): Hệ số nhân
  - `0.0`: Không trọng lực (lơ lửng)
  - `0.5`: Giảm một nửa (Moon gravity)
  - `1.0`: Bình thường
  - `2.0`: Gấp đôi (Jupiter gravity)

- **`override_gravity`** (true): 
  - `true`: Thay thế hoàn toàn gravity Godot
  - `false`: Cộng thêm vào gravity gốc

#### **Zone Shape:**
- **`use_rectangle`** (true): Dùng hình chữ nhật hay hình tròn?
- **`zone_width`** / **`zone_height`**: Kích thước nếu dùng rectangle
- **`zone_radius`**: Bán kính nếu dùng circle

#### **Visual Settings:**
- **`show_debug_area`**: Hiển thị vùng debug
- **`show_gravity_arrows`**: Hiển thị mũi tên chỉ hướng gravity
- **`area_color`** / **`border_color`**: Màu sắc

## 💡 Presets:

### 1. Trọng Lực Ngược (Upside Down)
```
custom_gravity = Vector2(0, -980)
gravity_multiplier = 1.0
override_gravity = true
```
→ Player rơi lên trời!

### 2. Trọng Lực Ngang Trái (Wall Gravity Left)
```
custom_gravity = Vector2(-980, 0)
gravity_multiplier = 1.0
override_gravity = true
```
→ Player rơi sang trái như đi trên tường!

### 3. Không Trọng Lực (Zero Gravity / Space)
```
custom_gravity = Vector2(0, 0)
gravity_multiplier = 0.0
override_gravity = true
```
→ Player lơ lửng hoàn toàn!

### 4. Mặt Trăng (Low Gravity)
```
custom_gravity = Vector2(0, 980)
gravity_multiplier = 0.3
override_gravity = true
```
→ Nhảy cao, rơi chậm!

### 5. Trọng Lực Xoáy (Diagonal Gravity)
```
custom_gravity = Vector2(700, 700)
gravity_multiplier = 1.0
override_gravity = true
```
→ Rơi chéo 45° sang phải dưới!

### 6. Gió Mạnh (Wind Effect)
```
custom_gravity = Vector2(500, 0)
override_gravity = false  # Cộng thêm
```
→ Vẫn rơi xuống nhưng bị gió thổi ngang!

## 🎯 Tips:

1. **Kết hợp nhiều zones**: Tạo puzzle với nhiều vùng gravity khác nhau
2. **Rotating zones**: Attach vào Node2D và rotate để tạo gravity xoay
3. **Tween gravity**: Dùng script để thay đổi `custom_gravity` theo thời gian
4. **Maze puzzle**: Tạo mê cung với gravity thay đổi ở mỗi phòng

## ⚖️ So sánh với GravityZone:

| Feature | GravityZone | GravityFieldZone |
|---------|-------------|------------------|
| Hiệu ứng | Hút vào tâm (black hole) | Thay đổi gravity (field) |
| Hướng | Luôn về tâm zone | Theo vector tùy chỉnh |
| Cường độ | Giảm dần theo khoảng cách | Đồng đều trong vùng |
| Use case | Lỗ đen, nam châm | Anti-gravity, wall walk |

## 🔧 Yêu cầu:
- Player script đã được cập nhật với logic check `gravity_field_zones` group
- Player trong group `"player"`

## 🐛 Debug:
- Bật `show_debug_area = true` và `show_gravity_arrows = true`
- Mũi tên vàng chỉ hướng gravity
- Console hiển thị khi player vào/ra zone
