// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
// ╔════════════════════════════════════════════════════════════════════════════╗
// ║                                                                            ║
// ║                              ████                                          ║
// ║                             █       █     █                                ║
// ║                             █     █████ █████                              ║
// ║                             █       █     █                                ║
// ║                              ████                                          ║
// ║                                                                            ║
// ║                             LEVEL 1  ·  BASICS                             ║
// ║                              ▰▰▰▰▰▰▰▰▱▱▱▱▱▱▱▱                              ║
// ╚════════════════════════════════════════════════════════════════════════════╝
//
//    ▌ C++ — دليل المبتدئ
//
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  ◆ وش هي؟
//  C بس "مطورة": فيها كلاسات ومكتبة جاهزة ضخمة (STL) وإدارة ذاكرة أذكى.
//  تستخدم في:
//    - الألعاب ومحركاتها (Unreal Engine)
//    - البرامج الثقيلة والمتصفحات
//    - أي شيء يبي أداء عالي
//
//  ◆ كيف تشغل الملف؟
//    g++ main.cpp -std=c++20 -Wall -Wextra -o main
//    ./main
//
//  ◆ أهم شيء تعرفه:
//    - استخدم أدوات C++ الحديثة (vector, string, smart pointers)
//      ولا تكتب C++ كأنها C
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

#include <algorithm>
#include <iostream>
#include <map>
#include <memory>
#include <stdexcept>
#include <string>
#include <vector>

// ╭──────────────────────────────────────────────────────────────╮
// │  ▸  الكلاسات والوراثة
// ╰──────────────────────────────────────────────────────────────╯
class Animal {
public:
    // Constructor مع قائمة تهيئة (: name_(...)) أسرع من التعيين داخل الأقواس
    explicit Animal(std::string name) : name_(std::move(name)) {}

    // ⚠️ لو بتحذف كائن الابن عن طريق مؤشر للأب، لازم الـ destructor في الأب يكون virtual
    // وإلا يصير سلوك غير معرّف (غالبًا destructor الابن ما يشتغل)
    virtual ~Animal() = default;

    // virtual: الابن يقدر يغيرها
    virtual void speak() const {
        std::cout << name_ << " makes a sound\n";
    }

    // const بالآخر = الدالة ما تعدل على الكائن
    const std::string& name() const { return name_; }

protected:
    std::string name_; // protected: الكلاس وأبناؤه بس يشوفونه
};

class Dog : public Animal {
public:
    using Animal::Animal; // ياخذ نفس الـ constructor حق الأب

    // override: تأكيد إنك تغير دالة الأب، المترجم ينبهك لو غلطت بالاسم
    void speak() const override {
        std::cout << name_ << " barks\n";
    }
};

// ╭──────────────────────────────────────────────────────────────╮
// │  ▸  الدوال
// ╰──────────────────────────────────────────────────────────────╯
int add(int a, int b) {
    return a + b;
}

// ⚠️ لا تمرر الأشياء الكبيرة بالقيمة (تنسخ كل شيء = بطء)
// ❌ void printVector(std::vector<int> v)
// ✅ مررها كمرجع ثابت const&
void printVector(const std::vector<int>& v) {
    for (const auto& x : v) {
        std::cout << x << " ";
    }
    std::cout << "\n";
}

// & بدون const = الدالة تعدل على الأصل
void increase(int& value) {
    value += 10;
}

// Template: دالة وحدة تشتغل مع أي نوع
template <typename T>
T maxOf(T a, T b) {
    return (a > b) ? a : b;
}

int main() {
    // ╭──────────────────────────────────────────────────────────────╮
    // │  01  ▸  المتغيرات
    // ╰──────────────────────────────────────────────────────────────╯
    int age = 20;
    double price = 9.99;
    bool active = true;
    std::string name = "Ahmed"; // استخدم std::string مو char[]
    auto city = std::string("Riyadh"); // auto: المترجم يعرف النوع

    // ╭──────────────────────────────────────────────────────────────╮
    // │  02  ▸  الطباعة والإدخال
    // ╰──────────────────────────────────────────────────────────────╯
    std::cout << "Hello " << name << ", age " << age << "\n";
    std::cout << "Price: " << price << ", active: " << std::boolalpha << active << "\n";

    // ╭──────────────────────────────────────────────────────────────╮
    // │  03  ▸  الشروط والتكرار
    // ╰──────────────────────────────────────────────────────────────╯
    if (age >= 18) {
        std::cout << "Adult\n";
    }

    for (int i = 0; i < 3; i++) {
        std::cout << "i = " << i << "\n";
    }

    // ╭──────────────────────────────────────────────────────────────╮
    // │  04  ▸  vector: مصفوفة تكبر وتصغر لحالها (بتستخدمها كثير)
    // ╰──────────────────────────────────────────────────────────────╯
    std::vector<int> numbers = {5, 2, 8, 1};
    numbers.push_back(10);                       // أضف بالآخر
    std::sort(numbers.begin(), numbers.end());   // رتّب
    printVector(numbers);

    std::cout << "Size: " << numbers.size() << "\n";

    // ⚠️ numbers[100] ما يشيك على الحدود = سلوك غير معروف
    // numbers.at(100) يشيك ويرمي خطأ تقدر تمسكه
    try {
        int value = numbers.at(100);
        std::cout << value << "\n";
    } catch (const std::out_of_range& e) {
        std::cout << "Error: " << e.what() << "\n";
    }

    // البحث عن عنصر
    auto it = std::find(numbers.begin(), numbers.end(), 8);
    if (it != numbers.end()) {
        std::cout << "Found 8\n";
    }

    // ⚠️ لا تحذف من vector وأنت تلف عليه بـ for عادي
    // ✅ الطريقة الصح تحذف كل الأرقام الأقل من 3:
    std::erase_if(numbers, [](int x) { return x < 3; });
    printVector(numbers);

    // ╭──────────────────────────────────────────────────────────────╮
    // │  05  ▸  map: مفتاح وقيمة
    // ╰──────────────────────────────────────────────────────────────╯
    std::map<std::string, int> scores;
    scores["Ali"] = 90;
    scores["Sara"] = 95;

    for (const auto& [key, value] : scores) {
        std::cout << key << ": " << value << "\n";
    }

    // ⚠️ scores["Omar"] لو مو موجود بيضيفه بقيمة 0! استخدم find أو contains
    if (scores.contains("Omar")) {
        std::cout << "Omar exists\n";
    }

    // ╭──────────────────────────────────────────────────────────────╮
    // │  06  ▸  المراجع (References)
    // ╰──────────────────────────────────────────────────────────────╯
    int points = 5;
    increase(points);
    std::cout << "Points: " << points << "\n"; // 15

    // ╭──────────────────────────────────────────────────────────────╮
    // │  07  ▸  Smart Pointers: بدال new و delete
    // ╰──────────────────────────────────────────────────────────────╯
    // ❌ الطريقة القديمة الخطيرة:
    //    Animal* a = new Animal("Cat");
    //    ... لو نسيت delete a; = تسريب ذاكرة
    //
    // ✅ unique_ptr: له مالك واحد، وينحذف تلقائي لما يطلع من النطاق
    //
    //   unique_ptr:   pet ──►  [ Dog "Rex" ]        مالك واحد
    //
    //   shared_ptr:   cat     ──┐
    //                           ├──►  [ "Cat" ]     count = 2
    //                 sameCat ──┘
    //
    //   لما يختفي آخر مالك، الكائن ينحذف تلقائي
    //
    std::unique_ptr<Animal> pet = std::make_unique<Dog>("Rex");
    pet->speak();

    // shared_ptr: أكثر من واحد يملكونه، ينحذف لما آخر واحد يخلص منه
    std::shared_ptr<Animal> cat = std::make_shared<Animal>("Cat");
    std::shared_ptr<Animal> sameCat = cat;
    std::cout << "Owners: " << cat.use_count() << "\n";

    // قائمة حيوانات مختلفة (Polymorphism)
    std::vector<std::unique_ptr<Animal>> zoo;
    zoo.push_back(std::make_unique<Dog>("Max"));
    zoo.push_back(std::make_unique<Animal>("Bird"));
    for (const auto& animal : zoo) {
        animal->speak();
    }

    // ╭──────────────────────────────────────────────────────────────╮
    // │  08  ▸  Lambda: دالة صغيرة بدون اسم
    // ╰──────────────────────────────────────────────────────────────╯
    auto square = [](int x) { return x * x; };
    std::cout << "square(4) = " << square(4) << "\n";

    std::cout << "maxOf(3, 7) = " << maxOf(3, 7) << "\n";
    std::cout << "add(2, 3) = " << add(2, 3) << "\n";

    return 0;
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  ┃  ⚠️  ملخص الأغلاط اللي لازم ما تطيح فيها
//
//  1. new و delete يدوي                -> unique_ptr / make_unique
//  2. تمرر أشياء كبيرة بالقيمة         -> const&
//  3. كلاس أب بدون virtual destructor
//  4. using namespace std; في ملفات .h -> تضارب أسماء
//  5. v[i] بدون تأكد من الحدود         -> v.at(i)
//  6. ترجع مرجع (&) لمتغير محلي من دالة -> المتغير يموت وأنت ماسكه
//  7. تحذف من vector وأنت تلف عليه     -> std::erase_if
//  8. map[key] للقراءة                  -> يضيف المفتاح لو مو موجود
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
