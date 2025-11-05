// ignore: depend_on_referenced_packages
import 'package:equatable/equatable.dart';

class BannerEntity extends Equatable {
  /// ID duy nhất của banner
  final String id;

  /// Tiêu đề banner
  final String title;

  /// Phụ đề/mô tả ngắn
  final String subtitle;

  /// URL hình ảnh banner
  final String imageUrl;

  /// Loại liên kết (product, category, url, none)
  final String linkType;

  /// Giá trị liên kết (productId, categoryId, url, hoặc empty)
  final String linkValue;

  /// Trạng thái hiển thị
  final bool isActive;

  /// Thứ tự hiển thị
  final int order;

  /// Thời gian tạo
  final DateTime createdAt;

  /// Thời gian cập nhật
  final DateTime updatedAt;

  const BannerEntity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.linkType,
    required this.linkValue,
    required this.isActive,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Kiểm tra banner có đang hoạt động không
  bool get isActiveBanner => isActive;

  /// Kiểm tra banner có bị vô hiệu hóa không
  bool get isInactive => !isActive;

  /// Kiểm tra có hình ảnh không
  bool get hasImage => imageUrl.isNotEmpty;

  /// Kiểm tra có tiêu đề không
  bool get hasTitle => title.isNotEmpty;

  /// Kiểm tra có phụ đề không
  bool get hasSubtitle => subtitle.isNotEmpty;

  /// Kiểm tra có liên kết không
  bool get hasLink => linkType.isNotEmpty && linkType != 'none';

  /// Kiểm tra liên kết đến sản phẩm
  bool get isProductLink => linkType == 'product' && linkValue.isNotEmpty;

  /// Kiểm tra liên kết đến danh mục
  bool get isCategoryLink => linkType == 'category' && linkValue.isNotEmpty;

  /// Kiểm tra liên kết đến URL
  bool get isUrlLink => linkType == 'url' && linkValue.isNotEmpty;

  /// Kiểm tra không có liên kết
  bool get hasNoLink => linkType.isEmpty || linkType == 'none';

  /// Lấy text loại liên kết
  String get linkTypeText {
    switch (linkType) {
      case 'product':
        return 'Sản phẩm';
      case 'category':
        return 'Danh mục';
      case 'url':
        return 'Liên kết web';
      case 'none':
        return 'Không có';
      default:
        return 'Không xác định';
    }
  }

  /// Lấy text trạng thái
  String get statusText => isActive ? 'Đang hiển thị' : 'Đã ẩn';

  /// Lấy emoji trạng thái
  String get statusEmoji => isActive ? '✅' : '❌';

  /// Kiểm tra banner mới tạo (trong vòng 7 ngày)
  bool get isNew {
    final now = DateTime.now();
    return now.difference(createdAt).inDays <= 7;
  }

  /// Kiểm tra banner được cập nhật gần đây (trong 3 ngày)
  bool get isRecentlyUpdated {
    final now = DateTime.now();
    return now.difference(updatedAt).inDays <= 3;
  }

  /// Số ngày kể từ khi tạo
  int get daysSinceCreated {
    final now = DateTime.now();
    return now.difference(createdAt).inDays;
  }

  /// Số ngày kể từ lần cập nhật cuối
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

  /// Kiểm tra tiêu đề hợp lệ
  bool get hasValidTitle => title.trim().isNotEmpty && title.length >= 2;

  /// Kiểm tra thứ tự hợp lệ
  bool get hasValidOrder => order >= 0;

  /// Kiểm tra có thể kích hoạt
  bool get canActivate => !isActive && hasImage;

  /// Kiểm tra có thể vô hiệu hóa
  bool get canDeactivate => isActive;

  /// Kiểm tra có thể di chuyển lên
  bool get canMoveUp => order > 0;

  /// Lấy tiêu đề hiển thị
  String get displayTitle => title.isEmpty ? 'Không có tiêu đề' : title;

  /// Lấy phụ đề hiển thị
  String get displaySubtitle => subtitle.isEmpty ? '' : subtitle;

  /// So sánh thứ tự
  int compareOrderWith(BannerEntity other) {
    return order.compareTo(other.order);
  }

  /// Kiểm tra cùng thứ tự
  bool hasSameOrderAs(BannerEntity other) {
    return order == other.order;
  }

  /// Kiểm tra thứ tự cao hơn
  bool hasHigherOrderThan(BannerEntity other) {
    return order > other.order;
  }

  /// Kiểm tra thứ tự thấp hơn
  bool hasLowerOrderThan(BannerEntity other) {
    return order < other.order;
  }

  /// Tạo bản sao với các thuộc tính cập nhật
  BannerEntity copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? imageUrl,
    String? linkType,
    String? linkValue,
    bool? isActive,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BannerEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      imageUrl: imageUrl ?? this.imageUrl,
      linkType: linkType ?? this.linkType,
      linkValue: linkValue ?? this.linkValue,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    subtitle,
    imageUrl,
    linkType,
    linkValue,
    isActive,
    order,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() {
    return 'BannerEntity('
        'id: $id, '
        'title: $title, '
        'linkType: $linkType, '
        'isActive: $isActive, '
        'order: $order'
        ')';
  }
}

/// Entity chứa thống kê về banner
class BannerStatsEntity extends Equatable {
  /// Tổng số banner
  final int totalBanners;

  /// Số banner đang hoạt động
  final int activeBanners;

  /// Số banner không hoạt động
  final int inactiveBanners;

  const BannerStatsEntity({
    required this.totalBanners,
    required this.activeBanners,
    required this.inactiveBanners,
  });

  /// Phần trăm banner đang hoạt động
  double get activePercentage {
    if (totalBanners == 0) return 0.0;
    return (activeBanners / totalBanners) * 100;
  }

  /// Phần trăm banner không hoạt động
  double get inactivePercentage {
    if (totalBanners == 0) return 0.0;
    return (inactiveBanners / totalBanners) * 100;
  }

  /// Có banner nào không
  bool get hasBanners => totalBanners > 0;

  /// Có banner đang hoạt động không
  bool get hasActiveBanners => activeBanners > 0;

  /// Có banner không hoạt động không
  bool get hasInactiveBanners => inactiveBanners > 0;

  /// Tất cả banner đang hoạt động
  bool get allBannersActive =>
      totalBanners > 0 && activeBanners == totalBanners;

  /// Không có banner nào hoạt động
  bool get noBannersActive => activeBanners == 0;

  @override
  List<Object?> get props => [totalBanners, activeBanners, inactiveBanners];

  @override
  String toString() {
    return 'BannerStatsEntity('
        'total: $totalBanners, '
        'active: $activeBanners, '
        'inactive: $inactiveBanners'
        ')';
  }
}
