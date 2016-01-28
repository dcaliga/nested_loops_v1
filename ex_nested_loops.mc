/* $Id: ex05.mc,v 2.1 2005/06/14 22:16:47 jls Exp $ */

/*
 * Copyright 2005 SRC Computers, Inc.  All Rights Reserved.
 *
 *	Manufactured in the United States of America.
 *
 * SRC Computers, Inc.
 * 4240 N Nevada Avenue
 * Colorado Springs, CO 80907
 * (v) (719) 262-0213
 * (f) (719) 262-0223
 *
 * No permission has been granted to distribute this software
 * without the express permission of SRC Computers, Inc.
 *
 * This program is distributed WITHOUT ANY WARRANTY OF ANY KIND.
 */

#include <libmap.h>


void subr (int64_t I0[], int64_t Out[], int D0, int D1, int64_t *time, int mapnum) {
    OBM_BANK_A (AL, int64_t, MAX_OBM_SIZE)
    OBM_BANK_B (BL, int64_t, MAX_OBM_SIZE)
    int64_t t0, t1;
    
    Stream_64 SA, SB;


    buffered_dma_cpu (CM2OBM, PATH_0, AL, MAP_OBM_stripe (1,"A"), I0, 1, D0*D1*8);


#pragma src parallel sections
{
#pragma src section
{
    int i,j;
    int64_t accum;

    read_timer (&t0);

    for (i=0; i<D0; i++) {
        for (j=0; j<D1; j++) {
           cg_accum_add_64 (AL[i*D1+j], 1, 0, j==0, &accum);
        }

        put_stream_64 (&SB, accum, 1);
    }

    read_timer (&t1);
    *time = t1 - t0;
}
#pragma src section
{
    streamed_dma_cpu_64 (&SB, STREAM_TO_PORT, Out, D0*sizeof(int64_t));
}
}


    }
