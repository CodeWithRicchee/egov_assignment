import 'package:equatable/equatable.dart';

class SduiScreen extends Equatable {
  final String screenId;
  final String title;
  final int? stepIndex;
  final int? totalSteps;
  final String version;
  final List<SduiSection> sections;

  const SduiScreen({
    required this.screenId,
    required this.title,
    this.stepIndex,
    this.totalSteps,
    required this.version,
    required this.sections,
  });

  factory SduiScreen.fromJson(Map<String, dynamic> json) => SduiScreen(
        screenId: json['screenId'],
        title: json['title'],
        stepIndex: json['stepIndex'],
        totalSteps: json['totalSteps'],
        version: json['version'] ?? '1.0.0',
        sections: (json['sections'] as List).map((s) => SduiSection.fromJson(s)).toList(),
      );

  @override
  List<Object?> get props => [screenId, version];
}

class SduiSection extends Equatable {
  final String sectionId;
  final String type;
  final String? sectionTitle;
  final List<SduiComponent> components;

  const SduiSection({
    required this.sectionId,
    required this.type,
    this.sectionTitle,
    required this.components,
  });

  factory SduiSection.fromJson(Map<String, dynamic> json) => SduiSection(
        sectionId: json['sectionId'],
        type: json['type'],
        sectionTitle: json['sectionTitle'],
        components: (json['components'] as List).map((c) => SduiComponent.fromJson(c)).toList(),
      );

  @override
  List<Object?> get props => [sectionId];
}

class SduiComponent extends Equatable {
  final String componentId;
  final String type;
  final Map<String, dynamic> properties;

  const SduiComponent({
    required this.componentId,
    required this.type,
    required this.properties,
  });

  factory SduiComponent.fromJson(Map<String, dynamic> json) => SduiComponent(
        componentId: json['componentId'],
        type: json['type'],
        properties: Map<String, dynamic>.from(json['properties'] ?? {}),
      );

  String? get label => properties['label'];
  String? get hint => properties['hint'];
  String? get fieldKey => properties['fieldKey'];
  bool get mandatory => properties['mandatory'] ?? false;
  String? get prefixIcon => properties['prefixIcon'];
  String? get action => properties['action'];
  bool get fullWidth => properties['fullWidth'] ?? false;
  bool get showToggle => properties['showToggle'] ?? false;
  String? get keyboardType => properties['keyboardType'];
  int? get maxLength => properties['maxLength'];
  int? get maxLines => properties['maxLines'];
  bool get dependsOn => properties.containsKey('dependsOn');
  String? get dependsOnKey => properties['dependsOn'];

  List<SduiValidation> get validations {
    final list = properties['validations'] as List? ?? [];
    return list.map((v) => SduiValidation.fromJson(v)).toList();
  }

  SduiAsyncValidation? get asyncValidation {
    final av = properties['asyncValidation'];
    if (av == null) return null;
    return SduiAsyncValidation.fromJson(av);
  }

  SduiDataSource? get dataSource {
    final ds = properties['dataSource'];
    if (ds == null) return null;
    return SduiDataSource.fromJson(ds);
  }

  SduiMaxDateRule? get maxDateRule {
    final rule = properties['maxDateRule'];
    if (rule == null) return null;
    return SduiMaxDateRule.fromJson(rule);
  }

  @override
  List<Object?> get props => [componentId, type];
}

class SduiValidation extends Equatable {
  final String type;
  final String? message;
  final dynamic value;
  final String? pattern;
  final String? matchKey;

  const SduiValidation({
    required this.type,
    this.message,
    this.value,
    this.pattern,
    this.matchKey,
  });

  factory SduiValidation.fromJson(Map<String, dynamic> json) => SduiValidation(
        type: json['type'],
        message: json['message'],
        value: json['value'],
        pattern: json['pattern'],
        matchKey: json['matchKey'],
      );

  @override
  List<Object?> get props => [type, pattern];
}

class SduiAsyncValidation extends Equatable {
  final String type;
  final String apiParam;
  final String errorMessage;

  const SduiAsyncValidation({
    required this.type,
    required this.apiParam,
    required this.errorMessage,
  });

  factory SduiAsyncValidation.fromJson(Map<String, dynamic> json) => SduiAsyncValidation(
        type: json['type'],
        apiParam: json['apiParam'],
        errorMessage: json['errorMessage'],
      );

  @override
  List<Object?> get props => [type, apiParam];
}

class SduiDataSource extends Equatable {
  final String type;
  final String? schemaCode;
  final String? labelKey;
  final String? valueKey;
  final int? level;
  final String? parentKey;

  const SduiDataSource({
    required this.type,
    this.schemaCode,
    this.labelKey,
    this.valueKey,
    this.level,
    this.parentKey,
  });

  factory SduiDataSource.fromJson(Map<String, dynamic> json) => SduiDataSource(
        type: json['type'],
        schemaCode: json['schemaCode'],
        labelKey: json['labelKey'],
        valueKey: json['valueKey'],
        level: json['level'],
        parentKey: json['parentKey'],
      );

  @override
  List<Object?> get props => [type, schemaCode, level];
}

class SduiMaxDateRule extends Equatable {
  final String type;
  final int? years;

  const SduiMaxDateRule({required this.type, this.years});

  factory SduiMaxDateRule.fromJson(Map<String, dynamic> json) => SduiMaxDateRule(
        type: json['type'],
        years: json['years'],
      );

  DateTime get maxDate {
    final now = DateTime.now();
    if (type == 'today') return now;
    if (type == 'years_before_today' && years != null) {
      return DateTime(now.year - years!, now.month, now.day);
    }
    return now;
  }

  @override
  List<Object?> get props => [type, years];
}
