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
// ║                          LEVEL 2  ·  INTERMEDIATE                          ║
// ║                              ▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰                              ║
// ╚════════════════════════════════════════════════════════════════════════════╝
//
//    ▌ Java — دليل المتوسط
//
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  ◆ لمين هذا الملف؟
//  لك إذا تعرف الكلاسات والقوائم والـ HashMap، وتبي تكتب
//  Java حديثة (21+) بالطريقة اللي تنكتب فيها بالشركات.
//
//  ◆ وش بتتعلم؟
//    abstract و interface و sealed، Generics
//    Records و Enums المتقدمة، Streams المتقدمة (groupingBy)
//    Optional صح، Exceptions مخصصة
//    اختيار الـ Collection المناسبة، CompletableFuture
//
//  ◆ كيف تشغله؟
//    java Main.java      (يحتاج Java 21 أو أحدث)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

import java.util.*;
import java.util.concurrent.*;
import java.util.function.*;
import java.util.stream.*;

public class Main {

    // ╭──────────────────────────────────────────────────────────────╮
    // │  01  ▸  Enum متقدم: له قيم ودوال
    // ╰──────────────────────────────────────────────────────────────╯
    enum Plan {
        FREE(0, 1),
        PRO(49, 10),
        BUSINESS(199, 100);

        private final int priceSar;
        private final int maxProjects;

        Plan(int priceSar, int maxProjects) {
            this.priceSar = priceSar;
            this.maxProjects = maxProjects;
        }

        boolean canCreate(int currentProjects) {
            return currentProjects < maxProjects;
        }
    }

    // ╭──────────────────────────────────────────────────────────────╮
    // │  02  ▸  sealed interface + records + pattern matching
    // ╰──────────────────────────────────────────────────────────────╯
    //
    //               sealed Shape
    //            ┌───────┼────────┐
    //            ▼       ▼        ▼
    //         Circle   Rect   Triangle      ← بس هذول مسموح، محد يضيف غيرهم
    //
    //  الفايدة: switch يعرف كل الاحتمالات، ولو نسيت واحد المترجم ينبهك
    sealed interface Shape permits Circle, Rect, Triangle {}
    record Circle(double radius) implements Shape {}
    record Rect(double width, double height) implements Shape {}
    record Triangle(double base, double height) implements Shape {}

    static double area(Shape shape) {
        return switch (shape) {
            case Circle c -> Math.PI * c.radius() * c.radius();
            case Rect r -> r.width() * r.height();
            case Triangle t -> 0.5 * t.base() * t.height();
        };
    }

    // record مع تحقق في الـ constructor
    record Employee(String name, String department, double salary) {
        Employee {
            Objects.requireNonNull(name);
            if (salary < 0) throw new IllegalArgumentException("salary < 0");
        }
    }

    // ╭──────────────────────────────────────────────────────────────╮
    // │  03  ▸  abstract class مقابل interface
    // ╰──────────────────────────────────────────────────────────────╯
    //  interface: "وش يقدر يسوي" (عقد + ممكن دوال default، بس بدون حقول/حالة)، تقدر تطبق أكثر من واحد
    //  abstract:  "وش هو" + كود مشترك، ترث من واحد بس
    interface Notifier {
        void send(String message);

        default void sendAll(List<String> messages) {
            messages.forEach(this::send);
        }
    }

    static abstract class BaseNotifier implements Notifier {
        private int sentCount = 0;

        @Override
        public final void send(String message) {
            deliver(message);
            sentCount++;
        }

        protected abstract void deliver(String message);

        int sentCount() {
            return sentCount;
        }
    }

    static class EmailNotifier extends BaseNotifier {
        @Override
        protected void deliver(String message) {
            System.out.println("[Email] " + message);
        }
    }

    // ╭──────────────────────────────────────────────────────────────╮
    // │  04  ▸  Generics مع حدود
    // ╰──────────────────────────────────────────────────────────────╯
    static class Repository<T, ID> {
        private final Map<ID, T> store = new HashMap<>();
        private final Function<T, ID> idGetter;

        Repository(Function<T, ID> idGetter) {
            this.idGetter = idGetter;
        }

        void save(T item) {
            store.put(idGetter.apply(item), item);
        }

        Optional<T> findById(ID id) {
            return Optional.ofNullable(store.get(id));
        }

        List<T> findAll() {
            return List.copyOf(store.values()); // نسخة ما تتعدل
        }
    }

    // <T extends Comparable<T>>: T لازم يقبل المقارنة
    static <T extends Comparable<T>> T maxOf(List<T> items) {
        if (items.isEmpty()) throw new NoSuchElementException("empty list");
        T best = items.get(0);
        for (T item : items) {
            if (item.compareTo(best) > 0) best = item;
        }
        return best;
    }

    // ╭──────────────────────────────────────────────────────────────╮
    // │  05  ▸  Exception مخصصة
    // ╰──────────────────────────────────────────────────────────────╯
    //   Checked   (extends Exception):         المترجم يجبرك تتعامل معها
    //   Unchecked (extends RuntimeException):  أخطاء برمجية أو منطق
    static class InsufficientBalanceException extends RuntimeException {
        private final double missing;

        InsufficientBalanceException(double missing) {
            super("Missing %.2f SAR".formatted(missing));
            this.missing = missing;
        }

        double missing() {
            return missing;
        }
    }

    static void withdraw(double balance, double amount) {
        if (amount > balance) throw new InsufficientBalanceException(amount - balance);
    }

    public static void main(String[] args) throws Exception {

        // ╭──────────────────────────────────────────────────────────────╮
        // │  06  ▸  اختيار الـ Collection المناسبة
        // ╰──────────────────────────────────────────────────────────────╯
        //
        //   تبي ترتيب الإضافة + وصول بالرقم؟      ──►  ArrayList
        //   تبي بدون تكرار؟                        ──►  HashSet
        //   بدون تكرار + مرتب؟                     ──►  TreeSet
        //   مفتاح وقيمة؟                           ──►  HashMap
        //   مفتاح وقيمة + مرتب بالمفتاح؟           ──►  TreeMap
        //   مفتاح وقيمة + ترتيب الإضافة؟           ──►  LinkedHashMap
        //   طابور (أول داخل أول طالع)؟             ──►  ArrayDeque
        //   أولوية (الأصغر يطلع أول)؟              ──►  PriorityQueue
        //   بين Threads؟                           ──►  ConcurrentHashMap
        //
        Set<String> tags = new TreeSet<>(List.of("java", "api", "java", "db"));
        System.out.println("tags = " + tags);

        PriorityQueue<Integer> tasks = new PriorityQueue<>(List.of(5, 1, 3));
        System.out.println("next task priority = " + tasks.poll());

        // ╭──────────────────────────────────────────────────────────────╮
        // │  07  ▸  Streams المتقدمة
        // ╰──────────────────────────────────────────────────────────────╯
        List<Employee> staff = List.of(
                new Employee("Ali", "IT", 9000),
                new Employee("Sara", "IT", 12000),
                new Employee("Omar", "HR", 4500),
                new Employee("Noor", "HR", 7000));

        Map<String, Double> avgByDept = staff.stream()
                .collect(Collectors.groupingBy(Employee::department,
                        Collectors.averagingDouble(Employee::salary)));

        Map<Boolean, List<String>> highVsLow = staff.stream()
                .collect(Collectors.partitioningBy(e -> e.salary() > 8000,
                        Collectors.mapping(Employee::name, Collectors.toList())));

        Optional<Employee> topEarner = staff.stream().max(Comparator.comparingDouble(Employee::salary));

        String names = staff.stream()
                .sorted(Comparator.comparing(Employee::department).thenComparing(Employee::name))
                .map(Employee::name)
                .collect(Collectors.joining(", ", "[", "]"));

        System.out.println(avgByDept);
        System.out.println(highVsLow);
        System.out.println(names);

        // ╭──────────────────────────────────────────────────────────────╮
        // │  08  ▸  Optional صح
        // ╰──────────────────────────────────────────────────────────────╯
        // ❌ optional.get() بدون فحص = نفس مشكلة null
        // ❌ Optional كمعامل في دالة أو حقل في كلاس
        // ✅ للقيم الراجعة من الدوال، وتسلسلها كذا:
        String topName = topEarner
                .filter(e -> e.salary() > 10000)
                .map(Employee::name)
                .orElse("nobody");
        System.out.println("top = " + topName);

        // Repository + Generics
        var repo = new Repository<Employee, String>(Employee::name);
        staff.forEach(repo::save);
        repo.findById("Omar").ifPresentOrElse(
                e -> System.out.println("found " + e),
                () -> System.out.println("not found"));
        System.out.println("max = " + maxOf(List.of(3, 9, 4)));

        // sealed + records
        List<Shape> shapes = List.of(new Circle(1), new Rect(2, 3), new Triangle(4, 5));
        shapes.forEach(s -> System.out.printf("%s area=%.2f%n", s, area(s)));

        // Enum
        Plan plan = Plan.PRO;
        System.out.println(plan + " costs " + plan.priceSar + ", can create? " + plan.canCreate(3));

        // abstract / interface
        var notifier = new EmailNotifier();
        notifier.sendAll(List.of("Welcome", "Your order shipped"));
        System.out.println("sent = " + notifier.sentCount());

        // Exceptions
        try {
            withdraw(100, 250);
        } catch (InsufficientBalanceException e) {
            System.out.println(e.getMessage() + " -> missing " + e.missing());
        }

        // ╭──────────────────────────────────────────────────────────────╮
        // │  09  ▸  CompletableFuture و Virtual Threads
        // ╰──────────────────────────────────────────────────────────────╯
        //
        //   supplyAsync(users) ─┐
        //                       ├──► thenCombine ──► النتيجة
        //   supplyAsync(orders)─┘
        //
        try (ExecutorService executor = Executors.newVirtualThreadPerTaskExecutor()) {
            CompletableFuture<String> users = CompletableFuture.supplyAsync(() -> slow("users"), executor);
            CompletableFuture<String> orders = CompletableFuture.supplyAsync(() -> slow("orders"), executor);

            String combined = users.thenCombine(orders, (u, o) -> u + " + " + o)
                    .orTimeout(2, TimeUnit.SECONDS)
                    .exceptionally(ex -> "failed: " + ex.getMessage())
                    .get();
            System.out.println(combined);
        }

        // ConcurrentHashMap: آمن بين الـ Threads
        Map<String, Integer> hits = new ConcurrentHashMap<>();
        IntStream.range(0, 1000).parallel().forEach(i -> hits.merge("page", 1, Integer::sum));
        System.out.println("hits = " + hits.get("page"));
    }

    static String slow(String name) {
        try {
            Thread.sleep(300);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt(); // ⚠️ لا تبلع InterruptedException
            throw new RuntimeException(e);
        }
        return name + " loaded";
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  ┃  ⚠️  أغلاط المستوى المتوسط
//
//  1. optional.get() بدون فحص             -> orElse / map / ifPresent
//  2. Optional كحقل أو معامل
//  3. HashMap بين Threads                 -> ConcurrentHashMap
//  4. تبلع InterruptedException          -> رجّع حالة الـ interrupt
//  5. ترجع قائمة داخلية قابلة للتعديل    -> List.copyOf
//  6. switch بدون sealed                  -> تنسى حالات وما تدري
//  7. Streams لكل شيء حتى البسيط          -> for عادية أوضح أحيانًا
//  8. parallel() على قوائم صغيرة          -> أبطأ مو أسرع
//  9. ArrayList لكل شيء                   -> اختر الـ Collection المناسبة
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
