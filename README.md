# Kế hoạch thiết kế ExercisesLessonSection tương tự GlucoseLessonSection

## Phân tích hiện trạng

Dựa trên mã nguồn đã cung cấp, bạn cần:
1. Tạo một widget ExercisesLessonSection tương tự như GlucoseLessonSection đã có
2. Sử dụng API `getSupportExercises()` từ AppRepository
3. Mở rộng GlucoseBloc để hỗ trợ tính năng fetch SupportExercises

## Kế hoạch thực hiện

### Bước 1: Tạo bloc mới cho ExercisesLesson

Tạo các file:
- `exercise_lesson_bloc.dart`: quản lý trạng thái và xử lý sự kiện
- `exercise_lesson_state.dart`: định nghĩa các trạng thái (loading, loaded, error)
- `exercise_lesson_event.dart`: định nghĩa các sự kiện (fetch, refresh)

### Bước 2: Mở rộng GlucoseBloc để hỗ trợ SupportExercises

Thêm:
- Trạng thái mới: `ExercisesLessonLoaded` vào glucose_bloc_state.dart
- Sự kiện mới: `FetchSupportExercises` vào glucose_bloc_event.dart
- Phương thức xử lý: `fetchSupportExercises()` trong glucose_bloc.dart

### Bước 3: Tạo widget ExercisesLessonSection

Dựa trên thiết kế của GlucoseLessonSection nhưng thay đổi:
- Tiêu đề và nội dung phù hợp với bài tập
- Kết nối với bloc mới ExercisesLessonBloc

## Các câu prompt cho từng bước thực hiện

### Prompt 1: Tạo bloc cho ExercisesLesson
```
Hãy thiết kế các file bloc cho ExercisesLesson gồm:
1. exercise_lesson_bloc.dart: quản lý logic tải dữ liệu từ API getSupportExercises()
2. exercise_lesson_state.dart: định nghĩa các trạng thái của bloc (initial, loading, loaded, error)
3. exercise_lesson_event.dart: định nghĩa sự kiện FetchExercisesLesson
Chỉ cần mô tả cấu trúc và vai trò của mỗi file, không cần code cụ thể.
```

### Prompt 2: Mở rộng GlucoseBloc
```
Hãy mô tả cách mở rộng GlucoseBloc để hỗ trợ tính năng lấy dữ liệu SupportExercises:
1. Thêm trạng thái ExercisesLessonLoaded trong glucose_bloc_state.dart
2. Thêm sự kiện FetchSupportExercises trong glucose_bloc_event.dart
3. Thêm phương thức fetchSupportExercises() trong glucose_bloc.dart
Chỉ cần mô tả cụ thể những gì cần thêm vào, không cần code chi tiết.
```

### Prompt 3: Thiết kế widget ExercisesLessonSection
```
Hãy thiết kế widget ExercisesLessonSection dựa trên mẫu GlucoseLessonSection:
1. Cấu trúc chung của widget (chức năng và thành phần chính)
2. Các thành phần UI cần thay đổi so với GlucoseLessonSection
3. Cách kết nối với bloc và hiển thị dữ liệu ExerciseLesson
4. Xử lý sự kiện người dùng (chọn lesson, scroll)
Không cần code chi tiết, chỉ mô tả cấu trúc và chức năng.
```

### Prompt 4: Kế hoạch tích hợp các thành phần
```
Hãy đưa ra kế hoạch tích hợp các thành phần đã thiết kế:
1. Thứ tự triển khai các thành phần
2. Cách sử dụng ExercisesLessonSection trong màn hình chính
3. Cách kết nối với repository và bloc
4. Các điểm cần lưu ý khi tích hợp
Chỉ cần mô tả quy trình và các bước thực hiện, không cần code.
```

### Prompt 5: Kiểm thử và xử lý lỗi
```
Hãy đề xuất kế hoạch kiểm thử và xử lý lỗi cho ExercisesLessonSection:
1. Các kịch bản kiểm thử cần thiết
2. Cách xử lý các trường hợp lỗi (kết nối mạng, dữ liệu trống)
3. Cách hiển thị thông báo lỗi hoặc trạng thái loading
4. Tối ưu hiệu suất khi hiển thị danh sách bài tập
Chỉ cần đề xuất ý tưởng và phương pháp, không cần code chi tiết.
```
