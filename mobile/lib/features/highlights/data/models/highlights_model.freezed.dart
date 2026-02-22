// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'highlights_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

HighlightsData _$HighlightsDataFromJson(Map<String, dynamic> json) {
  return _HighlightsData.fromJson(json);
}

/// @nodoc
mixin _$HighlightsData {
  StaySummary get stay => throw _privateConstructorUsedError;
  HighlightsStats get stats => throw _privateConstructorUsedError;
  List<String> get categories => throw _privateConstructorUsedError;
  Map<String, List<HighlightItem>> get itemsByCategory =>
      throw _privateConstructorUsedError;

  /// Serializes this HighlightsData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HighlightsData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HighlightsDataCopyWith<HighlightsData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HighlightsDataCopyWith<$Res> {
  factory $HighlightsDataCopyWith(
    HighlightsData value,
    $Res Function(HighlightsData) then,
  ) = _$HighlightsDataCopyWithImpl<$Res, HighlightsData>;
  @useResult
  $Res call({
    StaySummary stay,
    HighlightsStats stats,
    List<String> categories,
    Map<String, List<HighlightItem>> itemsByCategory,
  });

  $StaySummaryCopyWith<$Res> get stay;
  $HighlightsStatsCopyWith<$Res> get stats;
}

/// @nodoc
class _$HighlightsDataCopyWithImpl<$Res, $Val extends HighlightsData>
    implements $HighlightsDataCopyWith<$Res> {
  _$HighlightsDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HighlightsData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stay = null,
    Object? stats = null,
    Object? categories = null,
    Object? itemsByCategory = null,
  }) {
    return _then(
      _value.copyWith(
            stay: null == stay
                ? _value.stay
                : stay // ignore: cast_nullable_to_non_nullable
                      as StaySummary,
            stats: null == stats
                ? _value.stats
                : stats // ignore: cast_nullable_to_non_nullable
                      as HighlightsStats,
            categories: null == categories
                ? _value.categories
                : categories // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            itemsByCategory: null == itemsByCategory
                ? _value.itemsByCategory
                : itemsByCategory // ignore: cast_nullable_to_non_nullable
                      as Map<String, List<HighlightItem>>,
          )
          as $Val,
    );
  }

  /// Create a copy of HighlightsData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StaySummaryCopyWith<$Res> get stay {
    return $StaySummaryCopyWith<$Res>(_value.stay, (value) {
      return _then(_value.copyWith(stay: value) as $Val);
    });
  }

  /// Create a copy of HighlightsData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $HighlightsStatsCopyWith<$Res> get stats {
    return $HighlightsStatsCopyWith<$Res>(_value.stats, (value) {
      return _then(_value.copyWith(stats: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$HighlightsDataImplCopyWith<$Res>
    implements $HighlightsDataCopyWith<$Res> {
  factory _$$HighlightsDataImplCopyWith(
    _$HighlightsDataImpl value,
    $Res Function(_$HighlightsDataImpl) then,
  ) = __$$HighlightsDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    StaySummary stay,
    HighlightsStats stats,
    List<String> categories,
    Map<String, List<HighlightItem>> itemsByCategory,
  });

  @override
  $StaySummaryCopyWith<$Res> get stay;
  @override
  $HighlightsStatsCopyWith<$Res> get stats;
}

/// @nodoc
class __$$HighlightsDataImplCopyWithImpl<$Res>
    extends _$HighlightsDataCopyWithImpl<$Res, _$HighlightsDataImpl>
    implements _$$HighlightsDataImplCopyWith<$Res> {
  __$$HighlightsDataImplCopyWithImpl(
    _$HighlightsDataImpl _value,
    $Res Function(_$HighlightsDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HighlightsData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stay = null,
    Object? stats = null,
    Object? categories = null,
    Object? itemsByCategory = null,
  }) {
    return _then(
      _$HighlightsDataImpl(
        stay: null == stay
            ? _value.stay
            : stay // ignore: cast_nullable_to_non_nullable
                  as StaySummary,
        stats: null == stats
            ? _value.stats
            : stats // ignore: cast_nullable_to_non_nullable
                  as HighlightsStats,
        categories: null == categories
            ? _value._categories
            : categories // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        itemsByCategory: null == itemsByCategory
            ? _value._itemsByCategory
            : itemsByCategory // ignore: cast_nullable_to_non_nullable
                  as Map<String, List<HighlightItem>>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$HighlightsDataImpl extends _HighlightsData {
  const _$HighlightsDataImpl({
    required this.stay,
    required this.stats,
    required final List<String> categories,
    required final Map<String, List<HighlightItem>> itemsByCategory,
  }) : _categories = categories,
       _itemsByCategory = itemsByCategory,
       super._();

  factory _$HighlightsDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$HighlightsDataImplFromJson(json);

  @override
  final StaySummary stay;
  @override
  final HighlightsStats stats;
  final List<String> _categories;
  @override
  List<String> get categories {
    if (_categories is EqualUnmodifiableListView) return _categories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categories);
  }

  final Map<String, List<HighlightItem>> _itemsByCategory;
  @override
  Map<String, List<HighlightItem>> get itemsByCategory {
    if (_itemsByCategory is EqualUnmodifiableMapView) return _itemsByCategory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_itemsByCategory);
  }

  @override
  String toString() {
    return 'HighlightsData(stay: $stay, stats: $stats, categories: $categories, itemsByCategory: $itemsByCategory)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HighlightsDataImpl &&
            (identical(other.stay, stay) || other.stay == stay) &&
            (identical(other.stats, stats) || other.stats == stats) &&
            const DeepCollectionEquality().equals(
              other._categories,
              _categories,
            ) &&
            const DeepCollectionEquality().equals(
              other._itemsByCategory,
              _itemsByCategory,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    stay,
    stats,
    const DeepCollectionEquality().hash(_categories),
    const DeepCollectionEquality().hash(_itemsByCategory),
  );

  /// Create a copy of HighlightsData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HighlightsDataImplCopyWith<_$HighlightsDataImpl> get copyWith =>
      __$$HighlightsDataImplCopyWithImpl<_$HighlightsDataImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$HighlightsDataImplToJson(this);
  }
}

abstract class _HighlightsData extends HighlightsData {
  const factory _HighlightsData({
    required final StaySummary stay,
    required final HighlightsStats stats,
    required final List<String> categories,
    required final Map<String, List<HighlightItem>> itemsByCategory,
  }) = _$HighlightsDataImpl;
  const _HighlightsData._() : super._();

  factory _HighlightsData.fromJson(Map<String, dynamic> json) =
      _$HighlightsDataImpl.fromJson;

  @override
  StaySummary get stay;
  @override
  HighlightsStats get stats;
  @override
  List<String> get categories;
  @override
  Map<String, List<HighlightItem>> get itemsByCategory;

  /// Create a copy of HighlightsData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HighlightsDataImplCopyWith<_$HighlightsDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StaySummary _$StaySummaryFromJson(Map<String, dynamic> json) {
  return _StaySummary.fromJson(json);
}

/// @nodoc
mixin _$StaySummary {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get city => throw _privateConstructorUsedError;
  String? get country => throw _privateConstructorUsedError;
  DateTime? get checkIn => throw _privateConstructorUsedError;
  DateTime? get checkOut => throw _privateConstructorUsedError;

  /// Serializes this StaySummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StaySummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StaySummaryCopyWith<StaySummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StaySummaryCopyWith<$Res> {
  factory $StaySummaryCopyWith(
    StaySummary value,
    $Res Function(StaySummary) then,
  ) = _$StaySummaryCopyWithImpl<$Res, StaySummary>;
  @useResult
  $Res call({
    int id,
    String title,
    String? city,
    String? country,
    DateTime? checkIn,
    DateTime? checkOut,
  });
}

/// @nodoc
class _$StaySummaryCopyWithImpl<$Res, $Val extends StaySummary>
    implements $StaySummaryCopyWith<$Res> {
  _$StaySummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StaySummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? city = freezed,
    Object? country = freezed,
    Object? checkIn = freezed,
    Object? checkOut = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            city: freezed == city
                ? _value.city
                : city // ignore: cast_nullable_to_non_nullable
                      as String?,
            country: freezed == country
                ? _value.country
                : country // ignore: cast_nullable_to_non_nullable
                      as String?,
            checkIn: freezed == checkIn
                ? _value.checkIn
                : checkIn // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            checkOut: freezed == checkOut
                ? _value.checkOut
                : checkOut // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StaySummaryImplCopyWith<$Res>
    implements $StaySummaryCopyWith<$Res> {
  factory _$$StaySummaryImplCopyWith(
    _$StaySummaryImpl value,
    $Res Function(_$StaySummaryImpl) then,
  ) = __$$StaySummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String title,
    String? city,
    String? country,
    DateTime? checkIn,
    DateTime? checkOut,
  });
}

/// @nodoc
class __$$StaySummaryImplCopyWithImpl<$Res>
    extends _$StaySummaryCopyWithImpl<$Res, _$StaySummaryImpl>
    implements _$$StaySummaryImplCopyWith<$Res> {
  __$$StaySummaryImplCopyWithImpl(
    _$StaySummaryImpl _value,
    $Res Function(_$StaySummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StaySummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? city = freezed,
    Object? country = freezed,
    Object? checkIn = freezed,
    Object? checkOut = freezed,
  }) {
    return _then(
      _$StaySummaryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        city: freezed == city
            ? _value.city
            : city // ignore: cast_nullable_to_non_nullable
                  as String?,
        country: freezed == country
            ? _value.country
            : country // ignore: cast_nullable_to_non_nullable
                  as String?,
        checkIn: freezed == checkIn
            ? _value.checkIn
            : checkIn // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        checkOut: freezed == checkOut
            ? _value.checkOut
            : checkOut // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StaySummaryImpl implements _StaySummary {
  const _$StaySummaryImpl({
    required this.id,
    required this.title,
    this.city,
    this.country,
    this.checkIn,
    this.checkOut,
  });

  factory _$StaySummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$StaySummaryImplFromJson(json);

  @override
  final int id;
  @override
  final String title;
  @override
  final String? city;
  @override
  final String? country;
  @override
  final DateTime? checkIn;
  @override
  final DateTime? checkOut;

  @override
  String toString() {
    return 'StaySummary(id: $id, title: $title, city: $city, country: $country, checkIn: $checkIn, checkOut: $checkOut)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StaySummaryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.checkIn, checkIn) || other.checkIn == checkIn) &&
            (identical(other.checkOut, checkOut) ||
                other.checkOut == checkOut));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, title, city, country, checkIn, checkOut);

  /// Create a copy of StaySummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StaySummaryImplCopyWith<_$StaySummaryImpl> get copyWith =>
      __$$StaySummaryImplCopyWithImpl<_$StaySummaryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StaySummaryImplToJson(this);
  }
}

abstract class _StaySummary implements StaySummary {
  const factory _StaySummary({
    required final int id,
    required final String title,
    final String? city,
    final String? country,
    final DateTime? checkIn,
    final DateTime? checkOut,
  }) = _$StaySummaryImpl;

  factory _StaySummary.fromJson(Map<String, dynamic> json) =
      _$StaySummaryImpl.fromJson;

  @override
  int get id;
  @override
  String get title;
  @override
  String? get city;
  @override
  String? get country;
  @override
  DateTime? get checkIn;
  @override
  DateTime? get checkOut;

  /// Create a copy of StaySummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StaySummaryImplCopyWith<_$StaySummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HighlightsStats _$HighlightsStatsFromJson(Map<String, dynamic> json) {
  return _HighlightsStats.fromJson(json);
}

/// @nodoc
mixin _$HighlightsStats {
  double? get tripAverage => throw _privateConstructorUsedError;
  UserStats? get userStats => throw _privateConstructorUsedError;
  List<CollaboratorStats> get collaboratorStats =>
      throw _privateConstructorUsedError;

  /// Serializes this HighlightsStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HighlightsStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HighlightsStatsCopyWith<HighlightsStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HighlightsStatsCopyWith<$Res> {
  factory $HighlightsStatsCopyWith(
    HighlightsStats value,
    $Res Function(HighlightsStats) then,
  ) = _$HighlightsStatsCopyWithImpl<$Res, HighlightsStats>;
  @useResult
  $Res call({
    double? tripAverage,
    UserStats? userStats,
    List<CollaboratorStats> collaboratorStats,
  });

  $UserStatsCopyWith<$Res>? get userStats;
}

/// @nodoc
class _$HighlightsStatsCopyWithImpl<$Res, $Val extends HighlightsStats>
    implements $HighlightsStatsCopyWith<$Res> {
  _$HighlightsStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HighlightsStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tripAverage = freezed,
    Object? userStats = freezed,
    Object? collaboratorStats = null,
  }) {
    return _then(
      _value.copyWith(
            tripAverage: freezed == tripAverage
                ? _value.tripAverage
                : tripAverage // ignore: cast_nullable_to_non_nullable
                      as double?,
            userStats: freezed == userStats
                ? _value.userStats
                : userStats // ignore: cast_nullable_to_non_nullable
                      as UserStats?,
            collaboratorStats: null == collaboratorStats
                ? _value.collaboratorStats
                : collaboratorStats // ignore: cast_nullable_to_non_nullable
                      as List<CollaboratorStats>,
          )
          as $Val,
    );
  }

  /// Create a copy of HighlightsStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserStatsCopyWith<$Res>? get userStats {
    if (_value.userStats == null) {
      return null;
    }

    return $UserStatsCopyWith<$Res>(_value.userStats!, (value) {
      return _then(_value.copyWith(userStats: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$HighlightsStatsImplCopyWith<$Res>
    implements $HighlightsStatsCopyWith<$Res> {
  factory _$$HighlightsStatsImplCopyWith(
    _$HighlightsStatsImpl value,
    $Res Function(_$HighlightsStatsImpl) then,
  ) = __$$HighlightsStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double? tripAverage,
    UserStats? userStats,
    List<CollaboratorStats> collaboratorStats,
  });

  @override
  $UserStatsCopyWith<$Res>? get userStats;
}

/// @nodoc
class __$$HighlightsStatsImplCopyWithImpl<$Res>
    extends _$HighlightsStatsCopyWithImpl<$Res, _$HighlightsStatsImpl>
    implements _$$HighlightsStatsImplCopyWith<$Res> {
  __$$HighlightsStatsImplCopyWithImpl(
    _$HighlightsStatsImpl _value,
    $Res Function(_$HighlightsStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HighlightsStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tripAverage = freezed,
    Object? userStats = freezed,
    Object? collaboratorStats = null,
  }) {
    return _then(
      _$HighlightsStatsImpl(
        tripAverage: freezed == tripAverage
            ? _value.tripAverage
            : tripAverage // ignore: cast_nullable_to_non_nullable
                  as double?,
        userStats: freezed == userStats
            ? _value.userStats
            : userStats // ignore: cast_nullable_to_non_nullable
                  as UserStats?,
        collaboratorStats: null == collaboratorStats
            ? _value._collaboratorStats
            : collaboratorStats // ignore: cast_nullable_to_non_nullable
                  as List<CollaboratorStats>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$HighlightsStatsImpl implements _HighlightsStats {
  const _$HighlightsStatsImpl({
    this.tripAverage,
    this.userStats,
    final List<CollaboratorStats> collaboratorStats = const [],
  }) : _collaboratorStats = collaboratorStats;

  factory _$HighlightsStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$HighlightsStatsImplFromJson(json);

  @override
  final double? tripAverage;
  @override
  final UserStats? userStats;
  final List<CollaboratorStats> _collaboratorStats;
  @override
  @JsonKey()
  List<CollaboratorStats> get collaboratorStats {
    if (_collaboratorStats is EqualUnmodifiableListView)
      return _collaboratorStats;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_collaboratorStats);
  }

  @override
  String toString() {
    return 'HighlightsStats(tripAverage: $tripAverage, userStats: $userStats, collaboratorStats: $collaboratorStats)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HighlightsStatsImpl &&
            (identical(other.tripAverage, tripAverage) ||
                other.tripAverage == tripAverage) &&
            (identical(other.userStats, userStats) ||
                other.userStats == userStats) &&
            const DeepCollectionEquality().equals(
              other._collaboratorStats,
              _collaboratorStats,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    tripAverage,
    userStats,
    const DeepCollectionEquality().hash(_collaboratorStats),
  );

  /// Create a copy of HighlightsStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HighlightsStatsImplCopyWith<_$HighlightsStatsImpl> get copyWith =>
      __$$HighlightsStatsImplCopyWithImpl<_$HighlightsStatsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$HighlightsStatsImplToJson(this);
  }
}

abstract class _HighlightsStats implements HighlightsStats {
  const factory _HighlightsStats({
    final double? tripAverage,
    final UserStats? userStats,
    final List<CollaboratorStats> collaboratorStats,
  }) = _$HighlightsStatsImpl;

  factory _HighlightsStats.fromJson(Map<String, dynamic> json) =
      _$HighlightsStatsImpl.fromJson;

  @override
  double? get tripAverage;
  @override
  UserStats? get userStats;
  @override
  List<CollaboratorStats> get collaboratorStats;

  /// Create a copy of HighlightsStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HighlightsStatsImplCopyWith<_$HighlightsStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserStats _$UserStatsFromJson(Map<String, dynamic> json) {
  return _UserStats.fromJson(json);
}

/// @nodoc
mixin _$UserStats {
  double get average => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;
  List<int> get distribution => throw _privateConstructorUsedError;

  /// Serializes this UserStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserStatsCopyWith<UserStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserStatsCopyWith<$Res> {
  factory $UserStatsCopyWith(UserStats value, $Res Function(UserStats) then) =
      _$UserStatsCopyWithImpl<$Res, UserStats>;
  @useResult
  $Res call({double average, int count, List<int> distribution});
}

/// @nodoc
class _$UserStatsCopyWithImpl<$Res, $Val extends UserStats>
    implements $UserStatsCopyWith<$Res> {
  _$UserStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? average = null,
    Object? count = null,
    Object? distribution = null,
  }) {
    return _then(
      _value.copyWith(
            average: null == average
                ? _value.average
                : average // ignore: cast_nullable_to_non_nullable
                      as double,
            count: null == count
                ? _value.count
                : count // ignore: cast_nullable_to_non_nullable
                      as int,
            distribution: null == distribution
                ? _value.distribution
                : distribution // ignore: cast_nullable_to_non_nullable
                      as List<int>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserStatsImplCopyWith<$Res>
    implements $UserStatsCopyWith<$Res> {
  factory _$$UserStatsImplCopyWith(
    _$UserStatsImpl value,
    $Res Function(_$UserStatsImpl) then,
  ) = __$$UserStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double average, int count, List<int> distribution});
}

/// @nodoc
class __$$UserStatsImplCopyWithImpl<$Res>
    extends _$UserStatsCopyWithImpl<$Res, _$UserStatsImpl>
    implements _$$UserStatsImplCopyWith<$Res> {
  __$$UserStatsImplCopyWithImpl(
    _$UserStatsImpl _value,
    $Res Function(_$UserStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? average = null,
    Object? count = null,
    Object? distribution = null,
  }) {
    return _then(
      _$UserStatsImpl(
        average: null == average
            ? _value.average
            : average // ignore: cast_nullable_to_non_nullable
                  as double,
        count: null == count
            ? _value.count
            : count // ignore: cast_nullable_to_non_nullable
                  as int,
        distribution: null == distribution
            ? _value._distribution
            : distribution // ignore: cast_nullable_to_non_nullable
                  as List<int>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserStatsImpl implements _UserStats {
  const _$UserStatsImpl({
    required this.average,
    required this.count,
    final List<int> distribution = const [0, 0, 0, 0, 0],
  }) : _distribution = distribution;

  factory _$UserStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserStatsImplFromJson(json);

  @override
  final double average;
  @override
  final int count;
  final List<int> _distribution;
  @override
  @JsonKey()
  List<int> get distribution {
    if (_distribution is EqualUnmodifiableListView) return _distribution;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_distribution);
  }

  @override
  String toString() {
    return 'UserStats(average: $average, count: $count, distribution: $distribution)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserStatsImpl &&
            (identical(other.average, average) || other.average == average) &&
            (identical(other.count, count) || other.count == count) &&
            const DeepCollectionEquality().equals(
              other._distribution,
              _distribution,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    average,
    count,
    const DeepCollectionEquality().hash(_distribution),
  );

  /// Create a copy of UserStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserStatsImplCopyWith<_$UserStatsImpl> get copyWith =>
      __$$UserStatsImplCopyWithImpl<_$UserStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserStatsImplToJson(this);
  }
}

abstract class _UserStats implements UserStats {
  const factory _UserStats({
    required final double average,
    required final int count,
    final List<int> distribution,
  }) = _$UserStatsImpl;

  factory _UserStats.fromJson(Map<String, dynamic> json) =
      _$UserStatsImpl.fromJson;

  @override
  double get average;
  @override
  int get count;
  @override
  List<int> get distribution;

  /// Create a copy of UserStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserStatsImplCopyWith<_$UserStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CollaboratorStats _$CollaboratorStatsFromJson(Map<String, dynamic> json) {
  return _CollaboratorStats.fromJson(json);
}

/// @nodoc
mixin _$CollaboratorStats {
  UserInfo get user => throw _privateConstructorUsedError;
  UserStats? get stats => throw _privateConstructorUsedError;

  /// Serializes this CollaboratorStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CollaboratorStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CollaboratorStatsCopyWith<CollaboratorStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CollaboratorStatsCopyWith<$Res> {
  factory $CollaboratorStatsCopyWith(
    CollaboratorStats value,
    $Res Function(CollaboratorStats) then,
  ) = _$CollaboratorStatsCopyWithImpl<$Res, CollaboratorStats>;
  @useResult
  $Res call({UserInfo user, UserStats? stats});

  $UserInfoCopyWith<$Res> get user;
  $UserStatsCopyWith<$Res>? get stats;
}

/// @nodoc
class _$CollaboratorStatsCopyWithImpl<$Res, $Val extends CollaboratorStats>
    implements $CollaboratorStatsCopyWith<$Res> {
  _$CollaboratorStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CollaboratorStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? user = null, Object? stats = freezed}) {
    return _then(
      _value.copyWith(
            user: null == user
                ? _value.user
                : user // ignore: cast_nullable_to_non_nullable
                      as UserInfo,
            stats: freezed == stats
                ? _value.stats
                : stats // ignore: cast_nullable_to_non_nullable
                      as UserStats?,
          )
          as $Val,
    );
  }

  /// Create a copy of CollaboratorStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserInfoCopyWith<$Res> get user {
    return $UserInfoCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }

  /// Create a copy of CollaboratorStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserStatsCopyWith<$Res>? get stats {
    if (_value.stats == null) {
      return null;
    }

    return $UserStatsCopyWith<$Res>(_value.stats!, (value) {
      return _then(_value.copyWith(stats: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CollaboratorStatsImplCopyWith<$Res>
    implements $CollaboratorStatsCopyWith<$Res> {
  factory _$$CollaboratorStatsImplCopyWith(
    _$CollaboratorStatsImpl value,
    $Res Function(_$CollaboratorStatsImpl) then,
  ) = __$$CollaboratorStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({UserInfo user, UserStats? stats});

  @override
  $UserInfoCopyWith<$Res> get user;
  @override
  $UserStatsCopyWith<$Res>? get stats;
}

/// @nodoc
class __$$CollaboratorStatsImplCopyWithImpl<$Res>
    extends _$CollaboratorStatsCopyWithImpl<$Res, _$CollaboratorStatsImpl>
    implements _$$CollaboratorStatsImplCopyWith<$Res> {
  __$$CollaboratorStatsImplCopyWithImpl(
    _$CollaboratorStatsImpl _value,
    $Res Function(_$CollaboratorStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CollaboratorStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? user = null, Object? stats = freezed}) {
    return _then(
      _$CollaboratorStatsImpl(
        user: null == user
            ? _value.user
            : user // ignore: cast_nullable_to_non_nullable
                  as UserInfo,
        stats: freezed == stats
            ? _value.stats
            : stats // ignore: cast_nullable_to_non_nullable
                  as UserStats?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CollaboratorStatsImpl implements _CollaboratorStats {
  const _$CollaboratorStatsImpl({required this.user, this.stats});

  factory _$CollaboratorStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$CollaboratorStatsImplFromJson(json);

  @override
  final UserInfo user;
  @override
  final UserStats? stats;

  @override
  String toString() {
    return 'CollaboratorStats(user: $user, stats: $stats)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CollaboratorStatsImpl &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.stats, stats) || other.stats == stats));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, user, stats);

  /// Create a copy of CollaboratorStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CollaboratorStatsImplCopyWith<_$CollaboratorStatsImpl> get copyWith =>
      __$$CollaboratorStatsImplCopyWithImpl<_$CollaboratorStatsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CollaboratorStatsImplToJson(this);
  }
}

abstract class _CollaboratorStats implements CollaboratorStats {
  const factory _CollaboratorStats({
    required final UserInfo user,
    final UserStats? stats,
  }) = _$CollaboratorStatsImpl;

  factory _CollaboratorStats.fromJson(Map<String, dynamic> json) =
      _$CollaboratorStatsImpl.fromJson;

  @override
  UserInfo get user;
  @override
  UserStats? get stats;

  /// Create a copy of CollaboratorStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CollaboratorStatsImplCopyWith<_$CollaboratorStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserInfo _$UserInfoFromJson(Map<String, dynamic> json) {
  return _UserInfo.fromJson(json);
}

/// @nodoc
mixin _$UserInfo {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;

  /// Serializes this UserInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserInfoCopyWith<UserInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserInfoCopyWith<$Res> {
  factory $UserInfoCopyWith(UserInfo value, $Res Function(UserInfo) then) =
      _$UserInfoCopyWithImpl<$Res, UserInfo>;
  @useResult
  $Res call({int id, String name, String? avatarUrl});
}

/// @nodoc
class _$UserInfoCopyWithImpl<$Res, $Val extends UserInfo>
    implements $UserInfoCopyWith<$Res> {
  _$UserInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? avatarUrl = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            avatarUrl: freezed == avatarUrl
                ? _value.avatarUrl
                : avatarUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserInfoImplCopyWith<$Res>
    implements $UserInfoCopyWith<$Res> {
  factory _$$UserInfoImplCopyWith(
    _$UserInfoImpl value,
    $Res Function(_$UserInfoImpl) then,
  ) = __$$UserInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String name, String? avatarUrl});
}

/// @nodoc
class __$$UserInfoImplCopyWithImpl<$Res>
    extends _$UserInfoCopyWithImpl<$Res, _$UserInfoImpl>
    implements _$$UserInfoImplCopyWith<$Res> {
  __$$UserInfoImplCopyWithImpl(
    _$UserInfoImpl _value,
    $Res Function(_$UserInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? avatarUrl = freezed,
  }) {
    return _then(
      _$UserInfoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        avatarUrl: freezed == avatarUrl
            ? _value.avatarUrl
            : avatarUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserInfoImpl implements _UserInfo {
  const _$UserInfoImpl({required this.id, required this.name, this.avatarUrl});

  factory _$UserInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserInfoImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String? avatarUrl;

  @override
  String toString() {
    return 'UserInfo(id: $id, name: $name, avatarUrl: $avatarUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserInfoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, avatarUrl);

  /// Create a copy of UserInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserInfoImplCopyWith<_$UserInfoImpl> get copyWith =>
      __$$UserInfoImplCopyWithImpl<_$UserInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserInfoImplToJson(this);
  }
}

abstract class _UserInfo implements UserInfo {
  const factory _UserInfo({
    required final int id,
    required final String name,
    final String? avatarUrl,
  }) = _$UserInfoImpl;

  factory _UserInfo.fromJson(Map<String, dynamic> json) =
      _$UserInfoImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String? get avatarUrl;

  /// Create a copy of UserInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserInfoImplCopyWith<_$UserInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HighlightItem _$HighlightItemFromJson(Map<String, dynamic> json) {
  return _HighlightItem.fromJson(json);
}

/// @nodoc
mixin _$HighlightItem {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;
  double? get averageRating => throw _privateConstructorUsedError;
  List<ItemRating> get ratings => throw _privateConstructorUsedError;

  /// Serializes this HighlightItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HighlightItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HighlightItemCopyWith<HighlightItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HighlightItemCopyWith<$Res> {
  factory $HighlightItemCopyWith(
    HighlightItem value,
    $Res Function(HighlightItem) then,
  ) = _$HighlightItemCopyWithImpl<$Res, HighlightItem>;
  @useResult
  $Res call({
    int id,
    String title,
    String? address,
    String category,
    DateTime? completedAt,
    double? averageRating,
    List<ItemRating> ratings,
  });
}

/// @nodoc
class _$HighlightItemCopyWithImpl<$Res, $Val extends HighlightItem>
    implements $HighlightItemCopyWith<$Res> {
  _$HighlightItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HighlightItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? address = freezed,
    Object? category = null,
    Object? completedAt = freezed,
    Object? averageRating = freezed,
    Object? ratings = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            address: freezed == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String?,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            completedAt: freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            averageRating: freezed == averageRating
                ? _value.averageRating
                : averageRating // ignore: cast_nullable_to_non_nullable
                      as double?,
            ratings: null == ratings
                ? _value.ratings
                : ratings // ignore: cast_nullable_to_non_nullable
                      as List<ItemRating>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$HighlightItemImplCopyWith<$Res>
    implements $HighlightItemCopyWith<$Res> {
  factory _$$HighlightItemImplCopyWith(
    _$HighlightItemImpl value,
    $Res Function(_$HighlightItemImpl) then,
  ) = __$$HighlightItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String title,
    String? address,
    String category,
    DateTime? completedAt,
    double? averageRating,
    List<ItemRating> ratings,
  });
}

/// @nodoc
class __$$HighlightItemImplCopyWithImpl<$Res>
    extends _$HighlightItemCopyWithImpl<$Res, _$HighlightItemImpl>
    implements _$$HighlightItemImplCopyWith<$Res> {
  __$$HighlightItemImplCopyWithImpl(
    _$HighlightItemImpl _value,
    $Res Function(_$HighlightItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HighlightItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? address = freezed,
    Object? category = null,
    Object? completedAt = freezed,
    Object? averageRating = freezed,
    Object? ratings = null,
  }) {
    return _then(
      _$HighlightItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        address: freezed == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String?,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        completedAt: freezed == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        averageRating: freezed == averageRating
            ? _value.averageRating
            : averageRating // ignore: cast_nullable_to_non_nullable
                  as double?,
        ratings: null == ratings
            ? _value._ratings
            : ratings // ignore: cast_nullable_to_non_nullable
                  as List<ItemRating>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$HighlightItemImpl extends _HighlightItem {
  const _$HighlightItemImpl({
    required this.id,
    required this.title,
    this.address,
    this.category = 'other',
    this.completedAt,
    this.averageRating,
    final List<ItemRating> ratings = const [],
  }) : _ratings = ratings,
       super._();

  factory _$HighlightItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$HighlightItemImplFromJson(json);

  @override
  final int id;
  @override
  final String title;
  @override
  final String? address;
  @override
  @JsonKey()
  final String category;
  @override
  final DateTime? completedAt;
  @override
  final double? averageRating;
  final List<ItemRating> _ratings;
  @override
  @JsonKey()
  List<ItemRating> get ratings {
    if (_ratings is EqualUnmodifiableListView) return _ratings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_ratings);
  }

  @override
  String toString() {
    return 'HighlightItem(id: $id, title: $title, address: $address, category: $category, completedAt: $completedAt, averageRating: $averageRating, ratings: $ratings)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HighlightItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.averageRating, averageRating) ||
                other.averageRating == averageRating) &&
            const DeepCollectionEquality().equals(other._ratings, _ratings));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    address,
    category,
    completedAt,
    averageRating,
    const DeepCollectionEquality().hash(_ratings),
  );

  /// Create a copy of HighlightItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HighlightItemImplCopyWith<_$HighlightItemImpl> get copyWith =>
      __$$HighlightItemImplCopyWithImpl<_$HighlightItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HighlightItemImplToJson(this);
  }
}

abstract class _HighlightItem extends HighlightItem {
  const factory _HighlightItem({
    required final int id,
    required final String title,
    final String? address,
    final String category,
    final DateTime? completedAt,
    final double? averageRating,
    final List<ItemRating> ratings,
  }) = _$HighlightItemImpl;
  const _HighlightItem._() : super._();

  factory _HighlightItem.fromJson(Map<String, dynamic> json) =
      _$HighlightItemImpl.fromJson;

  @override
  int get id;
  @override
  String get title;
  @override
  String? get address;
  @override
  String get category;
  @override
  DateTime? get completedAt;
  @override
  double? get averageRating;
  @override
  List<ItemRating> get ratings;

  /// Create a copy of HighlightItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HighlightItemImplCopyWith<_$HighlightItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ItemRating _$ItemRatingFromJson(Map<String, dynamic> json) {
  return _ItemRating.fromJson(json);
}

/// @nodoc
mixin _$ItemRating {
  int get userId => throw _privateConstructorUsedError;
  String get userName => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;
  int get rating => throw _privateConstructorUsedError;

  /// Serializes this ItemRating to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ItemRating
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ItemRatingCopyWith<ItemRating> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ItemRatingCopyWith<$Res> {
  factory $ItemRatingCopyWith(
    ItemRating value,
    $Res Function(ItemRating) then,
  ) = _$ItemRatingCopyWithImpl<$Res, ItemRating>;
  @useResult
  $Res call({int userId, String userName, String? avatarUrl, int rating});
}

/// @nodoc
class _$ItemRatingCopyWithImpl<$Res, $Val extends ItemRating>
    implements $ItemRatingCopyWith<$Res> {
  _$ItemRatingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ItemRating
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? userName = null,
    Object? avatarUrl = freezed,
    Object? rating = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as int,
            userName: null == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                      as String,
            avatarUrl: freezed == avatarUrl
                ? _value.avatarUrl
                : avatarUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            rating: null == rating
                ? _value.rating
                : rating // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ItemRatingImplCopyWith<$Res>
    implements $ItemRatingCopyWith<$Res> {
  factory _$$ItemRatingImplCopyWith(
    _$ItemRatingImpl value,
    $Res Function(_$ItemRatingImpl) then,
  ) = __$$ItemRatingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int userId, String userName, String? avatarUrl, int rating});
}

/// @nodoc
class __$$ItemRatingImplCopyWithImpl<$Res>
    extends _$ItemRatingCopyWithImpl<$Res, _$ItemRatingImpl>
    implements _$$ItemRatingImplCopyWith<$Res> {
  __$$ItemRatingImplCopyWithImpl(
    _$ItemRatingImpl _value,
    $Res Function(_$ItemRatingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ItemRating
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? userName = null,
    Object? avatarUrl = freezed,
    Object? rating = null,
  }) {
    return _then(
      _$ItemRatingImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as int,
        userName: null == userName
            ? _value.userName
            : userName // ignore: cast_nullable_to_non_nullable
                  as String,
        avatarUrl: freezed == avatarUrl
            ? _value.avatarUrl
            : avatarUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        rating: null == rating
            ? _value.rating
            : rating // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ItemRatingImpl implements _ItemRating {
  const _$ItemRatingImpl({
    required this.userId,
    required this.userName,
    this.avatarUrl,
    required this.rating,
  });

  factory _$ItemRatingImpl.fromJson(Map<String, dynamic> json) =>
      _$$ItemRatingImplFromJson(json);

  @override
  final int userId;
  @override
  final String userName;
  @override
  final String? avatarUrl;
  @override
  final int rating;

  @override
  String toString() {
    return 'ItemRating(userId: $userId, userName: $userName, avatarUrl: $avatarUrl, rating: $rating)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ItemRatingImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.rating, rating) || other.rating == rating));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, userId, userName, avatarUrl, rating);

  /// Create a copy of ItemRating
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ItemRatingImplCopyWith<_$ItemRatingImpl> get copyWith =>
      __$$ItemRatingImplCopyWithImpl<_$ItemRatingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ItemRatingImplToJson(this);
  }
}

abstract class _ItemRating implements ItemRating {
  const factory _ItemRating({
    required final int userId,
    required final String userName,
    final String? avatarUrl,
    required final int rating,
  }) = _$ItemRatingImpl;

  factory _ItemRating.fromJson(Map<String, dynamic> json) =
      _$ItemRatingImpl.fromJson;

  @override
  int get userId;
  @override
  String get userName;
  @override
  String? get avatarUrl;
  @override
  int get rating;

  /// Create a copy of ItemRating
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ItemRatingImplCopyWith<_$ItemRatingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
