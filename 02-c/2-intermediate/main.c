/* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 *
 * ╔════════════════════════════════════════════════════════════════════════════╗
 * ║                                                                            ║
 * ║                                    ████                                    ║
 * ║                                   █                                        ║
 * ║                                   █                                        ║
 * ║                                   █                                        ║
 * ║                                    ████                                    ║
 * ║                                                                            ║
 * ║                          LEVEL 2  ·  INTERMEDIATE                          ║
 * ║                              ▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰                              ║
 * ╚════════════════════════════════════════════════════════════════════════════╝
 *
 *    ▌ C — دليل المتوسط
 *
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 *  ◆ لمين هذا الملف؟
 *  لك إذا فهمت المتغيرات والمؤشرات البسيطة و malloc/free،
 *  وتبي تبني هياكل بيانات حقيقية وتفهم الذاكرة صح.
 *
 *  ◆ وش بتتعلم؟
 *    Stack و Heap، مصفوفة تكبر لحالها (realloc)
 *    Linked List، مؤشر لمؤشر، Function Pointers
 *    enum و Bit Flags، الملفات، تقسيم المشروع لملفات .h و .c
 *
 *  ◆ كيف تشغله؟
 *    gcc main.c -Wall -Wextra -fsanitize=address -g -o main
 *    ./main
 *    (-fsanitize=address يمسك لك أغلاط الذاكرة وقت التشغيل
 *     يشتغل على لينكس وماك، وعلى ويندوز استخدم clang أو MSVC بـ /fsanitize=address)
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

/* ╭──────────────────────────────────────────────────────────────╮
 * │  01  ▸  Stack و Heap: وين تعيش متغيراتك؟
 * ╰──────────────────────────────────────────────────────────────╯
 *
 *   الذاكرة
 *   ┌──────────────────────────────┐  عناوين عالية
 *   │  STACK  ▼ (ينمو لتحت)        │  متغيرات الدوال المحلية
 *   │  int x = 5;                  │  تنحذف تلقائي لما الدالة تخلص
 *   │                              │  سريع بس صغير
 *   ├──────────────────────────────┤
 *   │           (فاضي)             │
 *   ├──────────────────────────────┤
 *   │  HEAP   ▲ (ينمو لفوق)        │  اللي تحجزه بـ malloc
 *   │  malloc(...)                 │  يعيش لين تسوي free
 *   ├──────────────────────────────┤
 *   │  DATA   (متغيرات global)     │
 *   ├──────────────────────────────┤
 *   │  CODE   (كود البرنامج)       │  عناوين منخفضة
 *   └──────────────────────────────┘
 *
 *  ⚠️ لا ترجع مؤشر لمتغير على الـ Stack من دالة:
 *     int *bad(void) { int x = 5; return &x; }   x ماتت!
 * --------------------------------------------------------- */

/* ╭──────────────────────────────────────────────────────────────╮
 * │  02  ▸  enum و Bit Flags
 * ╰──────────────────────────────────────────────────────────────╯ */
typedef enum {
    ROLE_GUEST,
    ROLE_USER,
    ROLE_ADMIN
} Role;

/*  Bit Flags: كل صلاحية "بت" واحد، وتجمعهم في رقم واحد
 *
 *    bit:   3     2     1     0
 *         ┌─────┬─────┬─────┬─────┐
 *         │  0  │  1  │  0  │  1  │  = READ | DELETE
 *         └─────┴─────┴─────┴─────┘
 *          ADMIN DELETE WRITE READ
 */
enum {
    PERM_READ   = 1 << 0,
    PERM_WRITE  = 1 << 1,
    PERM_DELETE = 1 << 2,
    PERM_ADMIN  = 1 << 3
};

/* ╭──────────────────────────────────────────────────────────────╮
 * │  03  ▸  typedef: اسم مختصر للأنواع
 * ╰──────────────────────────────────────────────────────────────╯ */
typedef struct {
    int id;
    char name[32];
    Role role;
    unsigned permissions;
} User;

/* ╭──────────────────────────────────────────────────────────────╮
 * │  04  ▸  مصفوفة تكبر لحالها (Dynamic Array)
 * ╰──────────────────────────────────────────────────────────────╯
 *
 *   count = 3, capacity = 4
 *   ┌────┬────┬────┬────┐
 *   │ 10 │ 20 │ 30 │    │
 *   └────┴────┴────┴────┘
 *   لما تمتلي: نضاعف السعة (4 -> 8) ونطلبها من realloc،
 *   وهو يكبّر المكان في محله، أو ينقل البيانات لمكان جديد لو احتاج
 * --------------------------------------------------------- */
typedef struct {
    int *data;
    size_t count;
    size_t capacity;
} IntArray;

bool int_array_push(IntArray *arr, int value)
{
    if (arr->count == arr->capacity) {
        size_t new_capacity = arr->capacity == 0 ? 4 : arr->capacity * 2;

        /* ⚠️ لا تكتب arr->data = realloc(arr->data, ...)
         * لو فشل realloc يرجع NULL، وتضيع المؤشر القديم = تسريب ذاكرة
         * ✅ خزنه في متغير مؤقت أول */
        int *tmp = realloc(arr->data, new_capacity * sizeof *tmp);
        if (tmp == NULL) {
            return false;
        }
        arr->data = tmp;
        arr->capacity = new_capacity;
    }
    arr->data[arr->count++] = value;
    return true;
}

void int_array_free(IntArray *arr)
{
    free(arr->data);
    arr->data = NULL;
    arr->count = 0;
    arr->capacity = 0;
}

/* ╭──────────────────────────────────────────────────────────────╮
 * │  05  ▸  Linked List
 * ╰──────────────────────────────────────────────────────────────╯
 *
 *   head
 *    │
 *    ▼
 *  ┌─────┬───┐    ┌─────┬───┐    ┌─────┬──────┐
 *  │  3  │ ●─┼───►│  7  │ ●─┼───►│  9  │ NULL │
 *  └─────┴───┘    └─────┴───┘    └─────┴──────┘
 *   value next
 *
 *  كل عقدة (Node) فيها قيمة + مؤشر للي بعدها
 * --------------------------------------------------------- */
typedef struct Node {
    int value;
    struct Node *next;
} Node;

/* Node **head = مؤشر لمؤشر
 * نحتاجه لأننا نبي نغير الـ head نفسه، مو بس اللي يأشر له
 *
 *   head (Node** داخل الدالة) ──► head حق main (Node*) ──► [Node]
 */
bool list_push_front(Node **head, int value)
{
    Node *node = malloc(sizeof *node);
    if (node == NULL) {
        return false;
    }
    node->value = value;
    node->next = *head;
    *head = node;
    return true;
}

void list_print(const Node *head)
{
    for (const Node *cur = head; cur != NULL; cur = cur->next) {
        printf("%d -> ", cur->value);
    }
    printf("NULL\n");
}

void list_free(Node **head)
{
    Node *cur = *head;
    while (cur != NULL) {
        Node *next = cur->next; /* ⚠️ احفظ next قبل free، بعدها ما تقدر توصل له */
        free(cur);
        cur = next;
    }
    *head = NULL;
}

/* ╭──────────────────────────────────────────────────────────────╮
 * │  06  ▸  Function Pointers: تمرر دالة كأنها متغير
 * ╰──────────────────────────────────────────────────────────────╯ */
typedef int (*Operation)(int, int);

int op_add(int a, int b) { return a + b; }
int op_mul(int a, int b) { return a * b; }

int apply(Operation op, int a, int b)
{
    return op(a, b);
}

/* qsort تحتاج دالة مقارنة: سالب = a قبل، موجب = b قبل */
int compare_ints(const void *a, const void *b)
{
    int x = *(const int *)a;
    int y = *(const int *)b;
    return (x > y) - (x < y); /* ⚠️ لا تكتب x - y، ممكن يصير overflow */
}

/* ╭──────────────────────────────────────────────────────────────╮
 * │  07  ▸  الملفات
 * ╰──────────────────────────────────────────────────────────────╯ */
bool save_users(const char *path, const User *users, size_t count)
{
    FILE *file = fopen(path, "w");
    if (file == NULL) {
        perror("fopen");
        return false;
    }

    for (size_t i = 0; i < count; i++) {
        fprintf(file, "%d,%s,%d\n", users[i].id, users[i].name, users[i].role);
    }

    /* ⚠️ دايم سكّر الملف */
    fclose(file);
    return true;
}

void print_file(const char *path)
{
    FILE *file = fopen(path, "r");
    if (file == NULL) {
        perror("fopen");
        return;
    }

    char line[128];
    while (fgets(line, sizeof line, file) != NULL) {
        printf("  %s", line);
    }
    fclose(file);
}

/* ╭──────────────────────────────────────────────────────────────╮
 * │  08  ▸  const مع المؤشرات
 * ╰──────────────────────────────────────────────────────────────╯
 *   const int *p        القيمة ثابتة، المؤشر يتحرك
 *   int *const p        المؤشر ثابت، القيمة تتغير
 *   const int *const p  الاثنين ثابتين
 * --------------------------------------------------------- */

int main(void)
{
    /* Dynamic Array */
    IntArray arr = {0};
    for (int i = 1; i <= 10; i++) {
        if (!int_array_push(&arr, i * 10)) {
            fprintf(stderr, "Out of memory\n");
            int_array_free(&arr);
            return 1;
        }
    }
    printf("count=%zu capacity=%zu last=%d\n", arr.count, arr.capacity, arr.data[arr.count - 1]);
    int_array_free(&arr);

    /* Linked List */
    Node *head = NULL;
    list_push_front(&head, 9);
    list_push_front(&head, 7);
    list_push_front(&head, 3);
    list_print(head);
    list_free(&head);

    /* Function Pointers */
    printf("apply add = %d, apply mul = %d\n", apply(op_add, 3, 4), apply(op_mul, 3, 4));

    int nums[] = {5, 1, 9, 3, 7};
    size_t n = sizeof nums / sizeof nums[0];
    qsort(nums, n, sizeof nums[0], compare_ints);
    for (size_t i = 0; i < n; i++) {
        printf("%d ", nums[i]);
    }
    printf("\n");

    /* Bit Flags */
    User admin = {1, "Sara", ROLE_ADMIN, PERM_READ | PERM_WRITE | PERM_DELETE};
    if (admin.permissions & PERM_DELETE) {
        printf("%s can delete\n", admin.name);
    }
    admin.permissions &= ~PERM_DELETE; /* شيل صلاحية */
    printf("can delete now? %s\n", (admin.permissions & PERM_DELETE) ? "yes" : "no");

    /* الملفات */
    User users[] = {
        {1, "Ali", ROLE_USER, PERM_READ},
        {2, "Sara", ROLE_ADMIN, PERM_READ | PERM_WRITE},
    };
    if (save_users("users.csv", users, 2)) {
        print_file("users.csv");
    }

    return 0;
}

/* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 *  تقسيم المشروع لملفات (لما يكبر):
 *
 *    project/
 *    ├── main.c          يستدعي الدوال
 *    ├── list.h          الإعلانات بس (وش الدوال الموجودة)
 *    └── list.c          الكود الفعلي
 *
 *    list.h:
 *      #ifndef LIST_H      ⚠️ Include Guard: يمنع التضمين مرتين
 *      #define LIST_H
 *      #include <stdbool.h>
 *      typedef struct Node Node;
 *      bool list_push_front(Node **head, int value);
 *      #endif
 *
 *    gcc main.c list.c -o app
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 *
 *  ┃  ⚠️  أغلاط المستوى المتوسط
 *
 *  1. ptr = realloc(ptr, ...)           -> تضيع الأصل لو فشل
 *  2. free للعقدة قبل ما تحفظ next
 *  3. ترجع عنوان متغير على الـ Stack
 *  4. x - y في دوال المقارنة            -> overflow
 *  5. تنسى fclose أو free في مسارات الخطأ
 *  6. ملف .h بدون Include Guard
 *  7. ما تستخدم -fsanitize=address وقت التطوير
 *  8. تحرر نفس المؤشر مرتين (Double Free)
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
