// Bridge file: exports from country_picker with interface compatible to country_code_picker
import 'package:country_picker/country_picker.dart' as cp;
import 'package:flutter/material.dart';

// Re-export Country for compatibility - aliased as CountryCode
export 'package:country_picker/country_picker.dart' hide CountryCode;

/// A widget that provides country code selection functionality
/// Compatible replacement for country_code_picker using country_picker package
class CountryCodePicker extends StatelessWidget {
  final void Function(CountryCode countryCode)? onChanged;
  final String? initialSelection;
  final List<String>? favorite;
  final bool showDropDownButton;
  final bool showCountryOnly;
  final bool showOnlyCountryWhenClosed;
  final bool showFlagDialog;
  final bool hideMainText;
  final bool showFlagMain;
  final Color? dialogBackgroundColor;
  final Color? barrierColor;
  final EdgeInsets? padding;
  final double? flagWidth;
  final TextStyle? textStyle;

  const CountryCodePicker({
    super.key,
    this.onChanged,
    this.initialSelection,
    this.favorite,
    this.showDropDownButton = false,
    this.showCountryOnly = false,
    this.showOnlyCountryWhenClosed = false,
    this.showFlagDialog = false,
    this.hideMainText = false,
    this.showFlagMain = true,
    this.dialogBackgroundColor,
    this.barrierColor,
    this.padding,
    this.flagWidth,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        cp.showCountryPicker(
          context: context,
          onSelect: (cp.Country country) {
            if (onChanged != null) {
              // Convert country_picker's Country to CountryCode format
              onChanged!(CountryCode(
                name: country.name,
                code: country.countryCode,
                dialCode: '+${country.phoneCode}',
                flagUri: 'flags/${country.countryCode.toLowerCase()}.png',
              ));
            }
          },
        );
      },
      child: Padding(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showFlagMain) ...[
              if (initialSelection != null)
                _buildFlag(initialSelection!),
              const SizedBox(width: 4),
            ],
            if (!hideMainText && initialSelection != null)
              Text(
                _getCountryCode(initialSelection!),
                style: textStyle ?? Theme.of(context).textTheme.bodyLarge,
              ),
            if (showDropDownButton)
              const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFlag(String countryCode) {
    final String flagUri = 'flags/${countryCode.toLowerCase()}.png';
    return Container(
      width: flagWidth ?? 25,
      height: 20,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        image: DecorationImage(
          image: AssetImage(flagUri),
          fit: BoxFit.cover,
          onError: (_, __) {},
        ),
      ),
    );
  }

  String _getCountryCode(String code) {
    // Try to get the dial code from country_picker
    try {
      final country = cp.Country.parse(code);
      return '+${country.phoneCode}';
    } catch (_) {
      // Fallback to the code itself
      return code;
    }
  }
}

/// Alias for CountryCodePicker widget
typedef CodePickerWidget = CountryCodePicker;

/// CountryCode class compatible with the old country_code_picker API
class CountryCode {
  final String? name;
  final String? code;
  final String? dialCode;
  final String? flagUri;

  CountryCode({
    this.name,
    this.code,
    this.dialCode,
    this.flagUri,
  });

  /// Factory constructor to create CountryCode from country code (e.g., "BD")
  factory CountryCode.fromCountryCode(String countryCode) {
    try {
      final country = cp.Country.parse(countryCode);
      return CountryCode(
        name: country.name,
        code: country.countryCode,
        dialCode: '+${country.phoneCode}',
        flagUri: 'flags/${country.countryCode.toLowerCase()}.png',
      );
    } catch (_) {
      // Fallback: return with the code as dialCode
      return CountryCode(
        code: countryCode,
        dialCode: countryCode,
      );
    }
  }

  @override
  String toString() => dialCode ?? code ?? '';

  @override
  int get hashCode => (name ?? '').hashCode;

  @override
  bool operator ==(Object other) {
    if (other is CountryCode) {
      return code == other.code || dialCode == other.dialCode;
    }
    return false;
  }
}
