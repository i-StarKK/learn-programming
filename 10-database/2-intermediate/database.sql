-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--
-- ╔════════════════════════════════════════════════════════════════════════════╗
-- ║                                                                            ║
-- ║                              ████  ███  █                                  ║
-- ║                             █     █   █ █                                  ║
-- ║                              ███  █ █ █ █                                  ║
-- ║                                 █ █  █  █                                  ║
-- ║                             ████   ██ █ █████                              ║
-- ║                                                                            ║
-- ║                          LEVEL 2  ·  INTERMEDIATE                          ║
-- ║                              ▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰                              ║
-- ╚════════════════════════════════════════════════════════════════════════════╝
--
--    ▌ SQL / Database — دليل المتوسط
--
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  ◆ لمين هذا الملف؟
--  لك إذا تعرف SELECT و JOIN و INSERT/UPDATE/DELETE،
--  وتبي تصمم قاعدة بيانات صح وتخلي استعلاماتك سريعة وآمنة.
--
--  ◆ وش بتتعلم؟
--    تصميم الجداول (Normalization) و رسم العلاقات
--    أنواع JOIN بالرسم، Subqueries و CTE
--    Window Functions، Indexes المركبة و EXPLAIN
--    UPSERT، Pagination الصح، Locks و Race Conditions
--    Views و Soft Delete
--
--  مكتوب لـ MySQL 8 / MariaDB 10.6+
--  ملف مستقل: يسوي قاعدة بيانات خاصة فيه ويعبيها
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

CREATE DATABASE IF NOT EXISTS learning_intermediate
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE learning_intermediate;

-- ╭──────────────────────────────────────────────────────────────╮
-- │  01  ▸  تصميم الجداول (Normalization)
-- ╰──────────────────────────────────────────────────────────────╯
--
--  ❌ جدول واحد فيه كل شيء:
--  ┌────┬───────┬───────────────┬──────────────────────┐
--  │ id │ user  │ user_email    │ products             │
--  ├────┼───────┼───────────────┼──────────────────────┤
--  │ 1  │ Ali   │ ali@mail.com  │ Laptop, Mouse        │  ◄ قائمة في خانة!
--  │ 2  │ Ali   │ ali@mail.com  │ Keyboard             │  ◄ تكرار الإيميل
--  └────┴───────┴───────────────┴──────────────────────┘
--  المشاكل: لو غير الإيميل لازم تعدله بكل مكان، وما تقدر تبحث بالمنتج صح
--
--  ✅ كل شيء في جدوله، والعلاقات بالـ IDs:
--
--   ┌──────────────┐        ┌──────────────┐        ┌──────────────┐
--   │    users     │        │    orders    │        │   products   │
--   ├──────────────┤        ├──────────────┤        ├──────────────┤
--   │ PK id        │──┐     │ PK id        │     ┌──│ PK id        │
--   │    name      │  └───<│ FK user_id   │     │  │    name      │
--   │    email UQ  │  1:N   │    status    │     │  │    price     │
--   └──────────────┘        └──────┬───────┘     │  │ FK category  │
--                                  │ 1:N         │  └──────────────┘
--                                  ▼             │ N:1
--                           ┌──────────────┐     │
--                           │ order_items  │     │
--                           ├──────────────┤     │
--                           │ FK order_id  │     │
--                           │ FK product_id│>────┘
--                           │    quantity  │
--                           │    unit_price│  ◄ السعر وقت الشراء
--                           └──────────────┘
--
--   1:N = واحد لكثير (مستخدم واحد له طلبات كثيرة)
--   N:M = كثير لكثير (طلبات ومنتجات) ← تحتاج جدول وسيط (order_items)
-- ---------------------------------------------------------

DROP TABLE IF EXISTS order_items, orders, products, categories, users;

CREATE TABLE users (
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    email       VARCHAR(255) NOT NULL,
    city        VARCHAR(50)  NOT NULL,
    deleted_at  TIMESTAMP NULL DEFAULT NULL,
    created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_users_email UNIQUE (email)
);

CREATE TABLE categories (
    id    INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name  VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE products (
    id           INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    category_id  INT UNSIGNED NOT NULL,
    name         VARCHAR(150) NOT NULL,
    price        DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    stock        INT UNSIGNED NOT NULL DEFAULT 0,
    FOREIGN KEY (category_id) REFERENCES categories(id)
);

CREATE TABLE orders (
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id     INT UNSIGNED NOT NULL,
    status      ENUM('pending', 'paid', 'shipped', 'cancelled') NOT NULL DEFAULT 'pending',
    created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE order_items (
    order_id    INT UNSIGNED NOT NULL,
    product_id  INT UNSIGNED NOT NULL,
    quantity    INT UNSIGNED NOT NULL CHECK (quantity > 0),
    unit_price  DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (order_id, product_id),  -- مفتاح مركب: نفس المنتج ما يتكرر في نفس الطلب
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id)
);

INSERT INTO users (name, email, city) VALUES
    ('Ali',  'ali@example.com',  'Riyadh'),
    ('Sara', 'sara@example.com', 'Jeddah'),
    ('Omar', 'omar@example.com', 'Riyadh'),
    ('Noor', 'noor@example.com', 'Dammam');

INSERT INTO categories (name) VALUES ('Electronics'), ('Furniture'), ('Books');

INSERT INTO products (category_id, name, price, stock) VALUES
    (1, 'Laptop', 3500.00, 10),
    (1, 'Mouse', 75.00, 200),
    (1, 'Monitor', 1200.00, 15),
    (2, 'Desk', 900.00, 5),
    (2, 'Chair', 450.00, 0),
    (3, 'SQL Book', 120.00, 30);

INSERT INTO orders (user_id, status, created_at) VALUES
    (1, 'paid',      '2026-01-05 10:00:00'),
    (1, 'shipped',   '2026-02-10 12:00:00'),
    (2, 'paid',      '2026-02-11 09:30:00'),
    (2, 'cancelled', '2026-03-01 14:00:00'),
    (3, 'pending',   '2026-03-15 18:00:00');

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
    (1, 1, 1, 3500.00), (1, 2, 2, 75.00),
    (2, 6, 3, 120.00),
    (3, 3, 2, 1200.00), (3, 2, 1, 75.00),
    (4, 4, 1, 900.00),
    (5, 2, 4, 75.00);


-- ╭──────────────────────────────────────────────────────────────╮
-- │  02  ▸  أنواع JOIN بالرسم
-- ╰──────────────────────────────────────────────────────────────╯
--
--   INNER JOIN           LEFT JOIN            LEFT JOIN ... WHERE B IS NULL
--     ┌───┬───┬───┐        ┌───┬───┬───┐        ┌───┬───┬───┐
--     │ A │███│ B │        │███│███│ B │        │███│ ∩ │ B │
--     └───┴───┴───┘        └───┴───┴───┘        └───┴───┴───┘
--     المشترك بس           كل A + المشترك       A اللي ما لها شيء في B
--
-- المستخدمين اللي ما طلبوا أي شيء (Anti Join)
SELECT u.id, u.name
FROM users u
LEFT JOIN orders o ON o.user_id = u.id
WHERE o.id IS NULL;

-- نفس النتيجة بـ NOT EXISTS (غالبًا أوضح، والأداء متقارب في MySQL 8)
-- ⚠️ لا تستخدم NOT IN مع عمود ممكن يكون NULL: يرجع لك ولا نتيجة!
SELECT u.id, u.name
FROM users u
WHERE NOT EXISTS (SELECT 1 FROM orders o WHERE o.user_id = u.id);


-- ╭──────────────────────────────────────────────────────────────╮
-- │  03  ▸  Subqueries و CTE
-- ╰──────────────────────────────────────────────────────────────╯
-- المنتجات اللي سعرها أعلى من متوسط تصنيفها (Correlated Subquery)
SELECT p.name, p.price
FROM products p
WHERE p.price > (
    SELECT AVG(p2.price) FROM products p2 WHERE p2.category_id = p.category_id
);

-- CTE (WITH): تقسم الاستعلام المعقد لخطوات بأسماء
--
--   order_totals ──► user_totals ──► النتيجة النهائية
--
WITH order_totals AS (
    SELECT o.id AS order_id, o.user_id, SUM(oi.quantity * oi.unit_price) AS total
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.id
    WHERE o.status <> 'cancelled'
    GROUP BY o.id, o.user_id
),
user_totals AS (
    SELECT user_id, COUNT(*) AS orders_count, SUM(total) AS spent
    FROM order_totals
    GROUP BY user_id
)
SELECT u.name, ut.orders_count, ut.spent
FROM user_totals ut
JOIN users u ON u.id = ut.user_id
ORDER BY ut.spent DESC;


-- ╭──────────────────────────────────────────────────────────────╮
-- │  04  ▸  Window Functions: تحسب على مجموعة بدون ما تدمج الصفوف
-- ╰──────────────────────────────────────────────────────────────╯
--
--   GROUP BY:   ████ ████ ████   ──►   ■  (صف واحد لكل مجموعة)
--   WINDOW:     ████ ████ ████   ──►   ████ ████ ████  (كل الصفوف + الحساب)
--
-- ترتيب المنتجات داخل كل تصنيف حسب السعر
SELECT
    c.name AS category,
    p.name,
    p.price,
    RANK()       OVER (PARTITION BY p.category_id ORDER BY p.price DESC) AS rank_in_category,
    AVG(p.price) OVER (PARTITION BY p.category_id)                       AS category_avg
FROM products p
JOIN categories c ON c.id = p.category_id;

-- أغلى منتج في كل تصنيف (Top-N per group)
WITH ranked AS (
    SELECT p.*, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) AS rn
    FROM products p
)
SELECT category_id, name, price FROM ranked WHERE rn = 1;

-- مجموع تراكمي للمبيعات حسب التاريخ + الفرق عن آخر يوم قبله فيه مبيعات (الصف اللي قبله)
WITH daily AS (
    SELECT DATE(o.created_at) AS day, SUM(oi.quantity * oi.unit_price) AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.id
    WHERE o.status IN ('paid', 'shipped')
    GROUP BY DATE(o.created_at)
)
SELECT
    day,
    revenue,
    SUM(revenue) OVER (ORDER BY day)            AS running_total,
    revenue - LAG(revenue) OVER (ORDER BY day)  AS change_from_previous
FROM daily;


-- ╭──────────────────────────────────────────────────────────────╮
-- │  05  ▸  Indexes المركبة و EXPLAIN
-- ╰──────────────────────────────────────────────────────────────╯
--
--   Index على (user_id, status, created_at)
--   زي دليل الهاتف مرتب: المدينة ← اسم العائلة ← الاسم الأول
--
--   ┌─────────┬──────────┬─────────────┐
--   │ user_id │  status  │ created_at  │
--   ├─────────┼──────────┼─────────────┤
--   │   1     │  paid    │ 2026-01-05  │
--   │   1     │  shipped │ 2026-02-10  │
--   │   2     │  paid    │ 2026-02-11  │
--   └─────────┴──────────┴─────────────┘
--
--   قاعدة "من اليسار" (Leftmost Prefix):
--     WHERE user_id = 1                          ✅ يستخدم الـ Index
--     WHERE user_id = 1 AND status = 'paid'      ✅
--     WHERE status = 'paid'                      ❌ تخطيت أول عمود (غالبًا ما يستفيد من الـ Index)
--
--   ⚠️ دوال على العمود تقتل الـ Index:
--     ❌ WHERE YEAR(created_at) = 2026
--     ✅ WHERE created_at >= '2026-01-01' AND created_at < '2027-01-01'
--
CREATE INDEX idx_orders_user_status_date ON orders (user_id, status, created_at);
CREATE INDEX idx_products_category_price ON products (category_id, price);

-- EXPLAIN: يوريك كيف قاعدة البيانات بتنفذ الاستعلام
--   type = ALL       ❌ يقرا الجدول كامل (Full Scan)
--   type = ref/range ✅ يستخدم Index
--   rows             كم صف تتوقع تقراه (كل ما قل أحسن)
EXPLAIN SELECT id, status FROM orders WHERE user_id = 1 AND status = 'paid';


-- ╭──────────────────────────────────────────────────────────────╮
-- │  06  ▸  UPSERT: أضف، ولو موجود حدّث
-- ╰──────────────────────────────────────────────────────────────╯
INSERT INTO users (name, email, city)
VALUES ('Ali Updated', 'ali@example.com', 'Riyadh')
ON DUPLICATE KEY UPDATE name = VALUES(name), city = VALUES(city);
-- ملاحظة: VALUES() قديمة في MySQL 8.0.20+ وتطلع تحذير بس تشتغل
-- البديل الجديد في MySQL: ... VALUES (...) AS new ON DUPLICATE KEY UPDATE name = new.name
-- (البديل ما يشتغل في MariaDB، عشان كذا خليناها)

-- ⚠️ ❌ لا تسوي: SELECT تشيك إذا موجود، وبعدين INSERT
--    بين الخطوتين ممكن طلب ثاني يضيف نفس الشيء = تكرار أو خطأ


-- ╭──────────────────────────────────────────────────────────────╮
-- │  07  ▸  Pagination الصح
-- ╰──────────────────────────────────────────────────────────────╯
--
--   OFFSET:   LIMIT 20 OFFSET 100000
--             ◄──── يقرا 100,000 صف ويرميهم ────► ثم 20
--             ❌ يبطأ كل ما تروح لصفحة أبعد
--
--   Keyset:   WHERE id > (آخر id شفته) LIMIT 20
--             ──► يقفز على طول بالـ Index ثم 20
--             ✅ نفس السرعة في أي صفحة
--
SELECT id, name, price FROM products ORDER BY id LIMIT 3 OFFSET 3;   -- بسيط، للجداول الصغيرة
SELECT id, name, price FROM products WHERE id > 3 ORDER BY id LIMIT 3; -- للجداول الكبيرة


-- ╭──────────────────────────────────────────────────────────────╮
-- │  08  ▸  Race Conditions و Locks
-- ╰──────────────────────────────────────────────────────────────╯
--
--   بدون قفل (مشكلة):
--   Request A: يقرا stock = 1  ─┐
--   Request B: يقرا stock = 1  ─┤  الاثنين شافوا 1
--   Request A: يبيع، يكتب stock = 0  │
--   Request B: يبيع، يكتب stock = 0  ┘  ❌ انباع منتجين والمخزون كان واحد (Lost Update)
--
--   الحل 1 (الأبسط): خل الشرط داخل UPDATE نفسه (عملية ذرية)
--     UPDATE products SET stock = stock - 1 WHERE id = ? AND stock >= 1;
--     وشيك عدد الصفوف المتأثرة: 0 = خلص المخزون
--
--   الحل 2: SELECT ... FOR UPDATE يقفل الصف لين تخلص الـ Transaction
--
START TRANSACTION;

SELECT stock FROM products WHERE id = 1 FOR UPDATE;  -- أي أحد ثاني يبي يعدل هذا الصف أو يقفله ينتظر (الـ SELECT العادي ما ينتظر)

UPDATE products SET stock = stock - 1 WHERE id = 1 AND stock >= 1;
INSERT INTO orders (user_id, status) VALUES (4, 'pending');
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
SELECT LAST_INSERT_ID(), id, 1, price FROM products WHERE id = 1;

COMMIT;

-- ⚠️ خل الـ Transaction قصيرة: لا تسوي فيها طلبات API أو انتظار مستخدم
-- ⚠️ اقفل الصفوف بنفس الترتيب دايمًا عشان تقلل الـ Deadlock،
--    ولو صار (خطأ 1213) خل كودك يعيد المحاولة


-- ╭──────────────────────────────────────────────────────────────╮
-- │  09  ▸  Views و Soft Delete
-- ╰──────────────────────────────────────────────────────────────╯
-- Soft Delete: بدل ما تحذف، تحط وقت الحذف وتخفيه
UPDATE users SET deleted_at = CURRENT_TIMESTAMP WHERE id = 4;

-- View: استعلام محفوظ تستخدمه كأنه جدول
-- كذا ما تنسى شرط deleted_at IS NULL في كل مكان
CREATE OR REPLACE VIEW active_users AS
SELECT id, name, email, city FROM users WHERE deleted_at IS NULL;

SELECT * FROM active_users;

-- تقرير جاهز
CREATE OR REPLACE VIEW product_sales AS
SELECT
    p.id,
    p.name,
    -- ⚠️ نحسب بس البنود اللي طلبها مدفوع أو انشحن، وإلا الملغي بيندخل في المبيعات
    COALESCE(SUM(CASE WHEN o.id IS NOT NULL THEN oi.quantity END), 0)                 AS units_sold,
    COALESCE(SUM(CASE WHEN o.id IS NOT NULL THEN oi.quantity * oi.unit_price END), 0) AS revenue
FROM products p
LEFT JOIN order_items oi ON oi.product_id = p.id
LEFT JOIN orders o ON o.id = oi.order_id AND o.status IN ('paid', 'shipped')
GROUP BY p.id, p.name;

SELECT * FROM product_sales ORDER BY revenue DESC;


-- ╭──────────────────────────────────────────────────────────────╮
-- │  10  ▸  CASE: شروط داخل الاستعلام
-- ╰──────────────────────────────────────────────────────────────╯
SELECT
    name,
    stock,
    CASE
        WHEN stock = 0  THEN 'Out of stock'
        WHEN stock < 10 THEN 'Low'
        ELSE 'Available'
    END AS availability
FROM products;

-- عد مشروط (Pivot بسيط): كم طلب من كل حالة لكل مستخدم
SELECT
    u.name,
    SUM(o.status = 'paid')      AS paid,
    SUM(o.status = 'shipped')   AS shipped,
    SUM(o.status = 'cancelled') AS cancelled
FROM users u
LEFT JOIN orders o ON o.user_id = u.id
GROUP BY u.id, u.name;


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  ┃  ⚠️  أغلاط المستوى المتوسط
--
--  1. قوائم داخل خانة وحدة ("1,2,3")      -> جدول وسيط
--  2. ما تحفظ السعر وقت الشراء             -> unit_price في order_items
--  3. دالة على عمود في WHERE               -> الـ Index ما يشتغل
--  4. Index مركب بترتيب غلط               -> Leftmost Prefix
--  5. NOT IN مع قيم NULL                   -> NOT EXISTS
--  6. SELECT ثم INSERT لمنع التكرار        -> UNIQUE + UPSERT
--  7. OFFSET كبير                          -> Keyset Pagination
--  8. تقرا ثم تعدل بدون قفل               -> UPDATE مشروط أو FOR UPDATE
--  9. Transaction طويلة فيها طلبات خارجية -> Locks و Deadlocks
--  10. ما تجرب EXPLAIN على الاستعلامات البطيئة
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
