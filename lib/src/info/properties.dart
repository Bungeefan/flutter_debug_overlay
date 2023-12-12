// Contains code from the following authors:
//
// Copyright 2014 The Flutter Authors. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above
//       copyright notice, this list of conditions and the following
//       disclaimer in the documentation and/or other materials provided
//       with the distribution.
//     * Neither the name of Google Inc. nor the names of its
//       contributors may be used to endorse or promote products derived
//       from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
// ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
// ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import 'package:flutter/foundation.dart';

abstract class DebugPropertyNode {
  final String? name;
  final bool showName;
  final bool showSeparator;

  DebugPropertyNode({
    required this.name,
    this.showName = true,
    this.showSeparator = true,
  }) : assert(
          name == null || !name.endsWith(":"),
          "Names must not end with colons.\n"
          "name:\n"
          '  "$name"',
        );

  Object? get value;

  String? get tooltip;

  /// Children of this [DebugPropertyNode].
  List<DebugPropertyNode> getChildren();

  /// Properties of this [DebugPropertyNode].
  List<DebugPropertyNode> getProperties();

  /// Returns a description with a short summary of the node itself not
  /// including children or properties.
  String toDescription();
}

class DebugBlock extends DebugPropertyNode {
  DebugBlock({
    super.name,
    bool showName = true,
    super.showSeparator,
    this.value,
    String? description,
    List<DebugPropertyNode> children = const [],
    List<DebugPropertyNode> properties = const [],
  })  : _description = description ?? '',
        _children = children,
        _properties = properties,
        super(
          showName: showName && name != null,
        );

  final List<DebugPropertyNode> _children;
  final List<DebugPropertyNode> _properties;

  final String _description;

  @override
  final Object? value;

  @override
  String? get tooltip => null;

  @override
  List<DebugPropertyNode> getChildren() => _children;

  @override
  List<DebugPropertyNode> getProperties() => _properties;

  @override
  String toDescription() => _description;
}

class DebugProperty<T> extends DebugPropertyNode {
  DebugProperty(
    String? name,
    this.value, {
    super.showName,
    super.showSeparator,
    this.description,
    this.ifNull,
    this.ifEmpty,
    this.defaultValue = kNoDefaultValue,
    this.tooltip,
  }) : super(name: name);

  /// The type of the property [value].
  Type get propertyType => T;

  @override
  final T? value;

  /// Description if the property [value] is null.
  final String? ifNull;

  /// Description if the property description would otherwise be empty.
  final String? ifEmpty;

  @override
  final String? tooltip;

  /// The default value of this property, when it has not been set to a specific
  /// value.
  ///
  /// The [defaultValue] is [kNoDefaultValue] by default. Otherwise it must be of
  /// type `T?`.
  final Object? defaultValue;

  final String? description;

  /// Returns a string representation of the property value.
  ///
  /// Subclasses should override this method instead of [toDescription] to
  /// customize how property values are converted to strings.
  String valueToString() {
    return value.toString();
  }

  @override
  String toDescription() {
    if (description != null) {
      return description!;
    }

    if (ifNull != null && value == null) {
      return ifNull!;
    }

    String result = valueToString();
    if (result.isEmpty && ifEmpty != null) {
      result = ifEmpty!;
    }
    return result;
  }

  @override
  List<DebugPropertyNode> getChildren() {
    final T? object = value;
    if (object is DebugPropertyNode) {
      return object.getChildren();
    }
    return const [];
  }

  @override
  List<DebugPropertyNode> getProperties() {
    final T? object = value;
    if (object is DebugPropertyNode) {
      return object.getProperties();
    }
    return const [];
  }
}

class DebugStringProperty extends DebugProperty<String> {
  /// Create a diagnostics property for strings.
  DebugStringProperty(
    String super.name,
    super.value, {
    super.description,
    super.tooltip,
    super.showName,
    super.defaultValue,
    this.quoted = true,
    super.ifEmpty,
    super.ifNull,
  });

  /// Whether the value is enclosed in double quotes.
  final bool quoted;

  @override
  String valueToString() {
    String? text = description ?? value;

    if (quoted && text != null) {
      // An empty value would not appear empty after being surrounded with
      // quotes so we have to handle this case separately.
      if (ifEmpty != null && text.isEmpty) {
        return ifEmpty!;
      }
      return '"$text"';
    }
    return text.toString();
  }
}

abstract class _DebugNumProperty<T extends num> extends DebugProperty<T> {
  _DebugNumProperty(
    String super.name,
    super.value, {
    super.ifNull,
    this.unit,
    super.showName,
    super.defaultValue,
    super.tooltip,
  });

  /// Optional unit the [value] is measured in.
  ///
  /// Unit must be acceptable to display immediately after a number with no
  /// spaces. For example: 'physical pixels per logical pixel' should be a
  /// [tooltip] not a [unit].
  final String? unit;

  /// String describing just the numeric [value] without a unit suffix.
  String numberToString();

  @override
  String valueToString() {
    if (value == null) {
      return value.toString();
    }

    return unit != null ? '${numberToString()}$unit' : numberToString();
  }
}

/// Property describing a [double] [value] with an optional [unit] of measurement.
///
/// Numeric formatting is optimized for debug message readability.
class DebugDoubleProperty extends _DebugNumProperty<double> {
  /// If specified, [unit] describes the unit for the [value] (e.g. px).
  DebugDoubleProperty(
    super.name,
    super.value, {
    super.ifNull,
    super.unit,
    super.tooltip,
    super.defaultValue,
    super.showName,
  });

  @override
  String numberToString() => debugFormatDouble(value);
}

/// An int valued property with an optional unit the value is measured in.
///
/// Examples of units include 'px' and 'ms'.
class DebugIntProperty extends _DebugNumProperty<int> {
  /// Create a diagnostics property for integers.
  DebugIntProperty(
    super.name,
    super.value, {
    super.ifNull,
    super.showName,
    super.unit,
    super.defaultValue,
  });

  @override
  String numberToString() => value.toString();
}

class DebugFlagProperty extends DebugProperty<bool> {
  /// Constructs a FlagProperty with the given descriptions with the specified descriptions.
  ///
  /// [showName] defaults to false as typically [ifTrue] and [ifFalse] should
  /// be descriptions that make the property name redundant.
  DebugFlagProperty(
    String name, {
    required bool? value,
    this.ifTrue,
    this.ifFalse,
    super.tooltip,
    bool showName = false,
    Object? defaultValue,
  })  : assert(ifTrue != null || ifFalse != null),
        super(
          name,
          value,
          showName: showName,
          defaultValue: defaultValue,
        );

  /// Description to use if the property [value] is true.
  final String? ifTrue;

  /// Description to use if the property value is false.
  final String? ifFalse;

  @override
  String valueToString() {
    if (value ?? false) {
      if (ifTrue != null) {
        return ifTrue!;
      }
    } else if (value == false) {
      if (ifFalse != null) {
        return ifFalse!;
      }
    }
    return super.valueToString();
  }

  @override
  bool get showName {
    if (value == null ||
        ((value ?? false) && ifTrue == null) ||
        (!(value ?? true) && ifFalse == null)) {
      // We are missing a description for the flag value so we need to show the
      // flag name. The property will have DiagnosticLevel.hidden for this case
      // so users will not see this the property in this case unless they are
      // displaying hidden properties.
      return true;
    }
    return super.showName;
  }
}

class DebugIterableProperty<T> extends DebugProperty<Iterable<T>> {
  /// Create a diagnostics property for iterables (e.g. lists).
  ///
  /// The [ifEmpty] argument is used to indicate how an iterable [value] with 0
  /// elements is displayed. If [ifEmpty] equals null that indicates that an
  /// empty iterable [value] is not interesting to display similar to how
  /// [defaultValue] is used to indicate that a specific concrete value is not
  /// interesting to display.
  DebugIterableProperty(
    String super.name,
    super.value, {
    super.defaultValue,
    super.ifNull,
    super.ifEmpty = '[]',
    super.showName,
    super.showSeparator,
  });

  @override
  String valueToString() {
    if (value == null) {
      return value.toString();
    }

    if (value!.isEmpty) {
      return ifEmpty ?? '[]';
    }

    final Iterable<String> formattedValues = value!.map((T v) {
      if (T == double && v is double) {
        return debugFormatDouble(v);
      } else {
        return v.toString();
      }
    });

    return formattedValues.join('\n');
  }
}

class DebugEnumProperty<T extends Enum?> extends DebugProperty<T> {
  /// Create a diagnostics property that displays an enum.
  DebugEnumProperty(
    String super.name,
    super.value, {
    super.defaultValue,
  });

  @override
  String valueToString() {
    if (value == null) {
      return value.toString();
    }
    return value!.name;
  }
}
