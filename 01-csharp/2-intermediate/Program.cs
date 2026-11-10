// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
// ╔════════════════════════════════════════════════════════════════════════════╗
// ║                                                                            ║
// ║                                 ████  █ █                                  ║
// ║                                █     █████                                 ║
// ║                                █      █ █                                  ║
// ║                                █     █████                                 ║
// ║                                 ████  █ █                                  ║
// ║                                                                            ║
// ║                          LEVEL 2  ·  INTERMEDIATE                          ║
// ║                              ▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰                              ║
// ╚════════════════════════════════════════════════════════════════════════════╝
//
//    ▌ C# — دليل المتوسط
//
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  ◆ لمين هذا الملف؟
//  لك إذا خلصت الأساسيات وصرت تكتب برامج صغيرة، وتبي تكتب كود
//  مرتب ينفع في مشاريع حقيقية.
//
//  ◆ وش بتتعلم؟
//    Interfaces و Generics و Records و Pattern Matching
//    LINQ المتقدم، Delegates و Events، Extension Methods
//    async المتقدم (WhenAll, Cancellation)، IDisposable
//    Dependency Injection كفكرة
//
//  ◆ كيف تشغله؟
//    dotnet new console -n Intermediate
//    انسخ الملف مكان Program.cs ثم: dotnet run
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

// ╭──────────────────────────────────────────────────────────────╮
// │  01  ▸  Interface: عقد يقول "أي كلاس يطبقني لازم فيه هالدوال"
// ╰──────────────────────────────────────────────────────────────╯
//
//            ┌──────────────────────┐
//            │   INotifier (عقد)    │
//            │  + Send(message)     │
//            └──────────┬───────────┘
//                       │ implements
//          ┌────────────┴────────────┐
//          ▼                         ▼
//   ┌──────────────┐          ┌──────────────┐
//   │ EmailNotifier│          │  SmsNotifier │
//   └──────────────┘          └──────────────┘
//
//  الفايدة: الكود اللي يستخدم INotifier ما يهمه وش النوع الحقيقي،
//  فتقدر تبدل الإيميل بالـ SMS بدون ما تلمس باقي الكود.
public interface INotifier
{
    void Send(string message);
}

public class EmailNotifier : INotifier
{
    public void Send(string message) => Console.WriteLine($"[Email] {message}");
}

public class SmsNotifier : INotifier
{
    public void Send(string message) => Console.WriteLine($"[SMS] {message}");
}

// ╭──────────────────────────────────────────────────────────────╮
// │  02  ▸  Dependency Injection: لا تصنع اللي تحتاجه، خله يجيك من برا
// ╰──────────────────────────────────────────────────────────────╯
//  ❌ الكلاس يسوي new EmailNotifier() بنفسه = مربوط فيه للأبد وصعب تختبره
//  ✅ ياخذه في الـ constructor = تقدر تعطيه أي نوع (حتى نسخة وهمية للاختبار)
//  ASP.NET Core يحقنها لك تلقائي بعد ما تسجلها بـ builder.Services.AddScoped<...>()
public class OrderService
{
    private readonly INotifier _notifier;

    public OrderService(INotifier notifier)
    {
        _notifier = notifier ?? throw new ArgumentNullException(nameof(notifier));
    }

    public void PlaceOrder(int orderId) => _notifier.Send($"Order #{orderId} placed");
}

// ╭──────────────────────────────────────────────────────────────╮
// │  03  ▸  Generics: كود واحد يشتغل مع أي نوع وبأمان
// ╰──────────────────────────────────────────────────────────────╯
//  where T : class = قيد: T لازم يكون نوع مرجعي (class أو interface أو record)، مو int ولا struct
public class Repository<T> where T : class
{
    private readonly List<T> _items = new();

    public void Add(T item) => _items.Add(item);

    public IReadOnlyList<T> GetAll() => _items.AsReadOnly();

    public T? Find(Func<T, bool> predicate) => _items.FirstOrDefault(predicate);
}

// ╭──────────────────────────────────────────────────────────────╮
// │  04  ▸  Record: كلاس للبيانات، يقارن بالقيمة مو بالمرجع
// ╰──────────────────────────────────────────────────────────────╯
//
//   class:   new User("Ali") == new User("Ali")    -> false (مكانين مختلفين)
//   record:  new UserDto("Ali") == new UserDto("Ali") -> true  (نفس القيم)
//
public record Product(int Id, string Name, decimal Price, string Category);

// ╭──────────────────────────────────────────────────────────────╮
// │  05  ▸  Custom Exception: خطأ خاص بمشروعك له معنى واضح
// ╰──────────────────────────────────────────────────────────────╯
public class InsufficientBalanceException : Exception
{
    public decimal Missing { get; }

    public InsufficientBalanceException(decimal missing)
        : base($"Missing {missing:F2} SAR") => Missing = missing;
}

// ╭──────────────────────────────────────────────────────────────╮
// │  06  ▸  Events و Delegates: "خبرني لما يصير شيء"
// ╰──────────────────────────────────────────────────────────────╯
//
//    Account ──(BalanceChanged)──►  Logger
//                     │
//                     └──────────►  UI
//
//  Account ما يعرف مين يسمع له، بس يطلق الحدث.
public class Account
{
    public event EventHandler<decimal>? BalanceChanged;

    public decimal Balance { get; private set; }

    public void Deposit(decimal amount)
    {
        if (amount <= 0)
            throw new ArgumentOutOfRangeException(nameof(amount), "Amount must be positive");

        Balance += amount;
        BalanceChanged?.Invoke(this, Balance);
    }

    public void Withdraw(decimal amount)
    {
        if (amount > Balance)
            throw new InsufficientBalanceException(amount - Balance);

        Balance -= amount;
        BalanceChanged?.Invoke(this, Balance);
    }
}

// ╭──────────────────────────────────────────────────────────────╮
// │  07  ▸  Extension Methods: تضيف دوال لنوع موجود بدون ما تعدله
// ╰──────────────────────────────────────────────────────────────╯
public static class StringExtensions
{
    public static string Truncate(this string value, int max) =>
        value.Length <= max ? value : value[..max] + "...";

    public static bool IsNullOrBlank(this string? value) => string.IsNullOrWhiteSpace(value);
}

// ╭──────────────────────────────────────────────────────────────╮
// │  08  ▸  IDisposable: تنظيف الموارد بنفسك
// ╰──────────────────────────────────────────────────────────────╯
public sealed class ScopeTimer : IDisposable
{
    private readonly string _name;
    private readonly DateTime _start = DateTime.Now;

    public ScopeTimer(string name) => _name = name;

    public void Dispose() =>
        Console.WriteLine($"{_name} took {(DateTime.Now - _start).TotalMilliseconds:F0} ms");
}

public static class Program
{
    public static async Task Main()
    {
        // ╭──────────────────────────────────────────────────────────────╮
        // │  09  ▸  استخدام DI و Interfaces
        // ╰──────────────────────────────────────────────────────────────╯
        var service = new OrderService(new SmsNotifier());
        service.PlaceOrder(101);

        // ╭──────────────────────────────────────────────────────────────╮
        // │  10  ▸  LINQ المتقدم
        // ╰──────────────────────────────────────────────────────────────╯
        var products = new List<Product>
        {
            new(1, "Laptop", 3500m, "Electronics"),
            new(2, "Mouse", 75m, "Electronics"),
            new(3, "Desk", 900m, "Furniture"),
            new(4, "Chair", 450m, "Furniture"),
        };

        // GroupBy: جمّع حسب التصنيف
        var byCategory = products
            .GroupBy(p => p.Category)
            .Select(g => new
            {
                Category = g.Key,
                Count = g.Count(),
                Total = g.Sum(p => p.Price),
                Cheapest = g.MinBy(p => p.Price)!.Name
            });

        foreach (var g in byCategory)
            Console.WriteLine($"{g.Category}: {g.Count} items, total {g.Total}, cheapest {g.Cheapest}");

        // ToDictionary: بحث سريع بالمفتاح
        Dictionary<int, Product> byId = products.ToDictionary(p => p.Id);

        // ⚠️ LINQ "كسول": ما يشتغل إلا لما تلف عليه أو تطلب نتيجة نهائية (ToList, Count, Sum, First...)
        //    لو بتستخدم النتيجة أكثر من مرة سو ToList عشان ما يعيد الحساب كل مرة
        var expensive = products.Where(p => p.Price > 500).ToList();

        // with: نسخة من record مع تعديل (الأصل ما يتغير)
        var discounted = products[0] with { Price = 3000m };
        Console.WriteLine($"{products[0].Price} -> {discounted.Price}");

        // ╭──────────────────────────────────────────────────────────────╮
        // │  11  ▸  Pattern Matching
        // ╰──────────────────────────────────────────────────────────────╯
        object[] things = { 42, "hello", 3.5, null!, new Product(9, "X", 10m, "Y") };
        foreach (var t in things)
            Console.WriteLine(Describe(t));

        // ╭──────────────────────────────────────────────────────────────╮
        // │  12  ▸  Generics
        // ╰──────────────────────────────────────────────────────────────╯
        var repo = new Repository<Product>();
        products.ForEach(repo.Add);
        Console.WriteLine(repo.Find(p => p.Name == "Desk")?.Price);

        // ╭──────────────────────────────────────────────────────────────╮
        // │  13  ▸  Events و Custom Exceptions
        // ╰──────────────────────────────────────────────────────────────╯
        var account = new Account();
        account.BalanceChanged += (_, balance) => Console.WriteLine($"New balance: {balance}");
        account.Deposit(100);

        try
        {
            account.Withdraw(250);
        }
        catch (InsufficientBalanceException ex)
        {
            Console.WriteLine($"Failed: {ex.Message} (missing {ex.Missing})");
        }

        Console.WriteLine("A very long product description".Truncate(10));

        // ╭──────────────────────────────────────────────────────────────╮
        // │  14  ▸  async المتقدم
        // ╰──────────────────────────────────────────────────────────────╯
        //
        //  واحد ورا الثاني (بطيء):
        //    [── A 1s ──][── B 1s ──][── C 1s ──]           = 3s
        //
        //  مع بعض (تبدأهم كلهم أول، وبعدين تنتظرهم بـ Task.WhenAll):
        //    [── A 1s ──]
        //    [── B 1s ──]                                   = 1s
        //    [── C 1s ──]
        //
        using (new ScopeTimer("WhenAll"))
        {
            var results = await Task.WhenAll(
                FetchAsync("users", 300),
                FetchAsync("orders", 300),
                FetchAsync("products", 300));
            Console.WriteLine(string.Join(", ", results));
        }

        // CancellationToken: تلغي عملية طولت
        using var cts = new CancellationTokenSource(TimeSpan.FromMilliseconds(200));
        try
        {
            await SlowOperationAsync(cts.Token);
        }
        catch (OperationCanceledException)
        {
            Console.WriteLine("Operation cancelled (timeout)");
        }

        // ⚠️ لا تسوي .Result أو .Wait() على Task
        //    تعلّق الثريد وهو ينتظر، وفي تطبيقات الواجهات (WinForms/WPF) ممكن تسوي Deadlock
        //    ويعلق البرنامج كامل، استخدم await
    }

    static string Describe(object? value) => value switch
    {
        null => "null value",
        int n when n > 40 => $"big int {n}",
        int n => $"int {n}",
        string s => $"string of length {s.Length}",
        Product { Price: > 5 } p => $"product {p.Name}",
        _ => $"other: {value.GetType().Name}"
    };

    static async Task<string> FetchAsync(string name, int delayMs)
    {
        await Task.Delay(delayMs);
        return $"{name} loaded";
    }

    static async Task SlowOperationAsync(CancellationToken token)
    {
        for (int i = 0; i < 10; i++)
        {
            token.ThrowIfCancellationRequested();
            await Task.Delay(100, token);
        }
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  ┃  ⚠️  أغلاط المستوى المتوسط
//
//  1. .Result و .Wait()                -> تعلّق الثريد، وممكن Deadlock في تطبيقات الواجهات، استخدم await
//  2. new للخدمات داخل الكلاسات        -> استخدم Dependency Injection
//  3. تكرر LINQ الكسول أكثر من مرة     -> ToList مرة وحدة
//  4. تشترك في Event من كائن يعيش طويل وما تلغي (-=) -> تسريب ذاكرة
//  5. ترمي Exception عامة لكل شيء      -> اعمل Exceptions لها معنى
//  6. ترجع List قابلة للتعديل من كلاسك -> IReadOnlyList
//  7. عمليات طويلة بدون CancellationToken
//  8. تشغل Tasks مستقلة ورا بعض        -> Task.WhenAll
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
