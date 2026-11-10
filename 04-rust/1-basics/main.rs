// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
// ╔════════════════════════════════════════════════════════════════════════════╗
// ║                                                                            ║
// ║                          ████  █   █  ████ █████                           ║
// ║                          █   █ █   █ █       █                             ║
// ║                          ████  █   █  ███    █                             ║
// ║                          █  █  █   █     █   █                             ║
// ║                          █   █  ███  ████    █                             ║
// ║                                                                            ║
// ║                             LEVEL 1  ·  BASICS                             ║
// ║                              ▰▰▰▰▰▰▰▰▱▱▱▱▱▱▱▱                              ║
// ╚════════════════════════════════════════════════════════════════════════════╝
//
//    ▌ Rust — دليل المبتدئ
//
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  ◆ وش هي؟
//  لغة حديثة سريعة مثل C++ لكن آمنة في الذاكرة.
//  تستخدم في: الأنظمة، السيرفرات، أدوات سطر الأوامر، WebAssembly.
//
//  ◆ كيف تشغل الملف؟
//    cargo new my_app
//    انسخ الكود هذا مكان src/main.rs
//    cargo run
//
//  ◆ أهم شيء تعرفه:
//    - المترجم صارم جدًا، ورسائل أخطائه ممتازة: اقراها!
//    - المتغيرات ثابتة افتراضيًا، لو تبي تعدل لازم mut
//    - مفهوم الملكية (Ownership) هو قلب اللغة:
//        1. كل قيمة لها مالك واحد بس
//        2. لما المالك يطلع من النطاق {} القيمة تنحذف تلقائي
//        3. تقدر "تستعير" القيمة بـ & بدل ما تاخذها
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

use std::collections::HashMap;
use std::fs;

// ╭──────────────────────────────────────────────────────────────╮
// │  ▸  struct + impl = زي الكلاس
// ╰──────────────────────────────────────────────────────────────╯
// derive: يضيف خصائص جاهزة (Debug للطباعة، Clone للنسخ)
#[derive(Debug, Clone)]
struct User {
    name: String,
    age: u32, // u32 = رقم صحيح بدون سالب (من 0 وفوق)
}

impl User {
    // Self = نفس النوع (User)، هذي زي الـ constructor
    fn new(name: &str, age: u32) -> Self {
        User {
            name: name.to_string(),
            age,
        }
    }

    // &self = تقرا بس
    fn greet(&self) {
        println!("Hello, I'm {} and I'm {}", self.name, self.age);
    }

    // &mut self = تعدل على الكائن
    fn birthday(&mut self) {
        self.age += 1;
    }
}

// ╭──────────────────────────────────────────────────────────────╮
// │  ▸  enum: نوع له حالات محددة، وكل حالة ممكن تحمل بيانات
// ╰──────────────────────────────────────────────────────────────╯
enum Status {
    Active,
    Banned(String),
    Suspended { days: u32 },
}

// Trait = زي الـ interface: يحدد دوال لازم يطبقها النوع
trait Describe {
    fn describe(&self) -> String;
}

impl Describe for User {
    fn describe(&self) -> String {
        format!("User {} ({})", self.name, self.age)
    }
}

// ╭──────────────────────────────────────────────────────────────╮
// │  ▸  الدوال
// ╰──────────────────────────────────────────────────────────────╯
fn add(a: i32, b: i32) -> i32 {
    a + b // آخر سطر بدون ; = هو اللي يرجع
}

// Result: إما Ok(قيمة) أو Err(خطأ) - Rust ما فيها exceptions
fn divide(a: f64, b: f64) -> Result<f64, String> {
    if b == 0.0 {
        return Err("Cannot divide by zero".to_string());
    }
    Ok(a / b)
}

// علامة ? : لو صار خطأ ترجعه للي استدعى الدالة على طول
fn read_config() -> Result<String, std::io::Error> {
    let content = fs::read_to_string("config.txt")?;
    Ok(content)
}

// &str = تستعير النص بدون ما تاخذ ملكيته (الأفضل لمعاملات الدوال)
fn print_len(s: &str) {
    println!("Length of '{}' = {}", s, s.len());
}

fn add_exclamation(s: &mut String) {
    s.push('!');
}

fn main() {
    // ╭──────────────────────────────────────────────────────────────╮
    // │  01  ▸  المتغيرات
    // ╰──────────────────────────────────────────────────────────────╯
    let age = 20; // ثابت
    let mut counter = 0; // mut = تقدر تغيره
    counter += 1;

    let price: f64 = 9.99;
    let is_active: bool = true;
    let letter: char = 'R';

    println!("age={}, counter={}, price={:.2}, active={}, letter={}",
        age, counter, price, is_active, letter);

    // ❌ age = 21;  خطأ! لأن age مو mut

    // ╭──────────────────────────────────────────────────────────────╮
    // │  02  ▸  الملكية والاستعارة
    // ╰──────────────────────────────────────────────────────────────╯
    let name = String::from("Ahmed");

    print_len(&name); // استعرناه بـ & فـ name لسا لنا
    println!("{} still usable", name);

    //   قبل:   name  ──►  "Ahmed"
    //
    //   بعد let moved = name;
    //          name  ──╳  (ما عاد يملك شيء)
    //          moved ──►  "Ahmed"
    //
    //   الاستعارة &name:
    //          name  ──►  "Ahmed"  ◄── &name  (يشوف بس، ما ياخذ)
    let moved = name; // الملكية انتقلت لـ moved
    // ❌ println!("{}", name); خطأ! name ما عاد يملك شيء
    println!("moved = {}", moved);

    // لو تبي نسخة مستقلة فعلًا استخدم clone
    let copy = moved.clone();
    println!("copy = {}, original = {}", copy, moved);

    // استعارة قابلة للتعديل &mut
    let mut text = String::from("Hello");
    add_exclamation(&mut text);
    println!("{}", text);

    // ⚠️ ما تقدر تسوي &mut مرتين بنفس الوقت، Rust تمنعها عشان تحميك

    // ╭──────────────────────────────────────────────────────────────╮
    // │  03  ▸  الشروط والتكرار
    // ╰──────────────────────────────────────────────────────────────╯
    if age >= 18 {
        println!("Adult");
    } else {
        println!("Minor");
    }

    // if ترجع قيمة
    let label = if age >= 18 { "adult" } else { "minor" };
    println!("label = {}", label);

    for i in 0..5 {
        print!("{} ", i); // 0 إلى 4
    }
    println!();

    let mut n = 3;
    while n > 0 {
        println!("n = {}", n);
        n -= 1;
    }

    // ╭──────────────────────────────────────────────────────────────╮
    // │  04  ▸  Vec (القائمة) و HashMap
    // ╰──────────────────────────────────────────────────────────────╯
    let mut numbers = vec![1, 2, 3];
    numbers.push(4);

    for num in &numbers {
        // & عشان ما ناخذ ملكية القائمة
        print!("{} ", num);
    }
    println!();

    // iterators: map و filter و collect
    let doubled: Vec<i32> = numbers.iter().map(|x| x * 2).collect();
    let evens: Vec<&i32> = numbers.iter().filter(|x| *x % 2 == 0).collect();
    let sum: i32 = numbers.iter().sum();
    println!("doubled={:?}, evens={:?}, sum={}", doubled, evens, sum);

    let mut scores: HashMap<&str, i32> = HashMap::new();
    scores.insert("Ali", 90);
    scores.insert("Sara", 95);

    // get ترجع Option لأن المفتاح ممكن ما يكون موجود
    match scores.get("Omar") {
        Some(score) => println!("Omar: {}", score),
        None => println!("Omar not found"),
    }

    // ╭──────────────────────────────────────────────────────────────╮
    // │  05  ▸  Option: بديل null في Rust
    // ╰──────────────────────────────────────────────────────────────╯
    // Option إما Some(قيمة) أو None. Rust تجبرك تتعامل مع الحالتين
    let maybe = numbers.get(10);
    if let Some(value) = maybe {
        println!("Found {}", value);
    } else {
        println!("Index 10 not found");
    }

    // unwrap_or: قيمة بديلة لو None
    let first = numbers.first().copied().unwrap_or(0);
    println!("first = {}", first);

    // ╭──────────────────────────────────────────────────────────────╮
    // │  06  ▸  Result والتعامل مع الأخطاء
    // ╰──────────────────────────────────────────────────────────────╯
    match divide(10.0, 2.0) {
        Ok(result) => println!("Result: {}", result),
        Err(e) => println!("Error: {}", e),
    }

    match divide(1.0, 0.0) {
        Ok(result) => println!("Result: {}", result),
        Err(e) => println!("Error: {}", e),
    }

    match read_config() {
        Ok(content) => println!("Config: {}", content),
        Err(e) => println!("Could not read config: {}", e),
    }

    // ⚠️ .unwrap() يطيح البرنامج (panic) لو فيه خطأ
    // تجنبه في الكود الحقيقي إلا لو متأكد 100% إن الخطأ مستحيل، وحتى وقتها الأفضل expect("السبب")
    // let x = divide(1.0, 0.0).unwrap(); // 💥

    // ╭──────────────────────────────────────────────────────────────╮
    // │  07  ▸  match مع enum
    // ╰──────────────────────────────────────────────────────────────╯
    let statuses = vec![
        Status::Active,
        Status::Banned("Spam".to_string()),
        Status::Suspended { days: 7 },
    ];

    for status in &statuses {
        // match لازم يغطي كل الحالات، وإلا المترجم يرفض
        match status {
            Status::Active => println!("Active"),
            Status::Banned(reason) => println!("Banned: {}", reason),
            Status::Suspended { days } => println!("Suspended for {} days", days),
        }
    }

    // ╭──────────────────────────────────────────────────────────────╮
    // │  08  ▸  struct و trait
    // ╰──────────────────────────────────────────────────────────────╯
    let mut user = User::new("Sara", 22);
    user.greet();
    user.birthday();
    println!("{:?}", user); // {:?} تطبع باستخدام Debug
    println!("{}", user.describe());

    println!("add(3, 4) = {}", add(3, 4));
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  ┃  ⚠️  ملخص الأغلاط اللي لازم ما تطيح فيها
//
//  1. تستخدم متغير بعد ما انتقلت ملكيته -> استعر بـ & أو clone لما تحتاج
//  2. تكثر من unwrap()                 -> استخدم match أو ? أو if let
//  3. تكثر من clone() عشان تسكت المترجم -> افهم الاستعارة بدل كذا
//  4. تنسى mut وتحاول تعدل
//  5. تخلط String مع &str              -> الدوال غالبًا تاخذ &str
//  6. تقاتل المترجم بدل ما تقرا رسالته -> غالبًا الحل مكتوب فيها
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
