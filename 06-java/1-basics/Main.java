// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
// ╔════════════════════════════════════════════════════════════════════════════╗
// ║                                                                            ║
// ║                            ███  ███  █   █  ███                            ║
// ║                              █ █   █ █   █ █   █                           ║
// ║                              █ █████ █   █ █████                           ║
// ║                          █   █ █   █  █ █  █   █                           ║
// ║                           ███  █   █   █   █   █                           ║
// ║                                                                            ║
// ║                             LEVEL 1  ·  BASICS                             ║
// ║                              ▰▰▰▰▰▰▰▰▱▱▱▱▱▱▱▱                              ║
// ╚════════════════════════════════════════════════════════════════════════════╝
//
//    ▌ Java — دليل المبتدئ
//
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  ◆ وش هي؟
//  لغة قوية ومنتشرة جدًا. تستخدم في:
//    - أنظمة الشركات الكبيرة والبنوك
//    - تطبيقات أندرويد
//    - الباك إند (Spring Boot)
//
//  ◆ كيف تشغل الملف؟
//    java Main.java
//
//  ◆ أهم شيء تعرفه:
//    - كل شيء داخل كلاس
//    - ⚠️ اسم الملف لازم يطابق اسم الكلاس public (Main.java = class Main)
//    - كل أمر (statement) ينتهي بـ ;
//    - الأنواع صارمة
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;

public class Main {

    // main = نقطة البداية
    public static void main(String[] args) {

        // ╭──────────────────────────────────────────────────────────────╮
        // │  01  ▸  المتغيرات
        // ╰──────────────────────────────────────────────────────────────╯
        int age = 20;              // رقم صحيح
        long bigNumber = 9_000_000_000L; // رقم كبير (L بالآخر)
        double price = 9.99;       // رقم عشري
        boolean isActive = true;   // صح أو غلط
        char letter = 'J';         // حرف واحد
        String name = "Moayed";     // نص (S كبيرة)
        var city = "Riyadh";       // var: النوع يتحدد تلقائي
        final int MAX = 100;       // final: ثابت ما يتغير

        // ╭──────────────────────────────────────────────────────────────╮
        // │  02  ▸  الطباعة
        // ╰──────────────────────────────────────────────────────────────╯
        System.out.println("Hello " + name);
        System.out.printf("Age: %d, Price: %.2f%n", age, price);

        // ╭──────────────────────────────────────────────────────────────╮
        // │  03  ▸  الشروط
        // ╰──────────────────────────────────────────────────────────────╯
        if (age >= 18) {
            System.out.println("Adult");
        } else {
            System.out.println("Minor");
        }

        String role = "admin";
        String access = switch (role) {
            case "admin" -> "Full access";
            case "user" -> "Limited access";
            default -> "No access";
        };
        System.out.println(access);

        // ╭──────────────────────────────────────────────────────────────╮
        // │  04  ▸  التكرار
        // ╰──────────────────────────────────────────────────────────────╯
        for (int i = 0; i < 5; i++) {
            System.out.println(i);
        }

        int count = 3;
        while (count > 0) {
            System.out.println("Count: " + count);
            count--;
        }

        // ╭──────────────────────────────────────────────────────────────╮
        // │  05  ▸  مقارنة النصوص ⚠️ أهم غلطة في Java
        // ╰──────────────────────────────────────────────────────────────╯
        //
        //   a ──►  [ "hello" ]  @ 0x100
        //   b ──►  [ "hello" ]  @ 0x200
        //
        //   a == b       يقارن 0x100 مع 0x200  ──►  false
        //   a.equals(b)  يقارن "hello" مع "hello" ──► true
        //
        String a = new String("hello");
        String b = new String("hello");

        System.out.println(a == b);        // false ❌ == تقارن المكان في الذاكرة
        System.out.println(a.equals(b));   // true  ✅ equals تقارن المحتوى
        System.out.println("HELLO".equalsIgnoreCase(a)); // true، تتجاهل حالة الأحرف

        // ╭──────────────────────────────────────────────────────────────╮
        // │  06  ▸  المصفوفات والقوائم
        // ╰──────────────────────────────────────────────────────────────╯
        int[] numbers = {10, 20, 30};   // حجمها ثابت
        System.out.println(numbers[0]); // أول عنصر رقمه (index) صفر، وقيمته 10
        System.out.println(numbers.length);

        // ArrayList: تكبر وتصغر (بتستخدمها أكثر)
        List<String> names = new ArrayList<>();
        names.add("Moayed");
        names.add("Sara");
        names.add("Omar");

        for (String n : names) {
            System.out.println(n);
        }

        // ⚠️ لا تحذف من القائمة وأنت تلف عليها بـ for-each
        // غالبًا بيطلع لك ConcurrentModificationException، أو يتخطى عناصر بصمت
        // ✅ استخدم removeIf
        names.removeIf(n -> n.startsWith("O"));

        // أو Iterator
        Iterator<String> it = names.iterator();
        while (it.hasNext()) {
            if (it.next().equals("Moayed")) {
                it.remove();
            }
        }
        System.out.println(names);

        // ╭──────────────────────────────────────────────────────────────╮
        // │  07  ▸  HashMap: مفتاح وقيمة
        // ╰──────────────────────────────────────────────────────────────╯
        Map<String, Integer> scores = new HashMap<>();
        scores.put("Moayed", 90);
        scores.put("Sara", 95);

        // getOrDefault: لو المفتاح مو موجود يرجع القيمة البديلة بدل null
        System.out.println(scores.getOrDefault("Omar", 0));

        for (Map.Entry<String, Integer> entry : scores.entrySet()) {
            System.out.println(entry.getKey() + ": " + entry.getValue());
        }

        // ╭──────────────────────────────────────────────────────────────╮
        // │  08  ▸  Streams: فلترة وتحويل القوائم بشكل مرتب
        // ╰──────────────────────────────────────────────────────────────╯
        List<Integer> values = List.of(5, 2, 8, 1, 9);

        List<Integer> big = values.stream()
                .filter(v -> v > 4)
                .sorted()
                .toList();

        int sum = values.stream().mapToInt(Integer::intValue).sum();
        System.out.println(big + " sum=" + sum);

        // ╭──────────────────────────────────────────────────────────────╮
        // │  09  ▸  null و Optional
        // ╰──────────────────────────────────────────────────────────────╯
        // ⚠️ NullPointerException: أشهر خطأ في Java
        String maybe = null;
        // ❌ maybe.length() بيطيح
        if (maybe != null) {
            System.out.println(maybe.length());
        }

        // Optional: طريقة أوضح تقول "هذا ممكن يكون فاضي"
        Optional<String> found = findUser("unknown");
        System.out.println(found.orElse("Guest"));

        // ╭──────────────────────────────────────────────────────────────╮
        // │  10  ▸  التعامل مع الأخطاء
        // ╰──────────────────────────────────────────────────────────────╯
        try {
            int number = Integer.parseInt("abc");
        } catch (NumberFormatException e) {
            System.out.println("Invalid number: " + e.getMessage());
        } finally {
            System.out.println("Always runs");
        }

        // try-with-resources: يقفل الملف تلقائي
        try (BufferedReader reader = new BufferedReader(new FileReader("data.txt"))) {
            System.out.println(reader.readLine());
        } catch (IOException e) {
            System.out.println("Could not read file: " + e.getMessage());
        }

        // ╭──────────────────────────────────────────────────────────────╮
        // │  11  ▸  StringBuilder
        // ╰──────────────────────────────────────────────────────────────╯
        // ⚠️ لا تجمع نصوص بـ + داخل لوب كبير (كل مرة يسوي نص جديد = بطء)
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < 5; i++) {
            sb.append(i).append(",");
        }
        System.out.println(sb.toString());

        // ╭──────────────────────────────────────────────────────────────╮
        // │  12  ▸  الكلاسات
        // ╰──────────────────────────────────────────────────────────────╯
        Car car = new Car("Camry", 2024);
        car.drive();

        Car tesla = new ElectricCar("Model 3", 2025, 80);
        tesla.drive(); // ينفذ نسخة ElectricCar (Polymorphism)

        Car sameCar = new Car("Camry", 2024);
        System.out.println(car.equals(sameCar)); // true لأننا كتبنا equals

        System.out.println(add(3, 4));
    }

    // static = تقدر تستدعيها بدون ما تسوي كائن
    static int add(int a, int b) {
        return a + b;
    }

    static Optional<String> findUser(String id) {
        if (id.equals("1")) {
            return Optional.of("Ali");
        }
        return Optional.empty();
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  الكلاسات
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class Car {
    // private: محد يوصل لها من برا الكلاس (Encapsulation)
    // حتى الكلاس الابن ما يوصل لها، لازم يستخدم الـ Getter
    // (لو تبي الأبناء يوصلون لها مباشرة استخدم protected)
    private final String model;
    private final int year;

    public Car(String model, int year) {
        this.model = model;
        this.year = year;
    }

    // Getter: الطريقة الصح عشان تقرا خاصية private
    public String getModel() {
        return model;
    }

    public void drive() {
        System.out.println(model + " is driving");
    }

    // ⚠️ لو كتبت equals لازم تكتب hashCode معها
    // وإلا HashMap و HashSet بيتصرفون غلط
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Car other)) return false;
        return year == other.year && model.equals(other.model);
    }

    @Override
    public int hashCode() {
        return Objects.hash(model, year);
    }

    @Override
    public String toString() {
        return "Car(" + model + ", " + year + ")";
    }
}

// extends = وراثة
class ElectricCar extends Car {
    private final int battery;

    public ElectricCar(String model, int year, int battery) {
        super(model, year); // يستدعي constructor الأب
        this.battery = battery;
    }

    @Override
    public void drive() {
        System.out.println(getModel() + " is driving silently (" + battery + "%)");
    }
}

// interface: عقد يقول "أي كلاس يطبقني لازم يكون فيه هالدوال"
interface Payable {
    double calculatePay();
}

// record: كلاس بيانات جاهز (constructor + دوال قراءة بنفس اسم الحقل مثل name()
// + equals + hashCode + toString)
record Product(String name, double price) {}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  ┃  ⚠️  ملخص الأغلاط اللي لازم ما تطيح فيها
//
//  1. تقارن نصوص بـ ==                  -> استخدم equals
//  2. NullPointerException              -> شيك null أو Optional
//  3. catch (Exception e) {} فاضية
//  4. ما تقفل الملفات والاتصالات       -> try-with-resources
//  5. تحذف من List وأنت تلف عليها      -> removeIf أو Iterator
//  6. equals بدون hashCode
//  7. + للنصوص داخل لوب كبير            -> StringBuilder
//  8. اسم الملف ما يطابق اسم الكلاس public
//  9. double للفلوس                     -> استخدم BigDecimal
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
