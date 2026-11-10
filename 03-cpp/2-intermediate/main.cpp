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
// ║                          LEVEL 2  ·  INTERMEDIATE                          ║
// ║                              ▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰                              ║
// ╚════════════════════════════════════════════════════════════════════════════╝
//
//    ▌ C++ — دليل المتوسط
//
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  ◆ لمين هذا الملف؟
//  لك إذا تعرف الكلاسات و vector و smart pointers،
//  وتبي تفهم كيف C++ تدير الموارد وتكتب كود حديث وسريع.
//
//  ◆ وش بتتعلم؟
//    RAII، Rule of 0/3/5، Move Semantics
//    Templates و Concepts، Lambdas و Captures
//    STL المتقدم: unordered_map, optional, variant, algorithms
//    Threads و mutex
//
//  ◆ كيف تشغله؟
//    g++ main.cpp -std=c++20 -Wall -Wextra -pthread -o main
//    ./main
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

#include <algorithm>
#include <concepts>
#include <fstream>
#include <iterator>
#include <iostream>
#include <mutex>
#include <numeric>
#include <optional>
#include <stdexcept>
#include <string>
#include <thread>
#include <unordered_map>
#include <variant>
#include <vector>

// ╭──────────────────────────────────────────────────────────────╮
// │  01  ▸  RAII: أهم فكرة في C++
// ╰──────────────────────────────────────────────────────────────╯
//
//   الـ constructor  ──►  ياخذ المورد (ملف، ذاكرة، قفل)
//   الـ destructor   ──►  يرجعه تلقائي لما الكائن يطلع من {}
//
//   {
//       FileWriter w("log.txt");   ◄── انفتح الملف
//       w.write("hi");
//   }                              ◄── انقفل تلقائي، حتى لو صار exception
//
class FileWriter {
public:
    explicit FileWriter(const std::string& path) : file_(path) {
        if (!file_) {
            throw std::runtime_error("Cannot open " + path);
        }
    }

    void write(const std::string& line) { file_ << line << '\n'; }

private:
    std::ofstream file_; // ofstream نفسه RAII، يسكر لحاله
};

// ╭──────────────────────────────────────────────────────────────╮
// │  02  ▸  Rule of 0 / 3 / 5
// ╰──────────────────────────────────────────────────────────────╯
//  Rule of 0 ✅ (الأفضل): استخدم أنواع تدير نفسها (string, vector, unique_ptr)
//                        وما تحتاج تكتب destructor ولا copy ولا move
//
//  لو اضطريت تدير مورد بنفسك، اكتب الخمسة كلها:
//    ~T()  T(const T&)  T& operator=(const T&)  T(T&&)  T& operator=(T&&)
//  (أو operator= واحد يستقبل بالقيمة "copy-and-swap" يغطي النسخ والنقل مع بعض، زي Buffer تحت)
//
class Buffer {
public:
    explicit Buffer(size_t size) : size_(size), data_(new int[size]{}) {
        std::cout << "  Buffer(" << size_ << ") allocated\n";
    }

    ~Buffer() { delete[] data_; }

    // Copy: ينسخ البيانات (غالي)
    Buffer(const Buffer& other) : size_(other.size_), data_(new int[other.size_]) {
        std::copy(other.data_, other.data_ + size_, data_);
        std::cout << "  Buffer copied (expensive)\n";
    }

    Buffer& operator=(Buffer other) noexcept { // copy-and-swap
        swap(other);
        return *this;
    }

    // Move: "يسرق" البيانات بدل ما ينسخها (رخيص)
    //
    //   Buffer c = std::move(a);
    //   قبل:  a.data_ ──► [ 1 2 3 ]      (c لسا ما انبنى)
    //   بعد:  a.data_ ──► null           c.data_ ──► [ 1 2 3 ]
    //
    Buffer(Buffer&& other) noexcept : size_(other.size_), data_(other.data_) {
        other.data_ = nullptr;
        other.size_ = 0;
        std::cout << "  Buffer moved (cheap)\n";
    }

    void swap(Buffer& other) noexcept {
        std::swap(size_, other.size_);
        std::swap(data_, other.data_);
    }

    size_t size() const { return size_; }

private:
    size_t size_;
    int* data_;
};

// ╭──────────────────────────────────────────────────────────────╮
// │  03  ▸  Templates و Concepts
// ╰──────────────────────────────────────────────────────────────╯
// Concept: شرط على النوع، والخطأ يطلع واضح بدل صفحة رسائل
template <typename T>
concept Numeric = std::integral<T> || std::floating_point<T>;

template <Numeric T>
T average(const std::vector<T>& values) {
    if (values.empty()) return T{};
    return std::accumulate(values.begin(), values.end(), T{}) / static_cast<T>(values.size());
}

// ╭──────────────────────────────────────────────────────────────╮
// │  04  ▸  optional و variant
// ╰──────────────────────────────────────────────────────────────╯
// optional: "ممكن ما فيه نتيجة" بدل ما ترجع -1 أو nullptr
std::optional<int> findIndex(const std::vector<std::string>& v, const std::string& target) {
    auto it = std::find(v.begin(), v.end(), target);
    if (it == v.end()) return std::nullopt;
    return static_cast<int>(std::distance(v.begin(), it));
}

// variant: قيمة وحدة من عدة أنواع (بديل آمن لـ union)
using Value = std::variant<int, double, std::string>;

void printValue(const Value& v) {
    std::visit([](const auto& x) { std::cout << "  value: " << x << "\n"; }, v);
}

struct Employee {
    std::string name;
    std::string department;
    double salary;
};

int main() {
    // RAII
    {
        FileWriter writer("log.txt");
        writer.write("Program started");
    }

    // ╭──────────────────────────────────────────────────────────────╮
    // │  05  ▸  Move Semantics
    // ╰──────────────────────────────────────────────────────────────╯
    std::cout << "Move semantics:\n";
    Buffer a(1000);
    Buffer b = a;              // نسخ
    Buffer c = std::move(a);   // نقل، a صار فاضي (لأننا كاتبين Buffer كذا)
    // ⚠️ بعد std::move لا تعتمد على قيمة a: أغلب الأنواع تتركه "صالح بس غير محدد"
    //    هنا قراءة size آمنة بس لأننا عارفين وش يسوي Buffer
    std::cout << "  a=" << a.size() << " b=" << b.size() << " c=" << c.size() << "\n";

    std::vector<Buffer> buffers;
    buffers.reserve(2);              // ⚠️ reserve يمنع إعادة الحجز والنسخ المتكرر
    buffers.emplace_back(10);        // emplace_back يبنيه في مكانه مباشرة
    buffers.push_back(Buffer(20));   // يتنقل (move) مو ينسخ

    // ╭──────────────────────────────────────────────────────────────╮
    // │  06  ▸  Lambdas و Captures
    // ╰──────────────────────────────────────────────────────────────╯
    //   [ ]     ما ياخذ شيء من برا
    //   [x]     ياخذ نسخة من x
    //   [&x]    ياخذ مرجع لـ x (يقدر يعدل عليه)
    //   [=]     نسخة من كل شيء يستخدمه
    //   [&]     مرجع لكل شيء ⚠️ خطر لو الـ lambda عاشت أطول من المتغيرات
    int threshold = 5000;
    int counter = 0;
    auto isHighSalary = [threshold](const Employee& e) { return e.salary > threshold; };
    auto countIt = [&counter]() { counter++; };
    countIt();
    countIt();
    std::cout << "counter = " << counter << "\n";

    // ╭──────────────────────────────────────────────────────────────╮
    // │  07  ▸  STL Algorithms
    // ╰──────────────────────────────────────────────────────────────╯
    std::vector<Employee> staff = {
        {"Ali", "IT", 9000},
        {"Sara", "IT", 12000},
        {"Omar", "HR", 4500},
        {"Noor", "HR", 7000},
    };

    std::sort(staff.begin(), staff.end(),
              [](const Employee& x, const Employee& y) { return x.salary > y.salary; });

    auto highCount = std::count_if(staff.begin(), staff.end(), isHighSalary);
    bool anyHR = std::any_of(staff.begin(), staff.end(),
                             [](const Employee& e) { return e.department == "HR"; });

    std::vector<std::string> names;
    std::transform(staff.begin(), staff.end(), std::back_inserter(names),
                   [](const Employee& e) { return e.name; });

    std::cout << "high=" << highCount << " anyHR=" << anyHR << " first=" << names.front() << "\n";

    // ╭──────────────────────────────────────────────────────────────╮
    // │  08  ▸  unordered_map: بحث سريع جدًا
    // ╰──────────────────────────────────────────────────────────────╯
    //   map            مرتب، البحث O(log n)
    //   unordered_map  مو مرتب، البحث O(1) تقريبًا  ← أسرع غالبًا
    std::unordered_map<std::string, double> totalByDept;
    for (const auto& e : staff) {
        totalByDept[e.department] += e.salary;
    }
    for (const auto& [dept, total] : totalByDept) {
        std::cout << dept << ": " << total << "\n";
    }

    // optional و variant
    if (auto idx = findIndex(names, "Omar")) {
        std::cout << "Omar at index " << *idx << "\n";
    }
    std::cout << "average = " << average(std::vector<double>{1.5, 2.5, 3.5}) << "\n";

    std::vector<Value> values = {42, 3.14, std::string("hello")};
    for (const auto& v : values) printValue(v);

    // ╭──────────────────────────────────────────────────────────────╮
    // │  09  ▸  Threads و mutex
    // ╰──────────────────────────────────────────────────────────────╯
    //
    //   Thread 1 ──┐
    //   Thread 2 ──┼──► [ mutex 🔒 ] ──► shared total
    //   Thread 3 ──┘     واحد بس يدخل بكل مرة
    //
    //  ⚠️ بدون mutex: Race Condition والنتيجة تطلع غلط عشوائيًا
    long long sharedTotal = 0;
    std::mutex mtx;
    std::vector<std::jthread> workers;

    for (int t = 0; t < 4; t++) {
        workers.emplace_back([&sharedTotal, &mtx]() {
            long long local = 0;
            for (int i = 0; i < 100000; i++) local += 1;

            std::lock_guard<std::mutex> lock(mtx); // RAII للقفل
            sharedTotal += local;
        });
    }
    workers.clear(); // jthread يسوي join تلقائي

    std::cout << "sharedTotal = " << sharedTotal << "\n";

    return 0;
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  ┃  ⚠️  أغلاط المستوى المتوسط
//
//  1. تدير موارد يدويًا وتنسى Rule of 5 -> استخدم Rule of 0
//  2. تستخدم المتغير بعد std::move
//  3. push_back بكثرة وأنت تعرف العدد مسبقًا بدون reserve
//  4. [&] في lambda تعيش بعد ما تخلص الدالة -> Dangling Reference
//  5. متغير مشترك بين Threads بدون mutex     -> Race Condition
//  6. std::thread وتنسى join               -> البرنامج يطيح، استخدم jthread
//  7. ترجع -1 أو nullptr للدلالة على "ما فيه" -> std::optional
//  8. map وأنت ما تحتاج الترتيب            -> unordered_map أسرع
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
