using System.Globalization;
using Balenthiran.EarnYourBeers.Abstractions.Exceptions;

namespace Balenthiran.EarnYourBeers.Services;

/// <summary>
/// BEH-VICE-1, ported from lib/ui/dialogs/vice_settings_dialog.dart:31-35 and 59-63: trim, empty falls
/// back to the pizza, at most two characters (Flutter's maxLength counts what a person sees, so a
/// surrogate pair is one), and no ASCII at all, which keeps plain text out.
/// </summary>
public static class ViceRules
{
    public const string Default = "🍕";
    public const int MaxCharacters = 2;

    // Not in the Dart: one flag or family emoji is a single character but many code units, and a
    // string with no ASCII could otherwise be arbitrarily long combining marks. A guard, not a port.
    private const int MaxCodeUnits = 32;

    public static string Normalise(string? input)
    {
        var emoji = (input ?? "").Trim();
        if (emoji.Length == 0)
        {
            return Default;
        }

        if (emoji.Any(c => c <= '\u007F'))
        {
            throw new ValidationException("A vice must be an emoji, not plain text.");
        }

        if (emoji.Length > MaxCodeUnits || new StringInfo(emoji).LengthInTextElements > MaxCharacters)
        {
            throw new ValidationException($"A vice can be at most {MaxCharacters} characters.");
        }

        return emoji;
    }
}
