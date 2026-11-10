// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
// ╔════════════════════════════════════════════════════════════════════════════╗
// ║                                                                            ║
// ║           ███  ███  █   █  ███   ████  ████ ████  ███ ████  █████          ║
// ║             █ █   █ █   █ █   █ █     █     █   █  █  █   █   █            ║
// ║             █ █████ █   █ █████  ███  █     ████   █  ████    █            ║
// ║         █   █ █   █  █ █  █   █     █ █     █  █   █  █       █            ║
// ║          ███  █   █   █   █   █ ████   ████ █   █ ███ █       █            ║
// ║                                                                            ║
// ║                             LEVEL 1  ·  BASICS                             ║
// ║                              ▰▰▰▰▰▰▰▰▱▱▱▱▱▱▱▱                              ║
// ╚════════════════════════════════════════════════════════════════════════════╝
//
//    ▌ JavaScript — دليل المبتدئ
//
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  ◆ وش هي؟
//  لغة الويب. تشتغل في:
//    - المتصفح: تخلي الصفحة تتفاعل (أزرار، نوافذ، بيانات)
//    - السيرفر: عن طريق Node.js
//  وتستخدم مع: React, Vue, Next.js, Express ...
//
//  ◆ كيف تشغل الملف؟
//    node main.js
//    (أجزاء الـ DOM تحت تشتغل بس في المتصفح، شوف مجلد html)
//
//  ◆ أهم شيء تعرفه:
//    - انسى var، استخدم const و let
//    - استخدم === دايمًا مو ==
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// ╭──────────────────────────────────────────────────────────────╮
// │  01  ▸  المتغيرات
// ╰──────────────────────────────────────────────────────────────╯
const name = "Ahmed"; // const: ما تقدر تعيد تعيينه (استخدمها دايمًا كبداية)
let age = 20;         // let: لو بتغير القيمة بعدين
age = 21;

// ❌ var: قديمة وتسبب مشاكل غريبة في النطاق، لا تستخدمها

const price = 9.99;
const isActive = true;
const nothing = null;     // فاضي بقصد
let notSet;               // undefined: ما عطيته قيمة

// Template literal: علامة ` تخليك تحط متغيرات بـ ${}
console.log(`Hello ${name}, you are ${age} years old`);

// ╭──────────────────────────────────────────────────────────────╮
// │  02  ▸  المقارنة ⚠️ مهم جدًا
// ╰──────────────────────────────────────────────────────────────╯
console.log("5" == 5);   // true  ❌ == تحول الأنواع وتطلع نتايج غريبة
console.log("5" === 5);  // false ✅ === تقارن القيمة والنوع
console.log(0 == "");    // true  ❌ شفت؟
console.log(null == undefined); // true

// القيم اللي تعتبر false في الشروط (falsy):
// false, 0, -0, 0n, "", null, undefined, NaN
// ⚠️ انتبه: لو عندك رقم ممكن يكون 0 لا تسوي if (count)

// ╭──────────────────────────────────────────────────────────────╮
// │  03  ▸  الشروط
// ╰──────────────────────────────────────────────────────────────╯
if (age >= 18) {
  console.log("Adult");
} else if (age >= 13) {
  console.log("Teen");
} else {
  console.log("Child");
}

const label = age >= 18 ? "adult" : "minor"; // شرط بسطر واحد

// ╭──────────────────────────────────────────────────────────────╮
// │  04  ▸  التكرار
// ╰──────────────────────────────────────────────────────────────╯
for (let i = 0; i < 5; i++) {
  console.log(i);
}

// ╭──────────────────────────────────────────────────────────────╮
// │  05  ▸  المصفوفات (Arrays) - بتستخدم هذي الدوال كل يوم
// ╰──────────────────────────────────────────────────────────────╯
const names = ["Ali", "Sara", "Omar"];
names.push("Noor"); // أضف بالآخر

// for...of: تلف على العناصر
for (const n of names) {
  console.log(n);
}

const upper = names.map((n) => n.toUpperCase());          // حوّل كل عنصر
const longNames = names.filter((n) => n.length > 3);      // فلتر
const firstS = names.find((n) => n.startsWith("S"));      // أول واحد يطابق
const hasAli = names.includes("Ali");                     // موجود؟
const total = [1, 2, 3].reduce((sum, x) => sum + x, 0);   // اجمع

console.log(upper, longNames, firstS, hasAli, total);

// ⚠️ sort بدون دالة يرتب الأرقام كنصوص!
console.log([10, 2, 1].sort());                 // [1, 10, 2] ❌
console.log([10, 2, 1].sort((a, b) => a - b));  // [1, 2, 10] ✅

// ╭──────────────────────────────────────────────────────────────╮
// │  06  ▸  الكائنات (Objects)
// ╰──────────────────────────────────────────────────────────────╯
const user = {
  name: "Sara",
  age: 22,
  address: { city: "Jeddah" },
};

console.log(user.name);

// Destructuring: تطلع القيم في متغيرات
const { name: userName, age: userAge } = user;

// Spread: نسخة جديدة سطحية مع تعديل (مهم جدًا في React)
// ⚠️ سطحية يعني user.address لسا مشترك بين النسختين
const updatedUser = { ...user, age: 23 };

// ?. يمنع الخطأ لو شيء مو موجود
// ?? يعطي قيمة بديلة لو null أو undefined
console.log(user?.profile?.photo ?? "No photo");

// ⚠️ const ما تمنع تعديل محتوى الكائن، تمنع بس إعادة التعيين
user.age = 30;      // مسموح
// user = {};       // ❌ ممنوع

// ⚠️ النسخ: b = a ما ينسخ! الاثنين نفس الكائن
//
//   original ──┐
//              ├──►  { count: 99 }     نفس الكائن (بعد sameRef.count = 99)
//   sameRef  ──┘
//
//   realCopy ─────►  { count: 99 }     كائن جديد مستقل، لو عدلت عليه original ما يتأثر
//
const original = { count: 1 };
const sameRef = original;
sameRef.count = 99;
console.log(original.count); // 99 !
const realCopy = structuredClone(original); // ✅ نسخة عميقة

// ╭──────────────────────────────────────────────────────────────╮
// │  07  ▸  الدوال
// ╰──────────────────────────────────────────────────────────────╯
function add(a, b = 0) {
  return a + b;
}

// Arrow function: الشكل المختصر
const multiply = (a, b) => a * b;

// Rest: تاخذ عدد مفتوح من المعاملات
const sumAll = (...nums) => nums.reduce((s, x) => s + x, 0);

console.log(add(3, 4), multiply(2, 5), sumAll(1, 2, 3));

// ╭──────────────────────────────────────────────────────────────╮
// │  08  ▸  الأرقام ⚠️
// ╰──────────────────────────────────────────────────────────────╯
console.log(0.1 + 0.2); // 0.30000000000000004 !
// للفلوس: احسب بالهللات (أعداد صحيحة) وبعدين اقسم على 100
const priceInHalalas = 999;
console.log((priceInHalalas / 100).toFixed(2));

console.log(Number("42"));      // 42
console.log(Number("abc"));     // NaN = مو رقم
console.log(Number.isNaN(Number("abc"))); // true

// ╭──────────────────────────────────────────────────────────────╮
// │  09  ▸  async / await: للعمليات اللي تاخذ وقت (طلبات API)
// ╰──────────────────────────────────────────────────────────────╯
async function getUsers() {
  try {
    const response = await fetch("https://jsonplaceholder.typicode.com/users");

    // ⚠️ fetch ما يرمي خطأ لو السيرفر رجع 404 أو 500، لازم تشيك بنفسك
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }

    const data = await response.json();
    return data;
  } catch (error) {
    console.error("Failed to load users:", error.message);
    return [];
  }
}

// ⚠️ لو نسيت await بتاخذ Promise بدل البيانات
// ❌ const users = getUsers();   -> Promise { <pending> }
// ✅ const users = await getUsers();   (داخل async function أو في ES module)

// تشغيل أكثر من طلب بنفس الوقت بدل واحد ورا الثاني
async function loadAll() {
  const [users, posts] = await Promise.all([
    getUsers(),
    fetch("https://jsonplaceholder.typicode.com/posts").then((r) => r.json()),
  ]);
  console.log(users.length, posts.length);
}

// ╭──────────────────────────────────────────────────────────────╮
// │  10  ▸  الكلاسات
// ╰──────────────────────────────────────────────────────────────╯
class Car {
  #secret = "hidden"; // # = خاصية private

  constructor(model, year) {
    this.model = model;
    this.year = year;
  }

  drive() {
    console.log(`${this.model} is driving`);
  }
}

class ElectricCar extends Car {
  constructor(model, year, battery) {
    super(model, year); // لازم قبل ما تستخدم this
    this.battery = battery;
  }

  drive() {
    console.log(`${this.model} is driving silently (${this.battery}%)`);
  }
}

new Car("Camry", 2024).drive();
new ElectricCar("Model 3", 2025, 80).drive();

// ╭──────────────────────────────────────────────────────────────╮
// │  11  ▸  JSON
// ╰──────────────────────────────────────────────────────────────╯
const json = JSON.stringify({ a: 1, b: [1, 2] }); // كائن -> نص
const parsed = JSON.parse(json);                  // نص -> كائن

// ⚠️ JSON.parse يرمي خطأ لو النص خربان
try {
  JSON.parse("{bad json}");
} catch {
  console.log("Invalid JSON");
}

// ╭──────────────────────────────────────────────────────────────╮
// │  12  ▸  الـ DOM (في المتصفح بس)
// ╰──────────────────────────────────────────────────────────────╯
if (typeof document !== "undefined") {
  const button = document.querySelector("#myButton");
  const output = document.querySelector("#output");

  button?.addEventListener("click", () => {
    const userInput = "<img src=x onerror=alert(1)>";

    // ❌ خطر! innerHTML مع بيانات من المستخدم = ثغرة XSS
    // output.innerHTML = userInput;

    // ✅ textContent يعرضه كنص عادي وآمن
    output.textContent = userInput;
  });
}

loadAll().catch((error) => console.error("Failed to load:", error.message));

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  ┃  ⚠️  ملخص الأغلاط اللي لازم ما تطيح فيها
//
//  1. var                               -> const و let
//  2. ==                                -> ===
//  3. تنسى await                        -> تاخذ Promise بدل البيانات
//  4. fetch بدون response.ok
//  5. innerHTML مع بيانات المستخدم      -> textContent (ثغرة XSS)
//  6. حسابات الفلوس بأرقام عشرية        -> احسب بالهللات
//  7. sort للأرقام بدون دالة مقارنة
//  8. b = a تحسبها نسخة                 -> {...a} (سطحية) أو structuredClone (عميقة)
//  9. تحط API Keys وأسرار في كود الواجهة -> أي أحد يشوفها
//  10. تثق في التحقق اللي بالواجهة بس   -> السيرفر لازم يتحقق
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
