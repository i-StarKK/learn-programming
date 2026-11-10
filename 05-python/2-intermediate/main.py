# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                                                            ║
# ║                    ████  █   █ █████ █   █  ███  █   █                     ║
# ║                    █   █  █ █    █   █   █ █   █ ██  █                     ║
# ║                    ████    █     █   █████ █   █ █ █ █                     ║
# ║                    █       █     █   █   █ █   █ █  ██                     ║
# ║                    █       █     █   █   █  ███  █   █                     ║
# ║                                                                            ║
# ║                          LEVEL 2  ·  INTERMEDIATE                          ║
# ║                              ▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰                              ║
# ╚════════════════════════════════════════════════════════════════════════════╝
#
#    ▌ Python — دليل المتوسط
#
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  ◆ لمين هذا الملف؟
#  لك إذا تعرف القوائم والدوال والكلاسات، وتبي تكتب كود
#  Python احترافي ونظيف زي اللي في المشاريع الحقيقية.
#
#  ◆ وش بتتعلم؟
#    Type Hints، Generators، Decorators، Context Managers
#    collections (Counter, defaultdict, deque)، Enum
#    Exceptions مخصصة، logging، asyncio
#    Properties و dataclasses المتقدمة
#
#  ◆ كيف تشغله؟
#    python main.py
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

from __future__ import annotations

import asyncio
import functools
import logging
import time
from collections import Counter, defaultdict, deque
from contextlib import contextmanager
from dataclasses import dataclass, field
from enum import Enum
from typing import Callable, Iterator

# ╭──────────────────────────────────────────────────────────────╮
# │  01  ▸  logging: بدال print في البرامج الحقيقية
# ╰──────────────────────────────────────────────────────────────╯
#  DEBUG < INFO < WARNING < ERROR < CRITICAL
#  تقدر تطفي الرسائل الصغيرة في الإنتاج بدون ما تحذفها من الكود
logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")
log = logging.getLogger(__name__)


# ╭──────────────────────────────────────────────────────────────╮
# │  02  ▸  Enum: قيم محددة بدل نصوص عشوائية
# ╰──────────────────────────────────────────────────────────────╯
#  ❌ status = "actve"   غلطة إملائية وما أحد بينتبه
#  ✅ status = Status.ACTIVE   المحرر يكملها لك ويكشف الغلط
class Status(Enum):
    ACTIVE = "active"
    BANNED = "banned"
    PENDING = "pending"


# ╭──────────────────────────────────────────────────────────────╮
# │  03  ▸  Exceptions مخصصة
# ╰──────────────────────────────────────────────────────────────╯
class AppError(Exception):
    """الأب لكل أخطاء التطبيق"""


class InsufficientBalanceError(AppError):
    def __init__(self, missing: float):
        super().__init__(f"Missing {missing:.2f} SAR")
        self.missing = missing


# ╭──────────────────────────────────────────────────────────────╮
# │  04  ▸  dataclass المتقدم و property
# ╰──────────────────────────────────────────────────────────────╯
@dataclass
class Account:
    owner: str
    _balance: float = 0.0
    status: Status = Status.ACTIVE
    # ⚠️ لا تكتب history: list = []  الـ dataclass يرفضها ويطلع ValueError
    #    عشان يحميك من مشكلة القيمة الافتراضية المتغيرة، فاستخدم default_factory
    history: list[str] = field(default_factory=list)

    # property: تقرأها كأنها متغير، بس وراها دالة تتحكم فيها
    @property
    def balance(self) -> float:
        return self._balance

    def deposit(self, amount: float) -> None:
        if amount <= 0:
            raise ValueError("Amount must be positive")
        self._balance += amount
        self.history.append(f"+{amount}")

    def withdraw(self, amount: float) -> None:
        if amount > self._balance:
            raise InsufficientBalanceError(amount - self._balance)
        self._balance -= amount
        self.history.append(f"-{amount}")


# frozen=True: ما تتعدل بعد ما تنصنع (آمنة وتنفع كمفتاح في dict)
@dataclass(frozen=True)
class Point:
    x: int
    y: int


# ╭──────────────────────────────────────────────────────────────╮
# │  05  ▸  Decorators: تلف دالة بدالة ثانية
# ╰──────────────────────────────────────────────────────────────╯
#
#   @timer
#   def work(): ...
#
#   كأنك كتبت:  work = timer(work)
#
#   ┌─────────── wrapper ───────────┐
#   │  start = time()               │
#   │  ┌───── work() الأصلية ────┐  │
#   │  │                          │  │
#   │  └──────────────────────────┘  │
#   │  print(time() - start)        │
#   └───────────────────────────────┘
#
def timer(func: Callable) -> Callable:
    @functools.wraps(func)  # ⚠️ يحافظ على اسم الدالة الأصلية ووصفها
    def wrapper(*args, **kwargs):
        start = time.perf_counter()
        result = func(*args, **kwargs)
        log.info("%s took %.3fs", func.__name__, time.perf_counter() - start)
        return result

    return wrapper


# Decorator ياخذ معاملات = ثلاث طبقات
def retry(times: int = 3):
    def decorator(func: Callable) -> Callable:
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            for attempt in range(1, times + 1):
                try:
                    return func(*args, **kwargs)
                except ConnectionError as e:
                    log.warning("Attempt %d failed: %s", attempt, e)
            raise ConnectionError(f"Failed after {times} attempts")

        return wrapper

    return decorator


attempts = {"count": 0}


@retry(times=3)
def unstable_request() -> str:
    attempts["count"] += 1
    if attempts["count"] < 3:
        raise ConnectionError("server busy")
    return "success"


# functools.cache: يحفظ النتايج ولا يعيد الحساب
@functools.cache
def fibonacci(n: int) -> int:
    return n if n < 2 else fibonacci(n - 1) + fibonacci(n - 2)


# ╭──────────────────────────────────────────────────────────────╮
# │  06  ▸  Generators: تطلع القيم وحدة وحدة بدل ما تحملها كلها
# ╰──────────────────────────────────────────────────────────────╯
#
#   list:      [■ ■ ■ ■ ■ ■ ■ ■ ■ ■]  كلها في الذاكرة مرة وحدة
#   generator:  ■ → ■ → ■ → ...        وحدة بس بكل مرة
#
#  مثالي للملفات الكبيرة والبيانات اللي ما تنتهي
def read_in_chunks(items: list[int], size: int) -> Iterator[list[int]]:
    for i in range(0, len(items), size):
        yield items[i : i + size]


def countdown(n: int) -> Iterator[int]:
    while n > 0:
        yield n
        n -= 1


# ╭──────────────────────────────────────────────────────────────╮
# │  07  ▸  Context Managers: "سو شيء قبل، وشيء بعد، مهما صار"
# ╰──────────────────────────────────────────────────────────────╯
@contextmanager
def timed_block(name: str):
    start = time.perf_counter()
    try:
        yield
    finally:  # ⚠️ finally يضمن التنفيذ حتى لو صار خطأ
        log.info("Block '%s' finished in %.3fs", name, time.perf_counter() - start)


# ╭──────────────────────────────────────────────────────────────╮
# │  08  ▸  asyncio: عمليات كثيرة تنتظر (نت، ملفات) بنفس الوقت
# ╰──────────────────────────────────────────────────────────────╯
#
#   متتالي:   [─A─][─B─][─C─]   = 3 ثواني
#   gather:   [─A─]
#             [─B─]             = ثانية وحدة
#             [─C─]
#
async def fetch(name: str, delay: float) -> str:
    await asyncio.sleep(delay)  # ⚠️ time.sleep هنا يوقف كل شيء! استخدم asyncio.sleep
    return f"{name} done"


async def main_async() -> None:
    results = await asyncio.gather(fetch("users", 0.3), fetch("orders", 0.3), fetch("posts", 0.3))
    log.info("gather results: %s", results)

    try:
        await asyncio.wait_for(fetch("slow", 5), timeout=0.2)
    except asyncio.TimeoutError:
        log.warning("slow request timed out")


@timer
def main() -> None:
    # collections
    words = "the cat and the dog and the bird".split()
    counts = Counter(words)
    print("most common:", counts.most_common(2))

    by_letter: defaultdict[str, list[str]] = defaultdict(list)  # ما يطيح لو المفتاح جديد
    for w in words:
        by_letter[w[0]].append(w)
    print("grouped:", dict(by_letter))

    recent = deque(maxlen=3)  # يحتفظ بآخر 3 بس
    for i in range(10):
        recent.append(i)
    print("recent:", list(recent))

    # dataclass + exceptions
    acc = Account("Sara")
    acc.deposit(100)
    try:
        acc.withdraw(250)
    except InsufficientBalanceError as e:
        log.error("Withdraw failed: %s (missing %.2f)", e, e.missing)
    print("balance:", acc.balance, "status:", acc.status.value)

    locations = {Point(0, 0): "home", Point(5, 3): "work"}
    print(locations[Point(5, 3)])

    # generators
    for chunk in read_in_chunks(list(range(10)), 4):
        print("chunk:", chunk)
    print("countdown:", list(countdown(3)))

    total = sum(x * x for x in range(1_000_000))  # generator expression بدون أقواس []
    print("sum of squares:", total)

    # decorators
    print("retry:", unstable_request())
    print("fib(80):", fibonacci(80))

    # comprehensions متقدمة
    matrix = [[1, 2, 3], [4, 5, 6]]
    flat = [n for row in matrix for n in row]
    transposed = [list(col) for col in zip(*matrix)]
    inverted = {v: k for k, v in {"a": 1, "b": 2}.items()}
    print(flat, transposed, inverted)

    # match (Python 3.10+)
    for command in ["start", "move 3 4", "quit", "jump"]:
        match command.split():
            case ["start"]:
                print("starting")
            case ["move", x, y]:
                print(f"moving to {x},{y}")
            case ["quit"]:
                print("bye")
            case _:
                print(f"unknown: {command}")

    with timed_block("async section"):
        asyncio.run(main_async())


if __name__ == "__main__":
    main()

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  ┃  ⚠️  أغلاط المستوى المتوسط
#
#  1. print بدل logging في البرامج الحقيقية
#  2. Decorator بدون functools.wraps       -> تضيع اسم الدالة
#  3. time.sleep داخل async                -> يوقف كل شيء، استخدم asyncio.sleep
#  4. تحمل ملف ضخم كله بالذاكرة            -> Generators
#  5. نصوص عشوائية للحالات                -> Enum
#  6. except Exception في كل مكان         -> Exceptions مخصصة
#  7. list = [] في dataclass              -> field(default_factory=list)
#  8. تعيد حساب نفس الشيء كثير            -> functools.cache
#  9. ما تكتب Type Hints                   -> شغل mypy أو pyright عليها
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
