// Evaluates (pattern, title) pairs under the exact semantics Radarr/Sonarr use:
// .NET Regex with RegexOptions.IgnoreCase (Radarr RegexSpecificationBase).
//
// stdin JSON:
// {
//   "patterns":   { name: pattern, ... },
//   "composites": [ { "name": n, "all": [patternName...], "none": [patternName...] } ],
//   "cases":      [ { "title": t, "expect": { nameOrCompositeName: bool } } ]
// }
// Composites model custom-format condition graphs: every "all" pattern must match
// the title and no "none" pattern may match (Radarr: required + negated conditions).
//
// stdout TSV: title <TAB> name <TAB> expected <TAB> actual <TAB> verdict
// Only labeled (title,name) pairs are printed. Exit 1 if any labeled check fails.
using System.Text.Json;
using System.Text.RegularExpressions;

var input = JsonDocument.Parse(Console.In.ReadToEnd()).RootElement;

var patterns = new Dictionary<string, Regex>();
foreach (var p in input.GetProperty("patterns").EnumerateObject())
    patterns[p.Name] = new Regex(p.Value.GetString()!, RegexOptions.IgnoreCase | RegexOptions.Compiled);

var composites = new List<(string Name, string[] All, string[] None)>();
if (input.TryGetProperty("composites", out var comps))
    foreach (var c in comps.EnumerateArray())
        composites.Add((
            c.GetProperty("name").GetString()!,
            c.TryGetProperty("all", out var a) ? a.EnumerateArray().Select(x => x.GetString()!).ToArray() : [],
            c.TryGetProperty("none", out var n) ? n.EnumerateArray().Select(x => x.GetString()!).ToArray() : []));

int failures = 0, checks = 0;
foreach (var c in input.GetProperty("cases").EnumerateArray())
{
    var title = c.GetProperty("title").GetString()!;
    var expect = c.GetProperty("expect");

    var actuals = new Dictionary<string, bool>();
    foreach (var (name, rx) in patterns) actuals[name] = rx.IsMatch(title);
    foreach (var (name, all, none) in composites)
        actuals[name] = all.All(p => actuals[p]) && none.All(p => !actuals[p]);

    foreach (var e in expect.EnumerateObject())
    {
        if (!actuals.TryGetValue(e.Name, out var actual))
            throw new Exception($"unknown pattern/composite '{e.Name}' for title '{title}'");
        bool exp = e.Value.GetBoolean();
        checks++;
        string verdict = exp == actual ? "ok" : (actual ? "FALSE_POSITIVE" : "FALSE_NEGATIVE");
        if (exp != actual) failures++;
        Console.WriteLine($"{title}\t{e.Name}\t{exp}\t{actual}\t{verdict}");
    }
}
Console.Error.WriteLine($"{checks} labeled checks, {failures} failures");
Environment.Exit(failures == 0 ? 0 : 1);
