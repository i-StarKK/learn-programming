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
-- ║                             LEVEL 1  ·  BASICS                             ║
-- ║                              ▰▰▰▰▰▰▰▰▱▱▱▱▱▱▱▱                              ║
-- ╚════════════════════════════════════════════════════════════════════════════╝
--
--    ▌ SQL / Database — دليل المبتدئ
--
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  ◆ وش هي؟
--  قاعدة البيانات = المكان اللي تحفظ فيه بيانات تطبيقك بشكل دائم.
--
--  ◆ نوعين:
--    SQL (علائقية): البيانات في جداول (صفوف وأعمدة)
--        MySQL, MariaDB, PostgreSQL, SQL Server, SQLite
--    NoSQL: بيانات بأشكال مرنة
--        MongoDB (مستندات JSON), Redis (مفتاح وقيمة)
--
--  هذا الملف مكتوب لـ MySQL / MariaDB
--  ◆ كيف تشغله؟
--    mysql -u root -p < database.sql
--    أو افتحه في برنامج مثل HeidiSQL أو DBeaver أو MySQL Workbench
--
--  ◆ المصطلحات:
--    Table       = جدول
--    Row         = صف (سجل واحد، مثلًا مستخدم واحد)
--    Column      = عمود (خاصية، مثلًا الإيميل)
--    Primary Key = قيمة فريدة لكل صف (غالبًا رقم)، ما تتكرر
--    Foreign Key = ربط صف بصف في جدول ثاني
--    Index       = فهرس يسرّع البحث (زي فهرس الكتاب)
--    Transaction = مجموعة عمليات: يا تتأكد كلها (COMMIT) يا تنلغي كلها (ROLLBACK)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


-- ╭──────────────────────────────────────────────────────────────╮
-- │  01  ▸  إنشاء قاعدة البيانات
-- ╰──────────────────────────────────────────────────────────────╯
-- utf8mb4: ⚠️ استخدمه دايمًا: utf8 القديمة ما تدعم الإيموجي، و latin1 تخرب العربي
CREATE DATABASE IF NOT EXISTS learning_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE learning_db;


-- ╭──────────────────────────────────────────────────────────────╮
-- │  02  ▸  إنشاء الجداول
-- ╰──────────────────────────────────────────────────────────────╯
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
    id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, -- رقم يزيد لحاله
    name          VARCHAR(100) NOT NULL,                   -- NOT NULL = إجباري
    email         VARCHAR(255) NOT NULL UNIQUE,            -- UNIQUE = ما يتكرر
    password_hash VARCHAR(255) NOT NULL,                   -- ⚠️ هاش (Hash): مو كلمة المرور نفسها، ومو تشفير، ما ينفك ويرجع
    age           TINYINT UNSIGNED,
    is_active     BOOLEAN NOT NULL DEFAULT TRUE,           -- DEFAULT = قيمة افتراضية
    created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (age IS NULL OR age BETWEEN 1 AND 120)
);

CREATE TABLE products (
    id       INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name     VARCHAR(150) NOT NULL,
    -- ⚠️ للفلوس استخدم DECIMAL مو FLOAT
    -- FLOAT يخزن تقريب: 0.1 + 0.2 ما تطلع 0.3 بالضبط
    price    DECIMAL(10, 2) NOT NULL,
    stock    INT UNSIGNED NOT NULL DEFAULT 0
);

CREATE TABLE orders (
    id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id    INT UNSIGNED NOT NULL,
    total      DECIMAL(10, 2) NOT NULL DEFAULT 0,
    status     ENUM('pending', 'paid', 'cancelled') NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Foreign Key: كل طلب لازم يكون لمستخدم موجود
    -- ON DELETE CASCADE: لو انحذف المستخدم تنحذف طلباته معه
    CONSTRAINT fk_orders_user
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE order_items (
    id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_id   INT UNSIGNED NOT NULL,
    product_id INT UNSIGNED NOT NULL,
    quantity   INT UNSIGNED NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- ╭──────────────────────────────────────────────────────────────╮
-- │  03  ▸  الفهارس (Index)
-- ╰──────────────────────────────────────────────────────────────╯
-- ⚠️ الأعمدة اللي تبحث فيها كثير (WHERE) أو تربط فيها (JOIN) سو لها Index،
-- خصوصًا اللي قيمها متنوعة (مثل name, email, user_id)
-- بدونه: قاعدة البيانات تدور صف صف = بطء شديد لما تكبر البيانات
-- (بس لا تبالغ: كل Index يبطئ الإضافة والتعديل شوي)
-- عمود فيه قيم قليلة (مثل status أو true/false) غالبًا ما يستفيد من Index لحاله
-- ملاحظة: UNIQUE و Foreign Key في MySQL يسوون Index تلقائي، فـ user_id هنا عنده Index أصلًا
-- كتبناه بنفسنا عشان نعطيه اسم واضح، و MySQL يستخدمه بدل اللي سواه تلقائي (ما يصير مكرر)
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_users_name ON users(name);


-- ╭──────────────────────────────────────────────────────────────╮
-- │  04  ▸  INSERT: إضافة بيانات
-- ╰──────────────────────────────────────────────────────────────╯
-- الهاش هنا مجرد مثال، في الحقيقة يطلع من bcrypt أو argon2 في كود التطبيق
INSERT INTO users (name, email, password_hash, age) VALUES
    ('Ahmed', 'ahmed@example.com', '$2b$12$exampleHashOnly111111111111111111111111111111', 25),
    ('Sara',  'sara@example.com',  '$2b$12$exampleHashOnly222222222222222222222222222222', 22),
    ('Omar',  'omar@example.com',  '$2b$12$exampleHashOnly333333333333333333333333333333', 17);

INSERT INTO products (name, price, stock) VALUES
    ('Laptop',   3500.00, 10),
    ('Mouse',      75.50, 100),
    ('Keyboard',  199.99, 50);

INSERT INTO orders (user_id, total, status) VALUES
    (1, 3575.50, 'paid'),
    (1,  199.99, 'pending'),
    (2,   75.50, 'paid');

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
    (1, 1, 1, 3500.00),
    (1, 2, 1,   75.50),
    (2, 3, 1,  199.99),
    (3, 2, 1,   75.50);


-- ╭──────────────────────────────────────────────────────────────╮
-- │  05  ▸  SELECT: جلب البيانات
-- ╰──────────────────────────────────────────────────────────────╯
-- ⚠️ لا تستخدم SELECT * في كود التطبيق، اطلب الأعمدة اللي تحتاجها بس
-- (أسرع، وما ترجع بالغلط بيانات حساسة مثل password_hash)
SELECT id, name, email FROM users;

-- WHERE: شرط
SELECT id, name FROM users WHERE age >= 18;

-- AND / OR / IN / BETWEEN
SELECT id, name FROM users WHERE age BETWEEN 18 AND 30 AND is_active = TRUE;
SELECT id, name FROM users WHERE id IN (1, 3);

-- LIKE: بحث جزئي، % = أي شيء
SELECT id, name FROM users WHERE name LIKE 'A%';   -- يبدأ بـ A

-- ⚠️ NULL ما ينقارن بـ = ، استخدم IS NULL
SELECT id, name FROM users WHERE age IS NULL;

-- ORDER BY: ترتيب | LIMIT: عدد محدد (مهم للصفحات Pagination)
SELECT id, name, age FROM users ORDER BY age DESC LIMIT 2;

-- دوال التجميع
SELECT
    COUNT(*)   AS users_count,
    AVG(age)   AS average_age,
    MAX(age)   AS oldest,
    MIN(age)   AS youngest
FROM users;


-- ╭──────────────────────────────────────────────────────────────╮
-- │  06  ▸  JOIN: ربط الجداول ببعض
-- ╰──────────────────────────────────────────────────────────────╯
--
--      users                 orders
--   ┌───────────┐         ┌──────────────┐
--   │ id │ name │         │ id │ user_id │
--   ├────┼──────┤         ├────┼─────────┤
--   │ 1  │ Ahmed│ ◄──────┬ │ 1  │    1    │
--   │    │      │        └ │ 2  │    1    │
--   │ 2  │ Sara │ ◄─────── │ 3  │    2    │
--   │ 3  │ Omar │   (ما له طلبات)
--   └────┴──────┘         └────┴─────────┘
--
--   INNER JOIN  ──►  Ahmed, Ahmed, Sara           (صف لكل طلب، اللي لهم تطابق بس)
--   LEFT JOIN   ──►  Ahmed, Ahmed, Sara, Omar     (Omar يطلع و order_id = NULL)
--
-- INNER JOIN: يرجع بس اللي لهم تطابق في الجدولين
-- (المستخدمين اللي عندهم طلبات)
SELECT u.name, o.id AS order_id, o.total, o.status
FROM users u
INNER JOIN orders o ON o.user_id = u.id;

-- LEFT JOIN: يرجع كل اللي في الجدول اليسار حتى لو ما لهم تطابق
-- (كل المستخدمين حتى اللي ما طلبوا شيء)
SELECT u.name, o.id AS order_id
FROM users u
LEFT JOIN orders o ON o.user_id = u.id;

-- GROUP BY: تجميع | HAVING: شرط على نتيجة التجميع (هنا: بس اللي صرفوا أكثر من 100)
-- كم طلب وكم صرف كل مستخدم
SELECT
    u.id,
    u.name,
    COUNT(o.id)               AS order_count,
    COALESCE(SUM(o.total), 0) AS total_spent  -- COALESCE: لو NULL حط 0
FROM users u
LEFT JOIN orders o ON o.user_id = u.id
GROUP BY u.id, u.name
HAVING total_spent > 100
ORDER BY total_spent DESC;

-- تفاصيل طلب مع المنتجات (ربط 3 جداول)
SELECT o.id AS order_id, p.name AS product, oi.quantity, oi.unit_price
FROM orders o
JOIN order_items oi ON oi.order_id = o.id
JOIN products p     ON p.id = oi.product_id
WHERE o.id = 1;


-- ╭──────────────────────────────────────────────────────────────╮
-- │  07  ▸  UPDATE: تعديل
-- ╰──────────────────────────────────────────────────────────────╯
-- 🚨 أخطر غلطة: UPDATE بدون WHERE = تعدل الجدول كله!
-- ❌ UPDATE users SET is_active = FALSE;
--
-- ✅ نصيحة: جرب الشرط بـ SELECT أول، إذا طلع اللي تبيه حوّله لـ UPDATE
SELECT id, name FROM users WHERE id = 3;
UPDATE users SET age = 18 WHERE id = 3;


-- ╭──────────────────────────────────────────────────────────────╮
-- │  08  ▸  DELETE: حذف
-- ╰──────────────────────────────────────────────────────────────╯
-- 🚨 نفس الشيء: DELETE بدون WHERE = تمسح الجدول كله!
-- ❌ DELETE FROM orders;
DELETE FROM orders WHERE status = 'cancelled';

-- ✅ في التطبيقات الحقيقية غالبًا ما تحذف فعليًا (Soft Delete)
-- تحط علامة إنه محذوف وتحتفظ بالبيانات:
UPDATE users SET is_active = FALSE WHERE id = 3;


-- ╭──────────────────────────────────────────────────────────────╮
-- │  09  ▸  Transaction: يا كلها تنجح يا كلها تنلغي
-- ╰──────────────────────────────────────────────────────────────╯
-- مثال: شراء منتج = ننقص المخزون + نسجل الطلب
-- لو وحدة فشلت والثانية نجحت = بيانات خربانة (بعنا شيء ما هو موجود!)
START TRANSACTION;

-- ⚠️ الشرط stock >= 1 يمنع إن المخزون ينزل تحت الصفر
-- حتى لو اثنين اشتروا بنفس اللحظة
UPDATE products SET stock = stock - 1 WHERE id = 1 AND stock >= 1;

INSERT INTO orders (user_id, total, status) VALUES (2, 3500.00, 'pending');
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
VALUES (LAST_INSERT_ID(), 1, 1, 3500.00);

-- لو كل شيء تمام
COMMIT;
-- ⚠️ MySQL ما يلغي تلقائي لو أمر فشل داخل الـ Transaction
-- لو صار خطأ (أو الـ UPDATE ما عدل ولا صف) لازم تسوي ROLLBACK; بنفسك من كودك


-- ╭──────────────────────────────────────────────────────────────╮
-- │  10  ▸  🚨 SQL Injection - أخطر ثغرة لازم تعرفها
-- ╰──────────────────────────────────────────────────────────────╯
-- هذا مو كود SQL تشغله، هذا شرح لكيف تكتب الاستعلام في تطبيقك
--
-- تخيل المستخدم كتب في خانة الإيميل:
--     ' OR '1'='1
--
-- ❌ لو كودك يدمج النص مباشرة:
--     "SELECT * FROM users WHERE email = '" + email + "'"
--   يصير الاستعلام:
--     SELECT * FROM users WHERE email = '' OR '1'='1'
--   = يرجع كل المستخدمين! وممكن أسوأ: يمسح الجداول كلها
--
-- ✅ الحل: Prepared Statements (استعلامات بمعاملات)
--   البيانات تنرسل لحالها وما تنفهم كأوامر أبد
--   ⚠️ الـ ? للقيم بس، أسماء الجداول والأعمدة و ASC/DESC ما تنفع فيها،
--      لها استخدم قائمة مسموحة (whitelist) في كودك:
--
--   JavaScript (mysql2):
--     db.execute("SELECT id, name FROM users WHERE email = ?", [email]);
--
--   Python (mysql-connector / PyMySQL):
--     cursor.execute("SELECT id, name FROM users WHERE email = %s", (email,))
--
--   C#:
--     cmd.CommandText = "SELECT id, name FROM users WHERE email = @email";
--     cmd.Parameters.AddWithValue("@email", email);
--
--   Java:
--     PreparedStatement ps = conn.prepareStatement("SELECT id, name FROM users WHERE email = ?");
--     ps.setString(1, email);
--
--   Lua (FiveM - oxmysql):
--     MySQL.query.await('SELECT id, name FROM users WHERE email = ?', { email })

-- نفس الفكرة داخل SQL نفسه:
PREPARE find_user FROM 'SELECT id, name FROM users WHERE email = ?';
SET @email = 'sara@example.com';
EXECUTE find_user USING @email;
DEALLOCATE PREPARE find_user;


-- ╭──────────────────────────────────────────────────────────────╮
-- │  11  ▸  مشكلة N+1 (تبطئ التطبيقات بشكل مرعب)
-- ╰──────────────────────────────────────────────────────────────╯
-- ❌ في الكود: تجيب المستخدمين، وبعدين لكل مستخدم تسوي استعلام لطلباته
--     100 مستخدم = 101 استعلام!
--
-- ✅ استعلام واحد بـ JOIN أو IN:
SELECT user_id, id, total
FROM orders
WHERE user_id IN (1, 2, 3);


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  ┃  ⚠️  ملخص الأغلاط اللي لازم ما تطيح فيها
--
--  1. 🚨 تدمج مدخلات المستخدم في الاستعلام -> Prepared Statements دايمًا
--  2. 🚨 UPDATE أو DELETE بدون WHERE       -> جرب الشرط بـ SELECT أول
--  3. 🚨 كلمات المرور كنص عادي             -> bcrypt أو argon2
--  4. SELECT * في الكود                    -> حدد الأعمدة
--  5. ما تسوي Index للأعمدة اللي تبحث فيها
--  6. N+1: استعلام داخل لوب               -> JOIN أو IN
--  7. FLOAT للفلوس                         -> DECIMAL
--  8. عمليات مرتبطة بدون Transaction
--  9. = NULL                               -> IS NULL
--  10. ما تاخذ نسخة احتياطية (Backup)
--  11. تعطي التطبيق صلاحيات root           -> أقل صلاحيات يحتاجها
--  12. تنسى utf8mb4                         -> الإيموجي يخرب (والعربي مع latin1)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
