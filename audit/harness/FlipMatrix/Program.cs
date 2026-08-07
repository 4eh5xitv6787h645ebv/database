// Compares before/after regex pairs over a title list under exact Radarr semantics
// (.NET Regex, IgnoreCase). Prints only flips: name TAB direction TAB title.
using System.Text.Json;
using System.Text.RegularExpressions;

var input = JsonDocument.Parse(Console.In.ReadToEnd()).RootElement;
var pairs = new Dictionary<string, (Regex Before, Regex After)>();
foreach (var p in input.GetProperty("pairs").EnumerateObject())
{
    var b = p.Value.GetProperty("before").GetString()!;
    var a = p.Value.GetProperty("after").GetString()!;
    pairs[p.Name] = (
        new Regex(b, RegexOptions.IgnoreCase | RegexOptions.Compiled),
        new Regex(a, RegexOptions.IgnoreCase | RegexOptions.Compiled));
}
foreach (var t in input.GetProperty("titles").EnumerateArray())
{
    var title = t.GetString()!;
    foreach (var (name, rx) in pairs)
    {
        bool before = rx.Before.IsMatch(title), after = rx.After.IsMatch(title);
        if (before != after)
            Console.WriteLine($"{name}\t{(after ? "NEW-MATCH" : "LOST-MATCH")}\t{title}");
    }
}
