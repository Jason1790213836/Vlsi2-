// file = 0; split type = patterns; threshold = 100000; total count = 0.
#include <stdio.h>
#include <stdlib.h>
#include <strings.h>
#include "rmapats.h"

void  schedNewEvent (struct dummyq_struct * I1494, EBLK  * I1197, U  I624);
void  schedNewEvent (struct dummyq_struct * I1494, EBLK  * I1197, U  I624)
{
    U  I1788;
    U  I1789;
    U  I1790;
    struct futq * I1791;
    struct dummyq_struct * pQ = I1494;
    I1788 = ((U )vcs_clocks) + I624;
    I1790 = I1788 & ((1 << fHashTableSize) - 1);
    I1197->I669 = (EBLK  *)(-1);
    I1197->I670 = I1788;
    if (0 && rmaProfEvtProp) {
        vcs_simpSetEBlkEvtID((EBLK  *)I1197);
    }
    if (I1788 < (U )vcs_clocks) {
        I1789 = ((U  *)&vcs_clocks)[1];
        sched_millenium(pQ, I1197, I1789 + 1, I1788);
    }
    else if ((peblkFutQ1Head != ((void *)0)) && (I624 == 1)) {
        I1197->I672 = (struct eblk *)peblkFutQ1Tail;
        peblkFutQ1Tail->I669 = I1197;
        peblkFutQ1Tail = I1197;
    }
    else if ((I1791 = pQ->I1392[I1790].I693)) {
        I1197->I672 = (struct eblk *)I1791->I691;
        I1791->I691->I669 = (RP )I1197;
        I1791->I691 = (RmaEblk  *)I1197;
    }
    else {
        sched_hsopt(pQ, I1197, I1788);
    }
}
#ifdef __cplusplus
extern "C" {
#endif
void SinitHsimPats(void);
#ifdef __cplusplus
}
#endif
