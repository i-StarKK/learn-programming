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
# ║                             LEVEL 1  ·  BASICS                             ║
# ║                              ▰▰▰▰▰▰▰▰▱▱▱▱▱▱▱▱                              ║
# ╚════════════════════════════════════════════════════════════════════════════╝
#
#    ▌ Python — دليل المبتدئ
#
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  ◆ وش هي؟
#  أسهل لغة للبداية. تستخدم في:
#    - الذكاء الاصطناعي وتحليل البيانات
#    - الأتمتة (سكربتات توفر عليك شغل)
#    - الباك إند (Django, FastAPI)
#
#  ◆ كيف تشغل الملف؟
#    python main.py
#
#  ◆ أهم شيء تعرفه:
#    - ما تحتاج ; في آخر السطر، والبلوكات ما تنكتب بـ {}
#      (الأقواس {} تستخدم للـ dict والـ set)
#    - المسافات (Indentation) هي اللي تحدد البلوكات
#      استخدم 4 مسافات دايمًا، ولا تخلط Tab مع Space
#    - كل مشروع سو له بيئة خاصة:
#        python -m venv .venv
#    - ⚠️ لا تسمي ملفك باسم مكتبة (random.py, json.py) بيتعارض معها
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

import json
from dataclasses import dataclass
from pathlib import Path

# ╭──────────────────────────────────────────────────────────────╮
# │  01  ▸  المتغيرات (ما تحتاج تحدد النوع)
# ╰──────────────────────────────────────────────────────────────╯
name = "Ahmed"      # نص str
age = 20            # رقم صحيح int
price = 9.99        # رقم عشري float
is_active = True    # True أو False (أول حرف كبير)
nothing = None      # يعني "ما فيه قيمة"

# f-string: أسهل طريقة تحط متغيرات داخل نص
print(f"Hello {name}, you are {age} years old")
print(f"Price: {price:.2f}")

# تحويل الأنواع
number_text = "42"
number = int(number_text)   # نص -> رقم
back_to_text = str(number)  # رقم -> نص

# ⚠️ input() ترجع نص دايمًا، لازم تحوله لو تبيه رقم
# user_age = int(input("Your age: "))

# ╭──────────────────────────────────────────────────────────────╮
# │  02  ▸  الشروط
# ╰──────────────────────────────────────────────────────────────╯
if age >= 18:
    print("Adult")
elif age >= 13:
    print("Teen")
else:
    print("Child")

# شرط في سطر واحد
status = "adult" if age >= 18 else "minor"

# and / or / not بدل && || !
if age > 10 and is_active:
    print("Active and older than 10")

# ╭──────────────────────────────────────────────────────────────╮
# │  03  ▸  التكرار
# ╰──────────────────────────────────────────────────────────────╯
for i in range(5):          # 0 إلى 4
    print(i)

for i in range(1, 10, 2):   # من 1 إلى 9 بخطوة 2
    print(i)

count = 3
while count > 0:
    print(f"Count: {count}")
    count -= 1

# ╭──────────────────────────────────────────────────────────────╮
# │  04  ▸  القوائم (list)
# ╰──────────────────────────────────────────────────────────────╯
names = ["Ali", "Sara", "Omar"]
names.append("Noor")        # أضف بالآخر
names.remove("Ali")         # احذف
print(names[0])             # أول عنصر
print(names[-1])            # آخر عنصر
print(names[1:3])           # من 1 إلى 2 (slicing)
print(len(names))           # العدد

# enumerate: تاخذ الرقم والعنصر مع بعض
for index, n in enumerate(names):
    print(index, n)

# List comprehension: تسوي قائمة في سطر واحد
squares = [x * x for x in range(10)]
evens = [x for x in range(10) if x % 2 == 0]

# ⚠️ لا تحذف من قائمة وأنت تلف عليها، سو قائمة جديدة بدالها
numbers = [1, 2, 3, 4, 5]
numbers = [x for x in numbers if x != 3]

# ⚠️ النسخ: b = a ما ينسخ! الاثنين يأشرون لنفس القائمة
#
#   a ──┐
#       ├──►  [1, 2, 3, 4]    نفس القائمة (بعد b.append(4))
#   b ──┘
#
#   c ─────►  [1, 2, 3, 4]    نسخة مستقلة (a.copy())، لو عدلت عليها a ما تتأثر
#
a = [1, 2, 3]
b = a
b.append(4)
print(a)        # [1, 2, 3, 4]  تغيرت a بعد!
c = a.copy()    # ✅ نسخة جديدة (سطحية: لو فيها قوائم داخلية استخدم copy.deepcopy)

# ╭──────────────────────────────────────────────────────────────╮
# │  05  ▸  القاموس (dict) والأنواع الثانية
# ╰──────────────────────────────────────────────────────────────╯
user = {"name": "Sara", "age": 22}
user["email"] = "sara@example.com"

# ⚠️ user["phone"] يطيح لو المفتاح مو موجود، استخدم get
print(user.get("phone", "No phone"))

for key, value in user.items():
    print(key, value)

unique = {1, 2, 2, 3}   # set: بدون تكرار -> {1, 2, 3}
point = (10, 20)        # tuple: ما تتغير

# ╭──────────────────────────────────────────────────────────────╮
# │  06  ▸  الدوال
# ╰──────────────────────────────────────────────────────────────╯
# : int و -> int اسمها Type Hints، اختيارية بس تساعدك كثير
def add(a: int, b: int = 0) -> int:
    return a + b


print(add(3, 4))
print(add(5))           # b تاخذ 0
print(add(b=2, a=1))    # تقدر تحدد بالاسم


# ⚠️ غلط مشهور: قائمة كقيمة افتراضية
# ❌ def add_item(item, items=[]):  القائمة تنحفظ وتتراكم بين الاستدعاءات!
def add_item(item, items=None):  # ✅ الصح
    if items is None:
        items = []
    items.append(item)
    return items


# *args و **kwargs: تاخذ عدد مفتوح من المعاملات
def total(*args):
    return sum(args)


print(total(1, 2, 3, 4))

# lambda: دالة صغيرة بسطر واحد
double = lambda x: x * 2
sorted_names = sorted(names, key=lambda n: len(n))

# ╭──────────────────────────────────────────────────────────────╮
# │  07  ▸  التعامل مع الأخطاء
# ╰──────────────────────────────────────────────────────────────╯
try:
    result = int("abc")
except ValueError as e:     # ✅ حدد نوع الخطأ
    print("Invalid number:", e)
finally:
    print("This always runs")

# ❌ لا تسوي:
# try:
#     ...
# except:
#     pass
# هذي تبلع كل الأخطاء وما تدري وش صار

# ╭──────────────────────────────────────────────────────────────╮
# │  08  ▸  الملفات
# ╰──────────────────────────────────────────────────────────────╯
# with تقفل الملف تلقائي حتى لو صار خطأ
# encoding="utf-8" مهمة جدًا عشان العربي (خصوصًا على ويندوز)
with open("data.txt", "w", encoding="utf-8") as f:
    f.write("مرحبا\n")

with open("data.txt", "r", encoding="utf-8") as f:
    print(f.read())

# JSON
data = {"name": "Ali", "skills": ["python", "sql"]}
Path("data.json").write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")
loaded = json.loads(Path("data.json").read_text(encoding="utf-8"))
print(loaded["skills"])


# ╭──────────────────────────────────────────────────────────────╮
# │  09  ▸  الكلاسات
# ╰──────────────────────────────────────────────────────────────╯
class Car:
    # __init__ = الـ constructor
    # self = الكائن نفسه، يكون أول معامل في دوال الكائن العادية
    # (اسمه متعارف عليه مو كلمة محجوزة، و @staticmethod ما تاخذه)
    def __init__(self, model: str, year: int):
        self.model = model
        self.year = year

    def drive(self):
        print(f"{self.model} is driving")

    # __str__ = وش يطلع لما تسوي print للكائن
    def __str__(self):
        return f"Car({self.model}, {self.year})"


# الوراثة
class ElectricCar(Car):
    def __init__(self, model: str, year: int, battery: int):
        super().__init__(model, year)
        self.battery = battery

    def drive(self):
        print(f"{self.model} is driving silently ({self.battery}%)")


# dataclass: كلاس للبيانات بدون ما تكتب __init__ بنفسك
@dataclass
class Product:
    name: str
    price: float
    quantity: int = 0


# ╭──────────────────────────────────────────────────────────────╮
# │  10  ▸  المقارنة: is و ==
# ╰──────────────────────────────────────────────────────────────╯
# == تقارن القيمة
# is تقارن إنه نفس الكائن بالضبط، استخدمها مع None بس
value = None
if value is None:
    print("value is empty")


# ╭──────────────────────────────────────────────────────────────╮
# │  ▸  نقطة البداية
# ╰──────────────────────────────────────────────────────────────╯
# هذا الشرط يخلي الكود يشتغل بس لما تشغل الملف مباشرة
# مو لما ملف ثاني يسوي له import
if __name__ == "__main__":
    car = Car("Camry", 2024)
    car.drive()
    print(car)

    tesla = ElectricCar("Model 3", 2025, 80)
    tesla.drive()

    product = Product("Laptop", 3500.0, 2)
    print(product)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  ┃  ⚠️  ملخص الأغلاط اللي لازم ما تطيح فيها
#
#  1. تخلط Tab مع Space                  -> 4 مسافات دايمًا
#  2. قائمة كقيمة افتراضية items=[]       -> استخدم None
#  3. except: فاضية                       -> حدد نوع الخطأ
#  4. تسمي ملفك باسم مكتبة               -> random.py, json.py ...
#  5. b = a تحسبها نسخة                  -> استخدم .copy()
#  6. تعدل على قائمة وأنت تلف عليها
#  7. input() ترجع نص                    -> حوله بـ int()
#  8. تنسى encoding="utf-8" مع الملفات   -> العربي ممكن يخرب (خصوصًا على ويندوز)
#  9. ما تسوي venv لكل مشروع
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
