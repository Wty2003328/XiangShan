/* Atomic operations test: exercises AMO and LR/SC instructions
 * Targets: coherence_and_consistency (AtomicsReplayUnit.scala, MainPipe.scala)
 */
#include <am.h>
#include <klib.h>

static volatile long shared_val;
static volatile int  shared_val32;

/* Force the compiler not to optimize these away */
#define AMOADD_D(addr, val) ({ \
    long result; \
    asm volatile("amoadd.d %0, %1, (%2)" : "=r"(result) : "r"((long)(val)), "r"(addr) : "memory"); \
    result; \
})

#define AMOSWAP_D(addr, val) ({ \
    long result; \
    asm volatile("amoswap.d %0, %1, (%2)" : "=r"(result) : "r"((long)(val)), "r"(addr) : "memory"); \
    result; \
})

#define AMOAND_D(addr, val) ({ \
    long result; \
    asm volatile("amoand.d %0, %1, (%2)" : "=r"(result) : "r"((long)(val)), "r"(addr) : "memory"); \
    result; \
})

#define AMOOR_D(addr, val) ({ \
    long result; \
    asm volatile("amoor.d %0, %1, (%2)" : "=r"(result) : "r"((long)(val)), "r"(addr) : "memory"); \
    result; \
})

#define AMOXOR_D(addr, val) ({ \
    long result; \
    asm volatile("amoxor.d %0, %1, (%2)" : "=r"(result) : "r"((long)(val)), "r"(addr) : "memory"); \
    result; \
})

#define AMOMAX_D(addr, val) ({ \
    long result; \
    asm volatile("amomax.d %0, %1, (%2)" : "=r"(result) : "r"((long)(val)), "r"(addr) : "memory"); \
    result; \
})

#define AMOMIN_D(addr, val) ({ \
    long result; \
    asm volatile("amomin.d %0, %1, (%2)" : "=r"(result) : "r"((long)(val)), "r"(addr) : "memory"); \
    result; \
})

/* 32-bit AMO variants */
#define AMOADD_W(addr, val) ({ \
    int result; \
    asm volatile("amoadd.w %0, %1, (%2)" : "=r"(result) : "r"((int)(val)), "r"(addr) : "memory"); \
    result; \
})

#define AMOSWAP_W(addr, val) ({ \
    int result; \
    asm volatile("amoswap.w %0, %1, (%2)" : "=r"(result) : "r"((int)(val)), "r"(addr) : "memory"); \
    result; \
})

/* LR/SC pair */
static inline int lr_sc_test(volatile long *addr, long expected, long newval) {
    long tmp;
    int sc_result;
    asm volatile(
        "lr.d %0, (%2)\n\t"
        "sc.d %1, %3, (%2)\n\t"
        : "=&r"(tmp), "=&r"(sc_result)
        : "r"(addr), "r"(newval)
        : "memory"
    );
    return sc_result;  /* 0 = success */
}

int main() {
    long old;
    int errors = 0;

    /* === amoadd.d === */
    shared_val = 100;
    old = AMOADD_D(&shared_val, 50);
    if (old != 100 || shared_val != 150) {
        printf("FAIL amoadd.d: old=%ld val=%ld\n", old, shared_val);
        errors++;
    }

    /* === amoswap.d === */
    shared_val = 42;
    old = AMOSWAP_D(&shared_val, 99);
    if (old != 42 || shared_val != 99) {
        printf("FAIL amoswap.d: old=%ld val=%ld\n", old, shared_val);
        errors++;
    }

    /* === amoand.d === */
    shared_val = 0xFF;
    old = AMOAND_D(&shared_val, 0x0F);
    if (old != 0xFF || shared_val != 0x0F) {
        printf("FAIL amoand.d: old=%ld val=%ld\n", old, shared_val);
        errors++;
    }

    /* === amoor.d === */
    shared_val = 0x0F;
    old = AMOOR_D(&shared_val, 0xF0);
    if (old != 0x0F || shared_val != 0xFF) {
        printf("FAIL amoor.d: old=%ld val=%ld\n", old, shared_val);
        errors++;
    }

    /* === amoxor.d === */
    shared_val = 0xFF;
    old = AMOXOR_D(&shared_val, 0xAA);
    if (old != 0xFF || shared_val != 0x55) {
        printf("FAIL amoxor.d: old=%ld val=%ld\n", old, shared_val);
        errors++;
    }

    /* === amomax.d === */
    shared_val = 10;
    old = AMOMAX_D(&shared_val, 20);
    if (old != 10 || shared_val != 20) {
        printf("FAIL amomax.d: old=%ld val=%ld\n", old, shared_val);
        errors++;
    }

    /* === amomin.d === */
    shared_val = 10;
    old = AMOMIN_D(&shared_val, 20);
    if (old != 10 || shared_val != 10) {
        printf("FAIL amomin.d: old=%ld val=%ld\n", old, shared_val);
        errors++;
    }

    /* === amoadd.w (32-bit) === */
    shared_val32 = 100;
    int old32 = AMOADD_W(&shared_val32, 50);
    if (old32 != 100 || shared_val32 != 150) {
        printf("FAIL amoadd.w: old=%d val=%d\n", old32, shared_val32);
        errors++;
    }

    /* === LR/SC === */
    shared_val = 42;
    int sc = lr_sc_test(&shared_val, 42, 99);
    /* sc=0 means success */
    if (shared_val != 99 && sc != 0) {
        printf("FAIL lr/sc: sc=%d val=%ld\n", sc, shared_val);
        errors++;
    }

    /* === Repeated LR/SC (stress) === */
    shared_val = 0;
    for (int i = 0; i < 100; i++) {
        long tmp;
        int sc_res;
        do {
            asm volatile(
                "lr.d %0, (%2)\n\t"
                "addi %0, %0, 1\n\t"
                "sc.d %1, %0, (%2)\n\t"
                : "=&r"(tmp), "=&r"(sc_res)
                : "r"(&shared_val)
                : "memory"
            );
        } while (sc_res != 0);
    }
    if (shared_val != 100) {
        printf("FAIL lr/sc stress: val=%ld expected 100\n", shared_val);
        errors++;
    }

    if (errors > 0) {
        printf("Atomic test FAILED: %d errors\n", errors);
        _halt(1);
    }

    printf("Atomic test PASSED\n");
    _halt(0);
    return 0;
}
