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
// ║                          LEVEL 2  ·  INTERMEDIATE                          ║
// ║                              ▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰                              ║
// ╚════════════════════════════════════════════════════════════════════════════╝
//
//    ▌ Rust — دليل المتوسط
//
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  ◆ لمين هذا الملف؟
//  لك إذا فهمت Ownership و Borrowing و match و Result،
//  وتبي تكتب كود Rust مرتب ينفع في مشاريع حقيقية.
//
//  ◆ وش بتتعلم؟
//    Traits و Generics، Lifetimes
//    أخطاء مخصصة مع From و ?
//    Iterators المتقدمة، Closures
//    Box و Rc و RefCell، Threads مع Arc و Mutex، Modules
//
//  ◆ كيف تشغله؟
//    cargo new intermediate
//    انسخ الملف مكان src/main.rs ثم: cargo run
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

use std::collections::HashMap;
use std::fmt;
use std::rc::Rc;
use std::cell::RefCell;
use std::sync::{Arc, Mutex};
use std::thread;

// ╭──────────────────────────────────────────────────────────────╮
// │  01  ▸  Traits و Generics
// ╰──────────────────────────────────────────────────────────────╯
//
//              ┌─────────────────────┐
//              │   trait Shape       │
//              │   fn area() -> f64  │
//              └─────────┬───────────┘
//                ┌───────┴───────┐
//                ▼               ▼
//          ┌──────────┐    ┌──────────┐
//          │  Circle  │    │   Rect   │
//          └──────────┘    └──────────┘
//
trait Shape {
    fn area(&self) -> f64;

    // دالة افتراضية: كل الأنواع تاخذها مجانًا
    fn describe(&self) -> String {
        format!("shape with area {:.2}", self.area())
    }
}

struct Circle {
    radius: f64,
}

struct Rect {
    width: f64,
    height: f64,
}

impl Shape for Circle {
    fn area(&self) -> f64 {
        std::f64::consts::PI * self.radius * self.radius
    }
}

impl Shape for Rect {
    fn area(&self) -> f64 {
        self.width * self.height
    }
}

// Generic مع Trait Bound: أي نوع يطبق Shape
// Rust تولّد نسخة لكل نوع وقت الترجمة = سريع جدًا (Static Dispatch)
fn print_area<T: Shape>(shape: &T) {
    println!("{}", shape.describe());
}

// dyn Shape: أنواع مختلفة في نفس القائمة (Dynamic Dispatch)
fn total_area(shapes: &[Box<dyn Shape>]) -> f64 {
    shapes.iter().map(|s| s.area()).sum()
}

// ╭──────────────────────────────────────────────────────────────╮
// │  02  ▸  Display: تحدد كيف ينطبع نوعك بـ {}
// ╰──────────────────────────────────────────────────────────────╯
#[derive(Debug, Clone, PartialEq)]
struct Money {
    halalas: i64, // ⚠️ الفلوس بأعداد صحيحة، مو f64
}

impl fmt::Display for Money {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "{}.{:02} SAR", self.halalas / 100, self.halalas % 100)
    }
}

// ╭──────────────────────────────────────────────────────────────╮
// │  03  ▸  أخطاء مخصصة + From + ?
// ╰──────────────────────────────────────────────────────────────╯
//
//   parse_age("abc")
//        │
//        ▼  ParseIntError
//   ?  ──── From ────►  AppError::InvalidNumber
//        │
//        ▼
//   يرجع للي استدعى الدالة
//
#[derive(Debug)]
enum AppError {
    InvalidNumber(std::num::ParseIntError),
    OutOfRange(i64),
}

impl fmt::Display for AppError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            AppError::InvalidNumber(e) => write!(f, "invalid number: {}", e),
            AppError::OutOfRange(n) => write!(f, "{} is out of range", n),
        }
    }
}

impl std::error::Error for AppError {}

// From: يخلي ? يحول الخطأ تلقائي
impl From<std::num::ParseIntError> for AppError {
    fn from(e: std::num::ParseIntError) -> Self {
        AppError::InvalidNumber(e)
    }
}

fn parse_age(input: &str) -> Result<u8, AppError> {
    let n: i64 = input.trim().parse()?;
    if !(1..=120).contains(&n) {
        return Err(AppError::OutOfRange(n));
    }
    Ok(n as u8)
}

// ╭──────────────────────────────────────────────────────────────╮
// │  04  ▸  Lifetimes: كم يعيش المرجع؟
// ╰──────────────────────────────────────────────────────────────╯
//  'a تقول: "المرجع اللي أرجعه يعيش قد أقصر واحد من المدخلات"
//
//    let a = String::from("long");      ──────────────┐ a عايش
//    let r;                                           │
//    {                                                │
//        let b = String::from("hi");    ───┐ b عايش   │
//        r = longest(&a, &b);              │          │
//    }                                  ───┘          │
//    println!("{}", r); ❌ المترجم يرفض: r ممكن يأشر على b، و b مات
//                                       ──────────────┘
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
    if x.len() >= y.len() { x } else { y }
}

// struct فيه مرجع لازم يحدد الـ lifetime
struct Highlight<'a> {
    text: &'a str,
}

// ╭──────────────────────────────────────────────────────────────╮
// │  05  ▸  Modules: تنظيم الكود
// ╰──────────────────────────────────────────────────────────────╯
//  في مشروع حقيقي كل module في ملف:
//    src/
//    ├── main.rs        mod bank;
//    └── bank.rs        pub struct Account ...
mod bank {
    #[derive(Debug)]
    pub struct Account {
        pub owner: String,
        balance: i64, // private: ما ينوصل له من برا الـ module
    }

    impl Account {
        pub fn new(owner: &str) -> Self {
            Account { owner: owner.to_string(), balance: 0 }
        }

        pub fn deposit(&mut self, amount: i64) -> Result<(), String> {
            if amount <= 0 {
                return Err("amount must be positive".into());
            }
            self.balance += amount;
            Ok(())
        }

        pub fn balance(&self) -> i64 {
            self.balance
        }
    }
}

// ╭──────────────────────────────────────────────────────────────╮
// │  06  ▸  Rc و RefCell: أكثر من مالك + تعديل
// ╰──────────────────────────────────────────────────────────────╯
//
//   Box<T>          مالك واحد، البيانات على الـ Heap
//   Rc<T>           أكثر من مالك (Thread واحد بس)، قراءة بس
//   RefCell<T>      تعديل داخلي، الفحص وقت التشغيل
//   Arc<T>          زي Rc بس آمن بين الـ Threads
//   Mutex<T>        تعديل آمن بين الـ Threads
//
//      shared ──┐
//      team_a ──┼──► Rc<RefCell<Vec>>  ──► ["Ali", "Sara"]
//      team_b ──┘      count = 3
//
#[derive(Debug)]
struct Task {
    title: String,
    done: bool,
}

fn main() {
    // Traits
    let c = Circle { radius: 2.0 };
    print_area(&c);

    let shapes: Vec<Box<dyn Shape>> = vec![
        Box::new(Circle { radius: 1.0 }),
        Box::new(Rect { width: 2.0, height: 3.0 }),
    ];
    println!("total area = {:.2}", total_area(&shapes));

    let price = Money { halalas: 1999 };
    println!("price = {}", price);

    // Errors
    for input in ["25", "abc", "500"] {
        match parse_age(input) {
            Ok(age) => println!("age = {}", age),
            Err(e) => println!("error: {}", e),
        }
    }

    // Lifetimes
    let a = String::from("programming");
    let result;
    {
        let b = String::from("rust");
        result = longest(&a, &b).to_string(); // ننسخها عشان تعيش بعد b
    }
    println!("longest = {}", result);

    let h = Highlight { text: &a[0..7] };
    println!("highlight = {}", h.text);

    // Modules
    let mut acc = bank::Account::new("Noor");
    if let Err(e) = acc.deposit(-5) {
        println!("deposit failed: {}", e);
    }
    acc.deposit(500).expect("valid deposit");
    println!("{} has {}", acc.owner, acc.balance());

    // ╭──────────────────────────────────────────────────────────────╮
    // │  07  ▸  Iterators و Closures المتقدمة
    // ╰──────────────────────────────────────────────────────────────╯
    let tasks = vec![
        Task { title: "Write code".into(), done: true },
        Task { title: "Test code".into(), done: false },
        Task { title: "Deploy".into(), done: false },
    ];

    let pending: Vec<&str> = tasks
        .iter()
        .filter(|t| !t.done)
        .map(|t| t.title.as_str())
        .collect();
    println!("pending = {:?}", pending);

    let (done, not_done): (Vec<&Task>, Vec<&Task>) = tasks.iter().partition(|t| t.done);
    println!("done={} not_done={}", done.len(), not_done.len());

    // enumerate + find_map + zip
    let first_pending = tasks.iter().enumerate().find_map(|(i, t)| (!t.done).then_some(i));
    println!("first pending index = {:?}", first_pending);

    let scores = [90, 75, 60];
    let names = ["Ali", "Sara", "Omar"];
    let table: HashMap<_, _> = names.iter().zip(scores.iter()).collect();
    println!("{:?}", table.get(&"Sara"));

    // Entry API: أضف أو حدّث بسطر واحد
    let text = "the cat and the dog and the bird";
    let mut counts: HashMap<&str, usize> = HashMap::new();
    for word in text.split_whitespace() {
        *counts.entry(word).or_insert(0) += 1;
    }
    println!("'the' appears {} times", counts["the"]);

    // Closure تمسك متغير (move ياخذ ملكيته)
    let multiplier = 3;
    let times = move |x: i32| x * multiplier;
    println!("times(5) = {}", times(5));

    // Rc + RefCell
    let shared = Rc::new(RefCell::new(vec!["Ali".to_string()]));
    let team_a = Rc::clone(&shared);
    let team_b = Rc::clone(&shared);
    team_a.borrow_mut().push("Sara".to_string());
    println!("team_b sees {:?}, owners = {}", team_b.borrow(), Rc::strong_count(&shared));
    // ⚠️ borrow_mut مرتين بنفس الوقت = panic وقت التشغيل

    // ╭──────────────────────────────────────────────────────────────╮
    // │  08  ▸  Threads مع Arc و Mutex
    // ╰──────────────────────────────────────────────────────────────╯
    let counter = Arc::new(Mutex::new(0));
    let mut handles = Vec::new();

    for _ in 0..4 {
        let counter = Arc::clone(&counter);
        handles.push(thread::spawn(move || {
            for _ in 0..1000 {
                // lock يرجع Guard، والقفل يتفك تلقائي لما يطلع من النطاق
                *counter.lock().unwrap() += 1;
            }
        }));
    }

    for h in handles {
        h.join().unwrap();
    }
    println!("counter = {}", *counter.lock().unwrap());
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  ┃  ⚠️  أغلاط المستوى المتوسط
//
//  1. Box<dyn Error> في كل مكان           -> enum أخطاء واضح في المكتبات
//  2. unwrap في كود الإنتاج               -> ? و Result
//  3. تحط lifetimes عشوائي               -> غالبًا الحل ترجع String مملوكة
//  4. Rc بين Threads                     -> المترجم يرفض، استخدم Arc
//  5. RefCell وتسوي borrow_mut مرتين     -> panic
//  6. تمسك Mutex lock وقت طويل          -> بطء أو Deadlock
//  7. collect() بدون ما تحدد النوع
//  8. f64 للفلوس                          -> أعداد صحيحة (هللات)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
