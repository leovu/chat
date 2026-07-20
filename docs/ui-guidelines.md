# UI Guidelines — chat

## Color Palette
```dart
// Xem lib/core/theme/app_colors.dart
primary:    #XXXXXX
secondary:  #XXXXXX
error:      #EF4444
success:    #22C55E
warning:    #F59E0B
background: #FFFFFF
surface:    #F8F8F8
```

## Typography
```dart
// Xem lib/core/theme/app_text_styles.dart
heading1:  fontSize: 24, fontWeight: bold
heading2:  fontSize: 20, fontWeight: bold
body:      fontSize: 14, fontWeight: normal
caption:   fontSize: 12, fontWeight: normal
```

## Spacing
- Sử dụng bội số của 4: 4, 8, 12, 16, 24, 32
- Margin ngoài màn hình: 16px horizontal
- Khoảng cách giữa sections: 24px

## Components

### Buttons
- Primary: filled, 48px height, border-radius 8px
- Secondary: outlined, cùng kích thước
- Text button: không có background

### Input Fields
- Height: 48px
- Border-radius: 8px
- Error state: border đỏ + error text bên dưới

### Cards
- Border-radius: 12px
- Shadow: elevation 2
- Padding: 16px

## Responsive Breakpoints
```dart
mobile:  < 600px
tablet:  600px - 900px
desktop: > 900px
```

## Accessibility
- Minimum touch target: 44x44px
- Contrast ratio >= 4.5:1 cho body text
- Semantics labels cho icons và images
