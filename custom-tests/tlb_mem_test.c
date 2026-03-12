/* TLB and memory stress test: exercises page walks and cache hierarchy
 * Targets: virtual_memory_and_translation (TLB.scala, TLBStorage.scala, PageTableCache.scala)
 *          cache_architecture_and_policies (DCacheWrapper.scala, ICache.scala)
 *          coherence_and_consistency (MissQueue.scala, RefillPipe.scala)
 */
#include <am.h>
#include <klib.h>

/* Large arrays to force many different cache lines and pages */
#define ARRAY_SIZE (8 * 1024)    /* 8K entries = 64KB for long */
#define STRIDE_PAGES 512         /* stride in longs to cross pages (4KB/8=512) */

static volatile long big_array[ARRAY_SIZE];
static volatile long results[32];

int main() {
    int errors = 0;
    long sum;

    /* === Test 1: Sequential memory access (cache-friendly) === */
    /* Exercises: DCache, L2Cache, cache line fill, prefetcher */
    for (int i = 0; i < ARRAY_SIZE; i++) {
        big_array[i] = i;
    }
    sum = 0;
    for (int i = 0; i < ARRAY_SIZE; i++) {
        sum += big_array[i];
    }
    results[0] = sum;
    long expected = (long)(ARRAY_SIZE - 1) * ARRAY_SIZE / 2;
    if (sum != expected) {
        printf("FAIL seq: sum=%ld expected=%ld\n", sum, expected);
        errors++;
    }

    /* === Test 2: Strided access across pages (TLB stress) === */
    /* Each access hits a different page, forcing TLB misses */
    sum = 0;
    for (int i = 0; i < ARRAY_SIZE; i += STRIDE_PAGES) {
        sum += big_array[i];
    }
    results[1] = sum;

    /* === Test 3: Random-like access pattern (cache thrashing) === */
    /* Pseudo-random stride to stress cache replacement and TLB */
    sum = 0;
    int idx = 0;
    for (int i = 0; i < 10000; i++) {
        idx = (idx + 4099) % ARRAY_SIZE;  /* prime stride */
        sum += big_array[idx];
    }
    results[2] = sum;

    /* === Test 4: Write-read with different strides === */
    /* Exercises store buffer, write-back, cache coherence */
    for (int i = 0; i < ARRAY_SIZE; i += 8) {
        big_array[i] = i * 3 + 7;
    }
    sum = 0;
    for (int i = 0; i < ARRAY_SIZE; i += 8) {
        sum += big_array[i];
        if (big_array[i] != i * 3 + 7) {
            printf("FAIL w/r stride: i=%d got=%ld expected=%ld\n",
                   i, big_array[i], (long)(i * 3 + 7));
            errors++;
            if (errors > 5) break;
        }
    }
    results[3] = sum;

    /* === Test 5: Interleaved read/write (store-to-load forwarding) === */
    for (int i = 0; i < 1000; i++) {
        big_array[i] = i + 1;
        long v = big_array[i];  /* should get i+1 via store forwarding */
        if (v != i + 1) {
            printf("FAIL st-fwd: i=%d got=%ld\n", i, v);
            errors++;
            break;
        }
    }

    /* === Test 6: Byte/halfword/word access (unaligned within cacheline) === */
    volatile char *byte_ptr = (volatile char *)&big_array[0];
    volatile short *half_ptr = (volatile short *)&big_array[0];
    volatile int *word_ptr = (volatile int *)&big_array[0];

    big_array[0] = 0x0102030405060708L;
    /* Read back as different sizes */
    char b = byte_ptr[0];
    short h = half_ptr[0];
    int w = word_ptr[0];
    results[4] = (long)b;
    results[5] = (long)h;
    results[6] = (long)w;

    /* === Test 7: Multiple pages sequential then reverse === */
    /* Forward fill */
    for (int p = 0; p < 64; p++) {
        int base = p * STRIDE_PAGES;
        if (base < ARRAY_SIZE) {
            big_array[base] = p * 1000;
        }
    }
    /* Reverse read (different TLB access pattern) */
    sum = 0;
    for (int p = 63; p >= 0; p--) {
        int base = p * STRIDE_PAGES;
        if (base < ARRAY_SIZE) {
            sum += big_array[base];
        }
    }
    results[7] = sum;
    /* Expected: pages 0..15 fit (p*512 < 8192), sum = 15*16/2*1000 = 120000 */
    if (sum != 120000) {
        printf("FAIL page reverse: sum=%ld expected=120000\n", sum);
        errors++;
    }

    if (errors > 0) {
        printf("TLB/mem test FAILED: %d errors\n", errors);
        _halt(1);
    }

    printf("TLB/mem test PASSED: seq=%ld stride=%ld random=%ld\n",
           results[0], results[1], results[2]);
    _halt(0);
    return 0;
}
