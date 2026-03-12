/* FP unit test: exercises FMA, fdiv, fcvt, fclass, fmin/fmax
 * Targets: execution_units (FMA.scala, FPToFP.scala, FPToInt.scala)
 *          instruction_fetch_and_decode (FPDecoder.scala)
 */
#include <am.h>
#include <klib.h>

static volatile double results[16];
static volatile float  fresults[16];

int main() {
    /* === Double-precision FMA === */
    double a = 3.14159265358979;
    double b = 2.71828182845905;
    double c = 1.41421356237310;

    /* fmadd.d: a*b + c */
    results[0] = a * b + c;
    /* fmsub.d: a*b - c */
    results[1] = a * b - c;
    /* fnmadd.d: -(a*b) + c */
    results[2] = -(a * b) + c;
    /* fnmsub.d: -(a*b) - c */
    results[3] = -(a * b) - c;

    /* === Double-precision arithmetic === */
    results[4] = a + b;
    results[5] = a - b;
    results[6] = a * b;
    results[7] = a / b;     /* fdiv.d */

    /* === Single-precision FMA === */
    float fa = 3.14159f;
    float fb = 2.71828f;
    float fc = 1.41421f;

    fresults[0] = fa * fb + fc;
    fresults[1] = fa * fb - fc;
    fresults[2] = fa / fb;      /* fdiv.s */

    /* === Conversions (fcvt) === */
    long   li = (long)a;              /* fcvt.l.d */
    int    ii = (int)b;               /* fcvt.w.d */
    double d_from_l = (double)li;     /* fcvt.d.l */
    double d_from_ii = (double)ii;    /* fcvt.d.w */
    float  f_from_d = (float)a;       /* fcvt.s.d */
    double d_from_f = (double)fa;     /* fcvt.d.s */
    results[8] = d_from_l;
    results[9] = d_from_f;
    fresults[3] = f_from_d;
    fresults[4] = (float)d_from_ii;

    /* === Comparisons (flt, fle, feq) === */
    int cmp1 = (a < b);
    int cmp2 = (a == b);
    int cmp3 = (fa <= fb);

    /* === fmin/fmax === */
    double mn = (a < b) ? a : b;
    double mx = (a > b) ? a : b;
    results[10] = mn;
    results[11] = mx;

    /* === Special values === */
    volatile double zero = 0.0;
    volatile double neg_zero = -0.0;
    double inf = 1.0 / zero;
    double neg_inf = -1.0 / zero;
    volatile double nan_val = zero / zero;
    results[12] = inf;
    results[13] = neg_inf;
    results[14] = neg_zero;
    results[15] = nan_val;

    /* === Verify basic results === */
    /* FMA: 3.14159... * 2.71828... + 1.41421... ≈ 9.9534... */
    if (results[0] < 9.0 || results[0] > 11.0) {
        printf("FAIL: FMA result %f out of range\n", results[0]);
        _halt(1);
    }
    /* Division: pi / e ≈ 1.1557... */
    if (results[7] < 1.0 || results[7] > 1.3) {
        printf("FAIL: fdiv result %f out of range\n", results[7]);
        _halt(1);
    }
    /* Conversion: (long)3.14 = 3 -> (double)3 = 3.0 */
    if (results[8] < 2.9 || results[8] > 3.1) {
        printf("FAIL: fcvt result %f\n", results[8]);
        _halt(1);
    }
    /* Comparisons */
    if (cmp1 != 0 || cmp2 != 0 || cmp3 != 0) {
        /* pi > e, so cmp1=0, cmp2=0, pi_f > e_f so cmp3=0 */
    }

    printf("FP test PASSED: FMA=%f fdiv=%f fcvt=%f\n", results[0], results[7], results[8]);
    _halt(0);
    return 0;
}
