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
// ║                             LEVEL 1  ·  BASICS                             ║
// ║                              ▰▰▰▰▰▰▰▰▱▱▱▱▱▱▱▱                              ║
// ╚════════════════════════════════════════════════════════════════════════════╝
//
//    ▌ C# — دليل المبتدئ
//
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  ◆ وش هي؟
//  لغة من مايكروسوفت، تستخدمها في:
//    - تطبيقات ويندوز
//    - مواقع وباك إند (ASP.NET)
//    - ألعاب (Unity)
//
//  ◆ كيف تشغل الملف؟
//    dotnet new console -n MyApp
//    انسخ الكود هذا مكان Program.cs
//    dotnet run
//
//  ◆ أهم شيء تعرفه:
//    - الكود منظم داخل كلاسات (وفيه طريقة مختصرة اسمها Top-level statements
//      تشوفها في القالب الافتراضي، بس هنا كتبناها كاملة عشان تفهم)
//    - كل أمر (statement) ينتهي بـ ;
//    - الأنواع صارمة: كل متغير له نوع ثابت، ما تقدر تحط نص في متغير int أو العكس
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;

class Program
{
    // Main هي نقطة البداية، البرنامج يبدأ من هنا
    static async Task Main()
    {
        // ╭──────────────────────────────────────────────────────────────╮
        // │  01  ▸  المتغيرات والأنواع
        // ╰──────────────────────────────────────────────────────────────╯
        int age = 20;              // رقم صحيح
        double price = 9.99;       // رقم عشري
        decimal money = 150.75m;   // للفلوس استخدم decimal دايمًا (لاحظ حرف m)
        string name = "Ahmed";     // نص
        bool isActive = true;      // صح أو غلط
        char letter = 'A';         // حرف واحد بين علامتين مفردة
        var city = "Riyadh";       // var: خل اللغة تعرف النوع لحالها (هنا string)

        const double Pi = 3.14159; // const: قيمة ثابتة ما تتغير أبد

        // ╭──────────────────────────────────────────────────────────────╮
        // │  02  ▸  الطباعة
        // ╰──────────────────────────────────────────────────────────────╯
        // $ قبل النص تخليك تحط متغيرات داخل {}
        Console.WriteLine($"Hello {name}, you are {age} years old");
        Console.WriteLine($"Price: {price:F2}"); // F2 = رقمين بعد الفاصلة

        // ╭──────────────────────────────────────────────────────────────╮
        // │  03  ▸  الشروط
        // ╰──────────────────────────────────────────────────────────────╯
        if (age >= 18)
        {
            Console.WriteLine("Adult");
        }
        else if (age >= 13)
        {
            Console.WriteLine("Teen");
        }
        else
        {
            Console.WriteLine("Child");
        }

        // switch: بديل مرتب لـ if كثيرة
        string role = "admin";
        string message = role switch
        {
            "admin" => "Full access",
            "user" => "Limited access",
            _ => "No access" // _ يعني أي شيء ثاني
        };
        Console.WriteLine(message);

        // ╭──────────────────────────────────────────────────────────────╮
        // │  04  ▸  التكرار (Loops)
        // ╰──────────────────────────────────────────────────────────────╯
        // for: لما تعرف كم مرة بتكرر
        for (int i = 0; i < 5; i++)
        {
            Console.WriteLine(i); // يطبع 0 إلى 4
        }

        // while: يكرر طالما الشرط صح
        int count = 3;
        while (count > 0)
        {
            Console.WriteLine($"Count: {count}");
            count--; // لا تنساها وإلا اللوب ما يوقف أبد!
        }

        // ╭──────────────────────────────────────────────────────────────╮
        // │  05  ▸  المصفوفات والقوائم
        // ╰──────────────────────────────────────────────────────────────╯
        // المصفوفة (Array): حجمها ثابت
        int[] numbers = { 10, 20, 30 };
        Console.WriteLine(numbers[0]); // أول عنصر رقمه 0 مو 1

        // القائمة (List): حجمها يكبر ويصغر - هذي اللي بتستخدمها أكثر
        List<string> names = new List<string> { "Ali", "Sara", "Omar" };
        names.Add("Noor");
        names.Remove("Ali");

        // foreach: تلف على كل عنصر
        foreach (string n in names)
        {
            Console.WriteLine(n);
        }

        // Dictionary: مفتاح وقيمة (زي القاموس)
        Dictionary<string, int> scores = new Dictionary<string, int>
        {
            ["Ali"] = 90,
            ["Sara"] = 95
        };

        // TryGetValue أأمن من scores["Omar"] اللي يطيح لو المفتاح مو موجود
        if (scores.TryGetValue("Omar", out int omarScore))
            Console.WriteLine(omarScore);
        else
            Console.WriteLine("Omar not found");

        // ╭──────────────────────────────────────────────────────────────╮
        // │  06  ▸  LINQ: طريقة سهلة تفلتر وترتب وتحسب على القوائم
        // ╰──────────────────────────────────────────────────────────────╯
        List<int> values = new List<int> { 5, 2, 8, 1, 9 };

        var bigValues = values.Where(v => v > 4).ToList();   // الأكبر من 4
        var sorted = values.OrderBy(v => v).ToList();        // ترتيب تصاعدي
        int total = values.Sum();                            // المجموع
        bool hasNine = values.Any(v => v == 9);              // فيه 9؟

        Console.WriteLine(string.Join(", ", bigValues));

        // ╭──────────────────────────────────────────────────────────────╮
        // │  07  ▸  الدوال
        // ╰──────────────────────────────────────────────────────────────╯
        Console.WriteLine(Add(3, 4));
        Console.WriteLine(Greet("Sara"));
        Console.WriteLine(Greet()); // يستخدم القيمة الافتراضية

        // ╭──────────────────────────────────────────────────────────────╮
        // │  08  ▸  التعامل مع الأخطاء
        // ╰──────────────────────────────────────────────────────────────╯
        // ⚠️ غلط شائع: int.Parse يطيح البرنامج لو النص مو رقم
        try
        {
            int bad = int.Parse("abc");
        }
        catch (FormatException ex)
        {
            Console.WriteLine("Invalid number: " + ex.Message);
        }

        // ✅ الأفضل: TryParse ما يطيح، يرجع true أو false
        if (int.TryParse("123", out int parsed))
        {
            Console.WriteLine($"Parsed: {parsed}");
        }

        // ╭──────────────────────────────────────────────────────────────╮
        // │  09  ▸  null وكيف تتجنب NullReferenceException
        // ╰──────────────────────────────────────────────────────────────╯
        // ⚠️ أشهر خطأ في C#: تستخدم شيء قيمته null
        string? maybeName = null;

        // ❌ غلط: maybeName.Length بيطيح البرنامج
        // ✅ صح: ?. يرجع null بدل ما يطيح، و ?? يعطي قيمة بديلة
        int length = maybeName?.Length ?? 0;
        Console.WriteLine(length);

        // ╭──────────────────────────────────────────────────────────────╮
        // │  10  ▸  الكلاسات والكائنات
        // ╰──────────────────────────────────────────────────────────────╯
        Car car = new Car("Camry", 2024);
        car.Drive();
        Console.WriteLine(car.Model);

        ElectricCar tesla = new ElectricCar("Model 3", 2025, 80);
        tesla.Drive();

        // ╭──────────────────────────────────────────────────────────────╮
        // │  11  ▸  الملفات + using
        // ╰──────────────────────────────────────────────────────────────╯
        // using يقفل الملف تلقائي حتى لو صار خطأ
        // ⚠️ لو ما قفلته يظل مفتوح لين الـ GC يفضيه بوقت ما تعرفه،
        //    وفي هالوقت ممكن ما تقدر تكتب عليه أو تحذفه
        File.WriteAllText("test.txt", "Hello file");
        using (var reader = new StreamReader("test.txt"))
        {
            Console.WriteLine(reader.ReadToEnd());
        }

        // ╭──────────────────────────────────────────────────────────────╮
        // │  12  ▸  async / await: للعمليات اللي تاخذ وقت (نت، ملفات، داتابيس)
        // ╰──────────────────────────────────────────────────────────────╯
        // ⚠️ لا تنسى await، وإلا الكود يكمل قبل ما تخلص العملية
        string result = await LoadDataAsync();
        Console.WriteLine(result);

        // ╭──────────────────────────────────────────────────────────────╮
        // │  13  ▸  مقارنة النصوص
        // ╰──────────────────────────────────────────────────────────────╯
        // ⚠️ "ali" و "Ali" مو نفس الشيء، لو تبي تتجاهل حالة الأحرف:
        bool same = string.Equals("ali", "Ali", StringComparison.OrdinalIgnoreCase);
        Console.WriteLine(same); // True
    }

    // دالة تاخذ رقمين وترجع مجموعهم
    // int الأولى = نوع اللي ترجعه، وداخل الأقواس = اللي تاخذه
    static int Add(int a, int b)
    {
        return a + b;
    }

    // قيمة افتراضية: لو ما عطيتها اسم تستخدم "Guest"
    static string Greet(string name = "Guest") => $"Welcome {name}";

    // ⚠️ لا تكتب async void، اكتب async Task
    //    (الاستثناء الوحيد: event handlers زي ضغطة زر)
    static async Task<string> LoadDataAsync()
    {
        await Task.Delay(500); // يمثل عملية تاخذ نص ثانية
        return "Data loaded";
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  الكلاس = قالب، والكائن (Object) = نسخة منه
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
//          ┌──────────────────┐
//          │   class Car      │   القالب
//          │   Model, Year    │
//          │   Drive()        │
//          └────────┬─────────┘
//                   │  new Car(...)
//        ┌──────────┼──────────┐
//        ▼          ▼          ▼
//   ┌─────────┐┌─────────┐┌─────────┐
//   │ Camry   ││ Accord  ││ Sonata  │   الكائنات
//   │ 2024    ││ 2023    ││ 2025    │
//   └─────────┘└─────────┘└─────────┘
//
class Car
{
    // Property: خاصية تقدر تقراها، و private set يعني ما أحد يغيرها من برا
    public string Model { get; private set; }
    public int Year { get; private set; }

    // Constructor: يشتغل أول ما تسوي new Car(...)
    public Car(string model, int year)
    {
        Model = model;
        Year = year;
    }

    // virtual: يسمح للكلاسات اللي تورث منه تغير الدالة
    public virtual void Drive()
    {
        Console.WriteLine($"{Model} is driving");
    }
}

// الوراثة: ElectricCar ياخذ كل شيء من Car ويزيد عليه
class ElectricCar : Car
{
    public int Battery { get; }

    public ElectricCar(string model, int year, int battery) : base(model, year)
    {
        Battery = battery;
    }

    public override void Drive()
    {
        Console.WriteLine($"{Model} is driving silently with {Battery}% battery");
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  ┃  ⚠️  ملخص الأغلاط اللي لازم ما تطيح فيها
//
//  1. تستخدم متغير قيمته null           -> استخدم ?. و ??
//  2. int.Parse على نص من المستخدم      -> استخدم int.TryParse
//  3. تنسى await                        -> النتيجة تجيك Task بدل البيانات
//  4. async void                        -> استخدم async Task (إلا في event handlers)
//  5. ما تقفل الملفات والاتصالات        -> استخدم using
//  6. double للفلوس                     -> استخدم decimal
//  7. تقارن نصوص بدون انتباه للأحرف    -> StringComparison.OrdinalIgnoreCase
//  8. catch (Exception) {} فاضية       -> تخفي الأخطاء وما تدري وش صار
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
