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
// ║                          LEVEL 2  ·  INTERMEDIATE                          ║
// ║                              ▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰                              ║
// ╚════════════════════════════════════════════════════════════════════════════╝
//
//    ▌ JavaScript — دليل المتوسط
//
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  ◆ لمين هذا الملف؟
//  لك إذا تعرف المتغيرات والدوال و map/filter و fetch،
//  وتبي تفهم كيف JavaScript تشتغل من جوا وتكتب كود متين.
//
//  ◆ وش بتتعلم؟
//    Scope و Closures، Event Loop
//    Promises المتقدمة (all, allSettled, race)، AbortController
//    Modules، Map و Set، Debounce و Throttle
//    Errors مخصصة، Immutability، Getters و Static
//
//  ◆ كيف تشغله؟
//    node main.js     (Node 22 أو أحدث، لأنه يستخدم Object.groupBy و toSorted)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// ╭──────────────────────────────────────────────────────────────╮
// │  01  ▸  Scope و Closures
// ╰──────────────────────────────────────────────────────────────╯
//
//   ┌─ Global scope ────────────────────────────┐
//   │  createCounter                            │
//   │   ┌─ createCounter scope ──────────────┐  │
//   │   │  let count = 0     ◄───────┐       │  │
//   │   │   ┌─ increment scope ──┐   │       │  │
//   │   │   │  count++  ─────────┼───┘       │  │
//   │   │   └────────────────────┘           │  │
//   │   └────────────────────────────────────┘  │
//   └───────────────────────────────────────────┘
//
//  Closure = الدالة الداخلية "تتذكر" متغيرات الدالة اللي صنعتها
//  حتى بعد ما تخلص. فـ count خاص ومحد يقدر يعدله من برا.
function createCounter() {
  let count = 0;
  return {
    increment: () => ++count,
    reset: () => {
      count = 0;
    },
    get value() {
      return count;
    },
  };
}

const counter = createCounter();
counter.increment();
counter.increment();
console.log("counter:", counter.value); // 2

// ╭──────────────────────────────────────────────────────────────╮
// │  02  ▸  Event Loop: ليش هذا الترتيب؟
// ╰──────────────────────────────────────────────────────────────╯
//
//   ┌───────────────┐
//   │  Call Stack   │ ◄── الكود العادي يتنفذ هنا أول
//   └───────┬───────┘
//           │ لما يفضى
//           ▼
//   ┌───────────────────┐   أولوية عالية
//   │  Microtask Queue  │   Promise.then / await
//   └───────┬───────────┘
//           │ لما يفضى
//           ▼
//   ┌───────────────────┐   أولوية أقل
//   │  Task Queue       │   setTimeout / setInterval / events
//   └───────────────────┘
//
console.log("A: sync");
setTimeout(() => console.log("D: timeout"), 0);
Promise.resolve().then(() => console.log("C: promise"));
console.log("B: sync");
// الناتج: A, B, C, D

// ⚠️ لوب ثقيل متزامن يجمد الصفحة كاملة لأنه ماسك الـ Call Stack

// ╭──────────────────────────────────────────────────────────────╮
// │  03  ▸  Errors مخصصة
// ╰──────────────────────────────────────────────────────────────╯
class HttpError extends Error {
  constructor(status, message) {
    super(message);
    this.name = "HttpError";
    this.status = status;
  }
}

class ValidationError extends Error {
  constructor(field, message) {
    super(message);
    this.name = "ValidationError";
    this.field = field;
  }
}

// ╭──────────────────────────────────────────────────────────────╮
// │  04  ▸  fetch احترافي: timeout + إلغاء + أخطاء واضحة
// ╰──────────────────────────────────────────────────────────────╯
async function request(url, { timeoutMs = 5000, ...options } = {}) {
  // AbortSignal.timeout: يلغي الطلب لو طول
  const response = await fetch(url, {
    ...options,
    signal: options.signal ?? AbortSignal.timeout(timeoutMs),
    headers: { "Content-Type": "application/json", ...options.headers },
  });

  if (!response.ok) {
    throw new HttpError(response.status, `Request failed: ${response.status}`);
  }

  return response.status === 204 ? null : response.json();
}

// ╭──────────────────────────────────────────────────────────────╮
// │  05  ▸  Promises المتقدمة
// ╰──────────────────────────────────────────────────────────────╯
//
//   Promise.all         كلها لازم تنجح، لو وحدة فشلت الكل يفشل
//   Promise.allSettled  ينتظر الكل ويقولك مين نجح ومين فشل
//   Promise.race        أول وحدة تخلص (نجاح أو فشل)
//   Promise.any         أول وحدة تنجح
//
const wait = (ms, value, fail = false) =>
  new Promise((resolve, reject) => setTimeout(() => (fail ? reject(new Error(value)) : resolve(value)), ms));

async function promiseDemo() {
  const settled = await Promise.allSettled([wait(100, "users"), wait(50, "orders failed", true)]);
  for (const r of settled) {
    console.log(r.status === "fulfilled" ? `ok: ${r.value}` : `error: ${r.reason.message}`);
  }

  const fastest = await Promise.any([wait(200, "slow server"), wait(80, "fast server")]);
  console.log("fastest:", fastest);

  // ⚠️ await داخل for = واحد ورا الثاني (بطيء لو مستقلين)
  // ❌ for (const id of ids) await load(id);
  // ✅
  const ids = [1, 2, 3];
  const loaded = await Promise.all(ids.map((id) => wait(50, `item ${id}`)));
  console.log(loaded);

  // ⚠️ بس لو عندك 1000 طلب لا تطلقها كلها مرة وحدة، قسمها دفعات
  const batches = await inBatches(Array.from({ length: 7 }, (_, i) => i), 3, (n) => wait(20, n * 10));
  console.log("batches:", batches);
}

async function inBatches(items, size, worker) {
  const results = [];
  for (let i = 0; i < items.length; i += size) {
    const chunk = items.slice(i, i + size);
    results.push(...(await Promise.all(chunk.map(worker))));
  }
  return results;
}

// ╭──────────────────────────────────────────────────────────────╮
// │  06  ▸  Map و Set
// ╰──────────────────────────────────────────────────────────────╯
//   Object: المفاتيح نصوص (أو Symbol) بس
//   Map:    أي نوع مفتاح، يحفظ الترتيب، فيه size، أسرع للإضافة والحذف الكثير
//   Set:    قيم بدون تكرار
const cache = new Map();
cache.set("user:1", { name: "Ali" });
console.log(cache.has("user:1"), cache.size);

const uniqueTags = [...new Set(["js", "css", "js", "html"])];
console.log(uniqueTags);

// ╭──────────────────────────────────────────────────────────────╮
// │  07  ▸  تحويل البيانات: groupBy و Object.fromEntries
// ╰──────────────────────────────────────────────────────────────╯
const products = [
  { id: 1, name: "Laptop", category: "tech", price: 3500 },
  { id: 2, name: "Mouse", category: "tech", price: 75 },
  { id: 3, name: "Desk", category: "home", price: 900 },
];

const byCategory = Object.groupBy(products, (p) => p.category);
const byId = new Map(products.map((p) => [p.id, p])); // بحث O(1) بدل find كل مرة
const prices = Object.fromEntries(products.map((p) => [p.name, p.price]));

console.log(Object.keys(byCategory), byId.get(3).name, prices);

// ╭──────────────────────────────────────────────────────────────╮
// │  08  ▸  Immutability: لا تعدل الأصل
// ╰──────────────────────────────────────────────────────────────╯
//
//   ❌ state.items.push(x)        نفس المرجع ← React ما يدري إنه تغير
//   ✅ { ...state, items: [...state.items, x] }   مرجع جديد
//
const state = { user: { name: "Sara" }, items: [1, 2] };
const next = {
  ...state,
  user: { ...state.user, name: "Noor" },
  items: [...state.items, 3],
};
console.log(state.user.name, next.user.name, state.items.length, next.items.length);

// دوال حديثة ترجع نسخة بدل ما تعدل الأصل
const nums = [3, 1, 2];
const sorted = nums.toSorted((a, b) => a - b);
const withoutFirst = nums.toSpliced(0, 1);
console.log(nums, sorted, withoutFirst);

// Object.freeze: يمنع التعديل (سطحي بس)
const CONFIG = Object.freeze({ apiUrl: "https://api.example.com", retries: 3 });

// ╭──────────────────────────────────────────────────────────────╮
// │  09  ▸  Debounce و Throttle
// ╰──────────────────────────────────────────────────────────────╯
//
//   الأحداث:     | | | | |       | | |
//   debounce:              ▲            ▲    ينفذ بعد ما يوقف المستخدم
//   throttle:    ▲     ▲         ▲             أول حدث، وبعدها مرة كل فترة بالكثير (بس لو فيه أحداث)
//
//  debounce: البحث وأنت تكتب (لا تطلب API مع كل حرف)
//  throttle: الـ scroll و resize
function debounce(fn, delay) {
  let timer;
  return (...args) => {
    clearTimeout(timer);
    timer = setTimeout(() => fn(...args), delay);
  };
}

function throttle(fn, interval) {
  let last = 0;
  return (...args) => {
    const now = Date.now();
    if (now - last >= interval) {
      last = now;
      fn(...args);
    }
  };
}

const search = debounce((q) => console.log("searching:", q), 100);
search("j");
search("ja");
search("jav"); // هذي بس اللي تتنفذ

// ╭──────────────────────────────────────────────────────────────╮
// │  10  ▸  Classes: static و getters و private
// ╰──────────────────────────────────────────────────────────────╯
class Cart {
  static TAX = 0.15;
  #items = [];

  add(product, qty = 1) {
    if (!Number.isInteger(qty) || qty <= 0) {
      throw new ValidationError("qty", "Quantity must be a positive integer");
    }
    this.#items.push({ ...product, qty });
    return this; // يسمح بالتسلسل cart.add().add()
  }

  get subtotal() {
    return this.#items.reduce((sum, i) => sum + i.price * i.qty, 0);
  }

  get total() {
    return Math.round(this.subtotal * (1 + Cart.TAX) * 100) / 100;
  }
}

const cart = new Cart().add(products[0]).add(products[1], 2);
console.log("cart total:", cart.total);

try {
  cart.add(products[2], -1);
} catch (e) {
  if (e instanceof ValidationError) console.log(`${e.field}: ${e.message}`);
  else throw e; // ⚠️ أخطاء ما تعرفها رجّعها، لا تبلعها
}

// ╭──────────────────────────────────────────────────────────────╮
// │  11  ▸  Modules (في مشروع حقيقي)
// ╰──────────────────────────────────────────────────────────────╯
//
//   src/
//   ├── api.js       export async function request(url) { ... }
//   ├── cart.js      export default class Cart { ... }
//   └── main.js      import Cart from "./cart.js";
//                    import { request } from "./api.js";
//
//   package.json:  { "type": "module" }
//
//  ⚠️ في المتصفح: <script type="module" src="main.js"></script>

// ╭──────────────────────────────────────────────────────────────╮
// │  12  ▸  Optional chaining مع الدوال و nullish assignment
// ╰──────────────────────────────────────────────────────────────╯
const settings = { theme: null, onSave: undefined };
settings.theme ??= "dark"; // عيّن بس لو null أو undefined
settings.onSave?.(); // نفّذ لو موجودة
console.log(settings.theme, CONFIG.retries);

promiseDemo().catch((e) => console.error("Unexpected:", e));

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  ┃  ⚠️  أغلاط المستوى المتوسط
//
//  1. await داخل for لطلبات مستقلة         -> Promise.all
//  2. Promise.all على آلاف الطلبات          -> دفعات (batches)
//  3. fetch بدون timeout                     -> AbortSignal.timeout
//  4. تعدل state مباشرة                     -> نسخة جديدة (spread)
//  5. find داخل لوب على قائمة كبيرة         -> Map للبحث السريع
//  6. API مع كل ضغطة زر                     -> debounce
//  7. catch يبلع كل الأخطاء                  -> تعامل مع اللي تعرفه، ورجّع الباقي
//  8. Promise بدون catch                    -> Unhandled Rejection يطيح Node
//  9. لوب ثقيل في المتصفح                    -> يجمد الصفحة، استخدم Web Worker
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
