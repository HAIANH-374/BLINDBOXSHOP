import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  /// ID duy nhất của danh mục
  final String id;

  /// Tên danh mục
  final String name;

  /// Mô tả chi tiết về danh mục
  final String description;

  /// URL của hình ảnh đại diện danh mục
  final String imageUrl;

  /// Trạng thái kích hoạt của danh mục
  /// - true: Danh mục đang hiển thị
  /// - false: Danh mục bị ẩn
  final bool isActive;

  /// Thứ tự hiển thị của danh mục
  /// Số nhỏ hơn sẽ hiển thị trước
  final int order;

  /// Thời gian tạo danh mục
  final DateTime createdAt;

  /// Thời gian cập nhật gần nhất
  final DateTime updatedAt;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.isActive,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
  });

  // ============================================================
  // Business Logic Methods
  // ============================================================

  /// Kiểm tra danh mục có đang hoạt động không
  bool get isActiveCategory => isActive;

  /// Kiểm tra danh mục có bị vô hiệu hóa không
  bool get isInactive => !isActive;

  /// Kiểm tra danh mục có hình ảnh không
  bool get hasImage => imageUrl.isNotEmpty;

  /// Kiểm tra danh mục có mô tả không
  bool get hasDescription => description.isNotEmpty;

  /// Lấy tên hiển thị của danh mục
  /// Nếu tên trống, trả về "Không có tên"
  String get displayName => name.isEmpty ? 'Không có tên' : name;

  /// Lấy mô tả hiển thị của danh mục
  /// Nếu mô tả trống, trả về "Không có mô tả"
  String get displayDescription =>
      description.isEmpty ? 'Không có mô tả' : description;

  /// Lấy text trạng thái của danh mục
  String get statusText => isActive ? 'Đang hoạt động' : 'Đã vô hiệu hóa';

  /// Kiểm tra danh mục có phải mới tạo không
  /// (được tạo trong vòng 7 ngày)
  bool get isNew {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inDays <= 7;
  }

  /// Kiểm tra danh mục có được cập nhật gần đây không
  /// (được cập nhật trong vòng 3 ngày)
  bool get isRecentlyUpdated {
    final now = DateTime.now();
    final difference = now.difference(updatedAt);
    return difference.inDays <= 3;
  }

  /// Lấy số ngày kể từ khi tạo
  int get daysSinceCreated {
    final now = DateTime.now();
    return now.difference(createdAt).inDays;
  }

  /// Lấy số ngày kể từ lần cập nhật cuối
  int get daysSinceUpdated {
    final now = DateTime.now();
    return now.difference(updatedAt).inDays;
  }

  /// Format ngày tạo (dd/MM/yyyy)
  String get formattedCreatedDate {
    return '${createdAt.day.toString().padLeft(2, '0')}/'
        '${createdAt.month.toString().padLeft(2, '0')}/'
        '${createdAt.year}';
  }

  /// Format ngày cập nhật (dd/MM/yyyy)
  String get formattedUpdatedDate {
    return '${updatedAt.day.toString().padLeft(2, '0')}/'
        '${updatedAt.month.toString().padLeft(2, '0')}/'
        '${updatedAt.year}';
  }

  /// Format ngày giờ tạo đầy đủ (dd/MM/yyyy HH:mm)
  String get formattedCreatedDateTime {
    return '${formattedCreatedDate} '
        '${createdAt.hour.toString().padLeft(2, '0')}:'
        '${createdAt.minute.toString().padLeft(2, '0')}';
  }

  /// Format ngày giờ cập nhật đầy đủ (dd/MM/yyyy HH:mm)
  String get formattedUpdatedDateTime {
    return '${formattedUpdatedDate} '
        '${updatedAt.hour.toString().padLeft(2, '0')}:'
        '${updatedAt.minute.toString().padLeft(2, '0')}';
  }

  /// Kiểm tra danh mục có thể được kích hoạt không
  bool get canActivate => !isActive;

  /// Kiểm tra danh mục có thể được vô hiệu hóa không
  bool get canDeactivate => isActive;

  /// Kiểm tra danh mục có thể di chuyển lên không
  bool get canMoveUp => order > 0;

  /// Kiểm tra tên danh mục có hợp lệ không
  bool get hasValidName => name.trim().isNotEmpty && name.length >= 2;

  /// Kiểm tra thứ tự có hợp lệ không
  bool get hasValidOrder => order >= 0;

  /// Lấy emoji trạng thái
  String get statusEmoji => isActive ? '✅' : '❌';

  /// So sánh thứ tự với danh mục khác
  int compareOrderWith(CategoryEntity other) {
    return order.compareTo(other.order);
  }

  /// Kiểm tra có cùng thứ tự với danh mục khác không
  bool hasSameOrderAs(CategoryEntity other) {
    return order == other.order;
  }

  /// Kiểm tra có thứ tự cao hơn danh mục khác không
  bool hasHigherOrderThan(CategoryEntity other) {
    return order > other.order;
  }

  /// Kiểm tra có thứ tự thấp hơn danh mục khác không
  bool hasLowerOrderThan(CategoryEntity other) {
    return order < other.order;
  }

  /// Tạo bản sao với các thuộc tính được cập nhật
  CategoryEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    bool? isActive,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    imageUrl,
    isActive,
    order,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() {
    return 'CategoryEntity('
        'id: $id, '
        'name: $name, '
        'isActive: $isActive, '
        'order: $order'
        ')';
  }
}

/// Entity chứa thống kê về danh mục
class CategoryStatsEntity extends Equatable {
  /// Tổng số danh mục
  final int totalCategories;

  /// Số danh mục đang hoạt động
  final int activeCategories;

  /// Số danh mục không hoạt động
  final int inactiveCategories;

  const CategoryStatsEntity({
    required this.totalCategories,
    required this.activeCategories,
    required this.inactiveCategories,
  });

  /// Phần trăm danh mục đang hoạt động
  double get activePercentage {
    if (totalCategories == 0) return 0.0;
    return (activeCategories / totalCategories) * 100;
  }

  /// Phần trăm danh mục không hoạt động
  double get inactivePercentage {
    if (totalCategories == 0) return 0.0;
    return (inactiveCategories / totalCategories) * 100;
  }

  /// Kiểm tra có danh mục nào không
  bool get hasCategories => totalCategories > 0;

  /// Kiểm tra có danh mục đang hoạt động không
  bool get hasActiveCategories => activeCategories > 0;

  /// Kiểm tra có danh mục không hoạt động không
  bool get hasInactiveCategories => inactiveCategories > 0;

  /// Kiểm tra tất cả danh mục có đang hoạt động không
  bool get allCategoriesActive =>
      totalCategories > 0 && activeCategories == totalCategories;

  /// Kiểm tra không có danh mục nào hoạt động
  bool get noCategoriesActive => activeCategories == 0;

  @override
  List<Object?> get props => [
    totalCategories,
    activeCategories,
    inactiveCategories,
  ];

  @override
  String toString() {
    return 'CategoryStatsEntity('
        'total: $totalCategories, '
        'active: $activeCategories, '
        'inactive: $inactiveCategories'
        ')';
  }
}
